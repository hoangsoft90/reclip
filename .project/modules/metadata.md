# Module: metadata

## Mục đích
Fetch metadata (title, author, thumbnail, content type) từ platform gốc. 5 adapter + 1 OG fallback.

## Files

### Domain
- `lib/features/metadata/domain/platform_adapter.dart` — Abstract interface
- `lib/features/metadata/domain/metadata_result.dart` — Result model

### Adapters
- `lib/features/metadata/adapters/reddit_adapter.dart` — Reddit JSON API (`/.json`)
- `lib/features/metadata/adapters/youtube_adapter.dart` — YouTube oEmbed
- `lib/features/metadata/adapters/x_adapter.dart` — Twitter oEmbed
- `lib/features/metadata/adapters/tiktok_adapter.dart` — Best-effort HTML parse
- `lib/features/metadata/adapters/instagram_adapter.dart` — Best-effort HTML parse
- `lib/features/metadata/adapters/generic_opengraph_adapter.dart` — OG fallback

### Application
- `lib/features/metadata/metadata_adapter_factory.dart` — Route to adapter by platform
- `lib/features/metadata/application/enrichment_orchestrator.dart` — Queue processor
- `lib/features/metadata/application/thumbnail_download_service.dart` — Download + cache
- `lib/features/metadata/application/metrics_logger.dart` — Success rate tracking

## Data Flow
```
EnrichmentOrchestrator.processPendingQueue()
    → findByMetadataStatus(pending)
    → for each item:
        → adapterFactory.forPlatform(platform).fetch(canonicalUrl)
        → [fail] → retry (max 2) → openGraphFallback.fetch()
        → updateSavedItem(status, title, description, author)
        → thumbnailService.enqueueDownload(itemId, thumbnailUrl)
        → metricsLogger.logMetadataResult(platform, status)
```

## API Endpoints

| Adapter | Endpoint | Timeout |
|---------|----------|---------|
| Reddit | `{url}.json` | 6s |
| YouTube | `youtube.com/oembed?url=...&format=json` | 6s |
| X/Twitter | `publish.twitter.com/oembed?url=...` | 6s |
| TikTok | Direct page fetch + OG parse | 4s |
| Instagram | Direct page fetch + OG parse | 4s |
| OG Fallback | Direct page fetch + `<meta>` parse | 5s |

## Local Storage
- SQLite: `saved_items` (UPDATE metadata fields)
- SQLite: `thumbnails` (INSERT + UPDATE download status)
- flutter_cache_manager: file cache for thumbnail images

## Known Issues
- TikTok/Instagram hay thay đổi HTML → tỷ lệ fail cao (expected behavior)
- Không có per-platform concurrency limit (chỉ global max 3)
- Thumbnail download dùng `unawaited()` — app kill giữa chừng → stuck ở downloading
