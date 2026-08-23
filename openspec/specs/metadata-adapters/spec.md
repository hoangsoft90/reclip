# metadata-adapters

## Purpose
Fetch metadata (title, author, thumbnail, content type) từ platform gốc. 5 adapter riêng + 1 OG fallback. Adapter KHÔNG BAO GIỜ throw exception — luôn trả `MetadataResult`.

## Requirements

### REQ-1: PlatformAdapter interface
Mọi adapter implement abstract class `PlatformAdapter` với `timeout` getter và `fetch(url)` method.

**Scenario: Interface contract**
- Given: Bất kỳ adapter nào
- When: Gọi `adapter.fetch(url)`
- Then: Trả về `MetadataResult` với `status` là success/partial/failed. KHÔNG throw exception.
- Reference: `lib/features/metadata/domain/platform_adapter.dart`

### REQ-2: MetadataResult model
Kết quả trả về gồm: status, title, description, author, authorUrl, thumbnailUrl, contentType, failureReason.

**Scenario: Success result**
- Given: Adapter fetch thành công
- When: Trả về `MetadataResult`
- Then: `status = success`, các field khác populated tùy adapter
- Reference: `lib/features/metadata/domain/metadata_result.dart`

**Scenario: Failed result**
- Given: Adapter fetch thất bại
- When: Trả về `MetadataResult.failed(reason)`
- Then: `status = failed`, `failureReason` chứa lý do
- Reference: `lib/features/metadata/domain/metadata_result.dart:30-33`

### REQ-3: RedditAdapter
Dùng Reddit JSON API (`/.json` suffix). Timeout 6s.

**Scenario: Reddit fetch success**
- Given: URL `https://reddit.com/r/flutter/comments/abc`
- When: `RedditAdapter.fetch(url)`
- Then: Append `.json` → GET → parse `data.children[0].data` → trả title, author, thumbnail, contentType
- Reference: `lib/features/metadata/adapters/reddit_adapter.dart`

**Scenario: Reddit thumbnail detection**
- Given: Reddit post có thumbnail URL
- When: Parse response
- Then: `thumbnail` phải bắt đầu bằng `http` và không phải `self`/`default` mới trả về
- Reference: `lib/features/metadata/adapters/reddit_adapter.dart:64-68`

### REQ-4: YouTubeAdapter
Dùng oEmbed API (`youtube.com/oembed`). Timeout 6s.

**Scenario: YouTube fetch success**
- Given: URL `https://youtube.com/watch?v=abc`
- When: `YouTubeAdapter.fetch(url)`
- Then: GET oEmbed → parse title, author_name, author_url, thumbnail_url, contentType = video
- Reference: `lib/features/metadata/adapters/youtube_adapter.dart`

### REQ-5: XAdapter
Dùng Twitter oEmbed API (`publish.twitter.com/oembed`). Timeout 6s.

**Scenario: X fetch success**
- Given: URL `https://x.com/user/status/123`
- When: `XAdapter.fetch(url)`
- Then: GET oEmbed → parse `author_name`, extract tweet text từ HTML `<p>` tag
- Reference: `lib/features/metadata/adapters/x_adapter.dart`

### REQ-6: TikTokAdapter
Best-effort, parse HTML page. Timeout 4s (ngắn hơn vì hay fail).

**Scenario: TikTok fetch**
- Given: URL `https://tiktok.com/@user/video/123`
- When: `TikTokAdapter.fetch(url)`
- Then: GET page → parse `og:title`, `og:description`, `og:image` từ HTML
- Reference: `lib/features/metadata/adapters/tiktok_adapter.dart`

### REQ-7: InstagramAdapter
Best-effort, parse HTML page. Timeout 4s.

**Scenario: Instagram fetch**
- Given: URL `https://instagram.com/p/ABC123/`
- When: `InstagramAdapter.fetch(url)`
- Then: GET page → parse OG tags → detect content type (video/gallery/image) từ HTML
- Reference: `lib/features/metadata/adapters/instagram_adapter.dart`

**Scenario: Instagram content type detection**
- Given: Instagram page HTML
- When: Parse
- Then: Nếu chứa `"video_url"` → video, nếu chứa `"edge_sidecar"` → gallery, mặc định → image
- Reference: `lib/features/metadata/adapters/instagram_adapter.dart:42-47`

### REQ-8: GenericOpenGraphAdapter
Fallback cuối cùng, parse `og:title`, `og:image`, `og:description` từ bất kỳ URL nào. Timeout 5s.

**Scenario: OG fallback**
- Given: URL từ platform không có adapter riêng (vd: `example.com`)
- When: `GenericOpenGraphAdapter.fetch(url)`
- Then: GET page → parse HTML → extract OG tags. Nếu cả title và image đều null → failed
- Reference: `lib/features/metadata/adapters/generic_opengraph_adapter.dart`

### REQ-9: MetadataAdapterFactory
Chọn adapter đúng theo `PlatformEnum`. Platform `other` → OG fallback.

**Scenario: Factory routing**
- Given: `PlatformEnum.reddit`
- When: `_adapterFactory.forPlatform(reddit)`
- Then: Trả về `RedditAdapter`
- Reference: `lib/features/metadata/metadata_adapter_factory.dart:19-26`

### REQ-10: Error handling — NEVER throw
Mọi adapter catch tất cả exceptions và trả `MetadataResult.failed(reason)`.

**Scenario: Network error**
- Given: Device mất kết nối
- When: Gọi `adapter.fetch(url)`
- Then: Catch exception → trả `MetadataResult.failed('reddit_fetch_error: ...')`
- Reference: `lib/features/metadata/adapters/reddit_adapter.dart:44-46` (catch block)

**Scenario: Invalid response**
- Given: API trả JSON không đúng format
- When: Parse response
- Then: Kiểm tra `is List`, `is Map` trước khi access → nếu sai → trả `failed` với lý do cụ thể
- Reference: `lib/features/metadata/adapters/reddit_adapter.dart:22-36`

## Cần làm rõ
- Reddit adapter dùng User-Agent `Reclip/1.0 (Android; personal use)` — Reddit có thể block nếu user-agent bị detect là bot.
- TikTok và Instagram adapters parse HTML trực tiếp — cấu trúc HTML thay đổi thường xuyên, tỷ lệ fail cao là expected behavior.
- YouTube oEmbed API không cần API key nhưng có thể rate-limit.
- X oEmbed dùng `publish.twitter.com` endpoint — Twitter có thể thay đổi endpoint này.
- `MetadataResult` phân biệt `partial` (có MỘT SỐ field) vs `success` (đầy đủ) — nhưng hiện tại orchestrator xử lý cả hai giống nhau (persist cả partial).
