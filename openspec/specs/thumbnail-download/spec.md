# thumbnail-download

## Purpose
Tải thumbnail ảnh từ remote URL, cache cục bộ, quản lý dung lượng cache tối đa 200MB (LRU).

## Requirements

### REQ-1: Enqueue download
Sau khi enrichment取得 thumbnail URL → enqueue download vào DB + chạy nền.

**Scenario: Enqueue**
- Given: `MetadataResult` có `thumbnailUrl = "https://img.reddit.com/..."`, `itemId = "abc"`
- When: Gọi `enqueueDownload("abc", thumbnailUrl)`
- Then: Kiểm tra chưa có thumbnail cho item → insert vào DB với `downloadStatus = pending` → `unawaited(_download(...))` chạy nền
- Reference: `lib/features/metadata/application/thumbnail_download_service.dart:14-23`

### REQ-2: Không duplicate download
Nếu item đã có thumbnail trong DB → skip.

**Scenario: Đã có thumbnail**
- Given: Item "abc" đã có 1 thumbnail record
- When: Gọi `enqueueDownload("abc", newUrl)`
- Then: `findThumbnailByItemId("abc")` trả về existing → return ngay, KHÔNG insert thêm
- Reference: `lib/features/metadata/application/thumbnail_download_service.dart:15-17`

### REQ-3: Download process
Flow: update status → downloading → fetch file → update result (done + localPath + sizeBytes).

**Scenario: Download thành công**
- Given: Thumbnail record với `downloadStatus = pending`
- When: `_download(thumbId, remoteUrl)` chạy
- Then: 1) `updateStatus(thumbId, downloading)` → 2) `DefaultCacheManager().getSingleFile(url)` → 3) `updateResult(thumbId, localPath, sizeBytes, done)`
- Reference: `lib/features/metadata/application/thumbnail_download_service.dart:25-35`

**Scenario: Download thất bại**
- Given: Network error hoặc URL invalid
- When: `_download` catch exception
- Then: `updateStatus(thumbId, failed)` — item vẫn tồn tại, chỉ mất thumbnail
- Reference: `lib/features/metadata/application/thumbnail_download_service.dart:36-38`

### REQ-4: Cache size limit = 200MB
Tổng dung lượng thumbnails done không vượt quá `maxCacheSizeBytes` (200MB).

**Scenario: Vượt quá 200MB**
- Given: Tổng size thumbnails done = 210MB
- When: Download thumbnail mới thành công
- Then: `_enforceMaxCacheSize()` chạy → tìm oldest thumbnails done → xóa file local + clear localPath cho đến khi total ≤ 200MB
- Reference: `lib/features/metadata/application/thumbnail_download_service.dart:40-52`

### REQ-5: LRU eviction
Xóa theo `createdAt` tăng dần (cũ nhất trước).

**Scenario: Evict oldest**
- Given: 10 thumbnails cần xóa để dưới 200MB
- When: `_enforceMaxCacheSize` chạy
- Then: `findOldestDoneThumbnails(limit: 10)` trả thumbnails cũ nhất → xóa file + clear localPath → kiểm tra lại total
- Reference: `lib/features/metadata/application/thumbnail_download_service.dart:43-51`

### REQ-6: Không xóa saved_items
Khi xóa thumbnail cache, KHÔNG xóa `saved_items` liên quan. Item vẫn tồn tại, chỉ mất ảnh cache.

**Scenario: Evict giữ item**
- Given: Item "abc" có thumbnail đang bị evict
- When: `_enforceMaxCacheSize` xóa thumbnail
- Then: `clearThumbnailLocalPath(thumbId)` — chỉ clear `localPath`, KHÔNG delete `saved_items`
- Reference: `lib/features/metadata/application/thumbnail_download_service.dart:49`

### REQ-7: flutter_cache_manager
Dùng `DefaultCacheManager().getSingleFile(url)` — tự động cache file locally.

**Scenario: Cache hit**
- Given: File đã được download trước đó
- When: Gọi `getSingleFile(url)`
- Then: Trả về file local từ cache, KHÔNG download lại
- Reference: `lib/features/metadata/application/thumbnail_download_service.dart:30`

## Cần làm rõ
- `DefaultCacheManager` có cache limit riêng (default 200MB, nhưng khác với `_maxCacheSizeBytes` của Reclip). Có 2 lớp cache: flutter_cache_manager cache và Reclip DB tracking. Nếu flutter_cache_manager tự xóa file (qua TTL), DB vẫn nghĩ file tồn tại → crash khi load ảnh. Cần sync giữa 2 lớp cache.
- `_download` dùng `unawaited()` — download chạy nền, không await. Nếu app bị kill giữa chừng, download bị hủy và thumbnail stuck ở `downloading` status. Không có retry cho thumbnail download.
