# platform-detection

## Purpose
Xác định platform mạng xã hội (Reddit, Instagram, TikTok, YouTube, X) từ URL, dùng để chọn metadata adapter phù hợp và hiển thị icon/color trên UI.

## Requirements

### REQ-1: Nhận diện Reddit
URL có host thuộc danh sách → trả `PlatformEnum.reddit`.

**Domains:** `reddit.com`, `www.reddit.com`, `redd.it`, `v.redd.it`
**Subdomain matching:** `old.reddit.com` cũng match (qua `host.endsWith('.reddit.com')`)

**Scenario: Reddit full URL**
- Given: URL `https://www.reddit.com/r/flutter/comments/abc`
- When: Gọi `PlatformDetector.detect(url)`
- Then: Trả về `PlatformEnum.reddit`
- Reference: `lib/core/url/platform_detector.dart:10-13`, `test/core/platform_detector_test.dart:7-12`

**Scenario: Reddit short link**
- Given: URL `https://redd.it/abc123`
- When: Gọi `PlatformDetector.detect(url)`
- Then: Trả về `PlatformEnum.reddit`
- Reference: `test/core/platform_detector_test.dart:14-19`

**Scenario: Reddit video CDN**
- Given: URL `https://v.redd.it/abc123/video.mp4`
- When: Gọi `PlatformDetector.detect(url)`
- Then: Trả về `PlatformEnum.reddit`
- Reference: `test/core/platform_detector_test.dart:21-26`

### REQ-2: Nhận diện Instagram
**Domains:** `instagram.com`, `www.instagram.com`, `instagr.am`

**Scenario: Instagram post**
- Given: URL `https://www.instagram.com/p/ABC123/`
- When: Gọi `PlatformDetector.detect(url)`
- Then: Trả về `PlatformEnum.instagram`
- Reference: `test/core/platform_detector_test.dart:28-33`

**Scenario: Instagram short link**
- Given: URL `https://instagr.am/p/ABC123/`
- When: Gọi `PlatformDetector.detect(url)`
- Then: Trả về `PlatformEnum.instagram`
- Reference: `test/core/platform_detector_test.dart:35-40`

### REQ-3: Nhận diện TikTok
**Domains:** `tiktok.com`, `www.tiktok.com`, `vt.tiktok.com`, `vm.tiktok.com`

**Scenario: TikTok short link (vt)**
- Given: URL `https://vt.tiktok.com/ZSabcdef/`
- When: Gọi `PlatformDetector.detect(url)`
- Then: Trả về `PlatformEnum.tiktok`
- Reference: `test/core/platform_detector_test.dart:42-47`

**Scenario: TikTok short link (vm)**
- Given: URL `https://vm.tiktok.com/ZSabcdef/`
- When: Gọi `PlatformDetector.detect(url)`
- Then: Trả về `PlatformEnum.tiktok`
- Reference: `test/core/platform_detector_test.dart:67-72`

### REQ-4: Nhận diện YouTube
**Domains:** `youtube.com`, `www.youtube.com`, `youtu.be`, `m.youtube.com`

**Scenario: YouTube short link**
- Given: URL `https://youtu.be/dQw4w9WgXcQ`
- When: Gọi `PlatformDetector.detect(url)`
- Then: Trả về `PlatformEnum.youtube`
- Reference: `test/core/platform_detector_test.dart:49-54`

**Scenario: YouTube mobile**
- Given: URL `https://m.youtube.com/watch?v=abc`
- When: Gọi `PlatformDetector.detect(url)`
- Then: Trả về `PlatformEnum.youtube`
- Reference: `test/core/platform_detector_test.dart:74-79`

### REQ-5: Nhận diện X (Twitter)
**Domains:** `twitter.com`, `x.com`, `www.x.com`, `www.twitter.com`, `t.co`

**Scenario: X.com URL**
- Given: URL `https://x.com/user/status/123`
- When: Gọi `PlatformDetector.detect(url)`
- Then: Trả về `PlatformEnum.x`
- Reference: `test/core/platform_detector_test.dart:56-59`

**Scenario: Twitter short link**
- Given: URL `https://t.co/abc123`
- When: Gọi `PlatformDetector.detect(url)`
- Then: Trả về `PlatformEnum.x`
- Reference: `test/core/platform_detector_test.dart:81-86`

### REQ-6: Fallback → other
Domain không nằm trong danh sách nào → trả `PlatformEnum.other`. KHÔNG throw exception.

**Scenario: Domain lạ**
- Given: URL `https://example.com/page`
- When: Gọi `PlatformDetector.detect(url)`
- Then: Trả về `PlatformEnum.other`
- Reference: `test/core/platform_detector_test.dart:61-66`

**Scenario: URL không hợp lệ**
- Given: Input `"not-a-url"` hoặc `""`
- When: Gọi `PlatformDetector.detect(input)`
- Then: Trả về `PlatformEnum.other`
- Reference: `test/core/platform_detector_test.dart:68-73`

### REQ-7: Case-insensitive host matching
Host được convert về lowercase trước khi so sánh.

**Scenario: Host viết hoa**
- Given: URL `https://WWW.REDDIT.com/r/flutter`
- When: Gọi `PlatformDetector.detect(url)`
- Then: Trả về `PlatformEnum.reddit`
- Reference: `lib/core/url/platform_detector.dart:7` (`.toLowerCase()`)

### REQ-8: Subdomain matching
Host kết thúc bằng `.<domain>` cũng match (vd: `old.reddit.com`, `m.youtube.com`).

**Scenario: Subdomain**
- Given: URL `https://old.reddit.com/r/flutter`
- When: Gọi `PlatformDetector.detect(url)`
- Then: Trả về `PlatformEnum.reddit`
- Reference: `lib/core/url/platform_detector.dart:42` (`host.endsWith('.$d')`)

## Cần làm rõ
- `_matchesAny` dùng `host.endsWith('.$d')` — nghĩa là subdomain nào cũng match, kể cả `evil.reddit.com.attacker.com`. Đây là cơ chế match cuối chuỗi, không phải exact domain. Vấn đề này không ảnh hưởng trong thực tế vì Reclip chỉ nhận URL từ share intent (user chủ động share), nhưng cần lưu ý nếu mở rộng sang URL nhập tay.
- Platform `other` được coi là hợp lệ — item vẫn save thành công, dùng OG fallback adapter ở Phase 2.
