# http-client

## Purpose
Shared Dio instance dùng chung cho tất cả metadata adapters, với timeout và header mặc định.

## Requirements

### REQ-1: Singleton instance
`HttpClient.instance` là Dio instance duy nhất, được dùng bởi tất cả adapters.

**Scenario: Truy cập client**
- Given: Bất kỳ adapter nào cần gọi HTTP
- When: `HttpClient.instance`
- Then: Trả về cùng 1 Dio instance
- Reference: `lib/core/network/http_client.dart`

### REQ-2: Default timeouts
- `connectTimeout: 10s`
- `receiveTimeout: 10s`

**Scenario: Timeout mặc định**
- Given: Adapter không override timeout
- When: HTTP request chạy
- Then: Nếu không kết nối trong 10s → throw `DioExceptionType.connectionTimeout`
- Reference: `lib/core/network/http_client.dart:7-8`

### REQ-3: Default headers
- `Accept: text/html,application/xhtml+xml,application/json`

**Scenario: Request headers**
- Given: Adapter gửi GET request
- When: Request được build
- Then: Header `Accept` tự động thêm
- Reference: `lib/core/network/http_client.dart:9-11`

### REQ-4: Per-adapter timeout override
Mỗi adapter có thể override timeout qua `Options(sendTimeout: ..., receiveTimeout: ...)` trong từng request.

**Scenario: Reddit adapter timeout riêng**
- Given: RedditAdapter có `timeout = 6s`
- When: Gọi `_dio.get(url, options: Options(sendTimeout: timeout, receiveTimeout: timeout))`
- Then: Request dùng 6s timeout thay vì 10s mặc định
- Reference: `lib/features/metadata/adapters/reddit_adapter.dart:20-24`

### REQ-5: Per-adapter headers override
Adapter có thể thêm headers riêng (User-Agent) trong từng request.

**Scenario: Reddit User-Agent**
- Given: RedditAdapter
- When: Gọi fetch
- Then: `headers: {'User-Agent': 'Reclip/1.0 (Android; personal use)'}`
- Reference: `lib/features/metadata/adapters/reddit_adapter.dart:23`

## Cần làm rõ
- `HttpClient.instance` là static final — tạo 1 lần, không thể reset hoặc dispose. Nếu cần thay đổi config (vd: thêm interceptor logging), phải sửa trực tiếp file này.
- Không có retry interceptor ở tầng HTTP — retry logic nằm trong `EnrichmentOrchestrator`.
- Không có logging interceptor — khó debug HTTP requests ở production. Cần thêm nếu muốn trace API calls.
