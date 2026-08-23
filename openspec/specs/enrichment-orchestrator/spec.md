# enrichment-orchestrator

## Purpose
Xử lý hàng đợi metadata: tìm items có `metadataStatus = pending`, fetch metadata bằng adapter phù hợp, retry nếu lỗi network, fallback OpenGraph, persist kết quả.

## Requirements

### REQ-1: processPendingQueue
Xử lý tất cả items pending. Gọi khi: (a) app khởi động, (b) app resume, (c) ngay sau Quick Save mới.

**Scenario: App khởi động**
- Given: DB có 5 items `metadataStatus = pending`
- When: `app.dart` gọi `_triggerEnrichment()` trong `addPostFrameCallback`
- Then: `processPendingQueue()` tìm 5 items → enrich từng cái
- Reference: `lib/app.dart:33-35`, `lib/features/metadata/application/enrichment_orchestrator.dart:23-36`

**Scenario: App resume**
- Given: App bị pause rồi resume
- When: `didChangeAppLifecycleState(AppLifecycleState.resumed)`
- Then: Gọi `_triggerEnrichment()` → `processPendingQueue()`
- Reference: `lib/app.dart:39-43`

### REQ-2: Concurrency limit = 3
Tối đa 3 requests chạy song song, tránh spam cùng platform.

**Scenario: 10 items pending**
- Given: 10 items pending
- When: `processPendingQueue()` chạy
- Then: Batch 3 items đầu tiên → đợi ít nhất 1 hoàn thành → thêm item tiếp → lặp
- Reference: `lib/features/metadata/application/enrichment_orchestrator.dart:30-35`, `_maxConcurrent = 3`

### REQ-3: Retry logic
Lỗi network/timeout → retry tối đa `_maxRetries = 2` lần với backoff (2s, 4s). KHÔNG retry cho 'partial'.

**Scenario: Timeout → retry**
- Given: Adapter trả `failed` vì timeout
- When: `_enrichOne(item, attempt=0)`
- Then: Đợi `2 * (0+1) = 2s` → gọi lại `_enrichOne(item, attempt=1)` → nếu fail lần nữa → đợi 4s → attempt=2 → hết retry
- Reference: `lib/features/metadata/application/enrichment_orchestrator.dart:47-52`

**Scenario: Hết retry → fallback OG**
- Given: Adapter fail sau 2 retries
- When: `_enrichOne` với `attempt = _maxRetries`
- Then: Gọi `openGraphFallback.fetch(url)` → persist kết quả OG
- Reference: `lib/features/metadata/application/enrichment_orchestrator.dart:54-58`

### REQ-4: OpenGraph fallback
Nếu adapter riêng fail hoàn tất retries → thử `GenericOpenGraphAdapter` trước khi chấp nhận failed.

**Scenario: Fallback OG**
- Given: RedditAdapter fail, hết retry
- When: `_enrichOne` xử lý
- Then: Gọi `_adapterFactory.openGraphFallback.fetch(item.canonicalUrl)` → persist OG result
- Reference: `lib/features/metadata/application/enrichment_orchestrator.dart:54-58`

### REQ-5: Persist result
Gọi `updateSavedItem` với title, description, author, status từ `MetadataResult`.

**Scenario: Persist success**
- Given: `MetadataResult(status: success, title: "Flutter Guide", author: "u/dev")`
- When: `_persistResult(item, result)`
- Then: `updateSavedItem(id: item.id, status: success, title: "Flutter Guide", author: "u/dev")`
- Reference: `lib/features/metadata/application/enrichment_orchestrator.dart:61-70`

### REQ-6: Trigger thumbnail download
Nếu `result.thumbnailUrl != null` → enqueue download.

**Scenario: Có thumbnail URL**
- Given: `MetadataResult` có `thumbnailUrl = "https://..."` 
- When: `_persistResult` chạy
- Then: Gọi `_thumbnailService.enqueueDownload(item.id, thumbnailUrl)`
- Reference: `lib/features/metadata/application/enrichment_orchestrator.dart:66-68`

### REQ-7: Metrics logging
Mỗi enrichment result được log qua `MetricsLogger.logMetadataResult`.

**Scenario: Log metadata result**
- Given: Enrichment hoàn thành cho item Reddit
- When: `_persistResult` chạy
- Then: `MetricsLogger.logMetadataResult(PlatformEnum.reddit, MetadataStatusEnum.success)`
- Reference: `lib/features/metadata/application/enrichment_orchestrator.dart:70`

## Cần làm rõ
- `processPendingQueue` load TẤT CẢ pending items vào memory trước khi xử lý. Nếu có hàng nghìn items pending (app không mở lâu), có thể tốn memory. Ở MVP scale, chấp nhận được.
- Không có per-platform concurrency limit — chỉ có global limit 3. Nếu 3 requests cùng TikTok (hay bị rate-limit), có thể bị block. Brief gợi ý "cân nhắc thêm per-platform concurrency limit" nhưng chưa implement.
- Không có expiry cho retry — item pending sẽ luôn được retry khi app resume, cho đến khi thành công hoặc chuyển sang `failed`.
