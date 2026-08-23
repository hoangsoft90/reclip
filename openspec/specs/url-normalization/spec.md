# url-normalization

## Purpose
Biến URL gốc (rawUrl) từ share intent thành canonical URL bằng cách loại bỏ tracking params, fragment, trailing slash — dùng để phát hiện trùng lặp (dedup) ở tầng service.

## Requirements

### REQ-1: Loại bỏ tracking params
Canonical URL phải loại bỏ tất cả query params nằm trong danh sách `_trackingParams`, giữ lại các param khác.

**Tracking params list:** `utm_source`, `utm_medium`, `utm_campaign`, `utm_content`, `utm_term`, `igsh`, `igshid`, `fbclid`, `gclid`, `si`, `ref`, `ref_src`, `ref_url`, `s`, `t`, `feature`

**Case-insensitive:** `UTM_SOURCE` và `utm_source` đều bị loại bỏ.

**Scenario: Loại bỏ nhiều tracking params cùng lúc**
- Given: URL `https://reddit.com/r/flutter?ref=sidebar&sort=top&t=week&feature=share`
- When: Gọi `UrlNormalizer.canonicalize(url)`
- Then: Kết quả là `https://reddit.com/r/flutter?sort=top` (`ref`, `t`, `feature` bị loại; `sort` giữ lại)
- Reference: `lib/core/url/url_normalizer.dart:26-28`, `test/core/url_normalizer_test.dart:53-58`

**Scenario: Case-insensitive tracking params**
- Given: URL `https://example.com/page?UTM_SOURCE=google&UTM_MEDIUM=cpc`
- When: Gọi `UrlNormalizer.canonicalize(url)`
- Then: Kết quả là `https://example.com/page`
- Reference: `lib/core/url/url_normalizer.dart:27` (`.toLowerCase()`), `test/core/url_normalizer_test.dart:43-48`

### REQ-2: Loại bỏ fragment
Canonical URL phải loại bỏ hoàn toàn fragment (`#section`).

**Scenario: Fragment bị loại bỏ**
- Given: URL `https://example.com/page#section1`
- When: Gọi `UrlNormalizer.canonicalize(url)`
- Then: Kết quả là `https://example.com/page`
- Reference: `lib/core/url/url_normalizer.dart:42` (comment "No fragment — intentionally omitted"), `test/core/url_normalizer_test.dart:34-38`

### REQ-3: Loại bỏ trailing slash
Trailing slash bị loại bỏ trừ khi URL chỉ có path gốc `/`.

**Scenario: Trailing slash bị loại**
- Given: URL `https://example.com/page/`
- When: Gọi `UrlNormalizer.canonicalize(url)`
- Then: Kết quả là `https://example.com/page`
- Reference: `lib/core/url/url_normalizer.dart:45-48`, `test/core/url_normalizer_test.dart:40-41`

**Scenario: Root path giữ nguyên**
- Given: URL `https://example.com/`
- When: Gọi `UrlNormalizer.canonicalize(url)`
- Then: Kết quả là `https://example.com`
- Reference: `test/core/url_normalizer_test.dart:44`

### REQ-4: Giữ nguyên non-tracking params
Các query params không nằm trong danh sách phải được giữ nguyên.

**Scenario: Giữ params bình thường**
- Given: URL `https://example.com/page?utm_source=fb&v=2&sort=new`
- When: Gọi `UrlNormalizer.canonicalize(url)`
- Then: Kết quả là `https://example.com/page?v=2&sort=new`
- Reference: `test/core/url_normalizer_test.dart:25-29`

### REQ-5: Xử lý input không hợp lệ
Input rỗng hoặc không parse được → trả về input đã trim, không throw exception.

**Scenario: Input rỗng**
- Given: Input `"   "` (whitespace only)
- When: Gọi `UrlNormalizer.canonicalize(input)`
- Then: Kết quả là `""`
- Reference: `lib/core/url/url_normalizer.dart:18-19`, `test/core/url_normalizer_test.dart:37-39`

**Scenario: Input không phải URL**
- Given: Input `"not-a-url"`
- When: Gọi `UrlNormalizer.canonicalize(input)`
- Then: Kết quả là `"not-a-url"` (trả lại nguyên văn)
- Reference: `test/core/url_normalizer_test.dart:39`

### REQ-6: Giữ nguyên scheme + host + port (nếu non-default)
Port mặc định (80 cho http, 443 cho https) bị ẩn. Port khác giữ lại.

**Scenario: Giữ non-default port**
- Given: URL `https://example.com:8080/page`
- When: Gọi `UrlNormalizer.canonicalize(url)`
- Then: Kết quả là `https://example.com:8080/page`
- Reference: `lib/core/url/url_normalizer.dart:32-34`

### REQ-7: Giữ nguyên query param encoding
Query params được encode qua `Uri.encodeComponent`.

**Scenario: Params có ký tự đặc biệt**
- Given: URL có param chứa ký tự space hoặc unicode
- When: Gọi `UrlNormalizer.canonicalize(url)`
- Then: Params được encode đúng qua `Uri.encodeComponent`
- Reference: `lib/core/url/url_normalizer.dart:37-39`

## Cần làm rõ
- `_trackingParams` là set cứng 16 param. Nếu platform mới thêm tracking param riêng (vd: `spm` trên YouTube), cần update set này. Hiện tại chưa có cơ chế cấu hình ngoại (hardcoded).
- Param `t` trong danh sách tracking có thể trùng với param `t` trên Reddit (sorting time). Test case `test/core/url_normalizer_test.dart:53-58` xác nhận `t=week` bị loại — đây là hành vi đúng theo thiết kế nhưng có thể gây confusion.
