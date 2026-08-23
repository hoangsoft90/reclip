# Module: share-intent

## Mục đích
Nhận URL từ Android Share Sheet, trích xuất URL, trigger Quick Save tự động.

## Files
- `lib/features/share_intent/share_intent_handler.dart` — Listen share intent
- `lib/features/share_intent/quick_save_service.dart` — Quick Save flow + dedup

## Data Flow
```
Android Share Sheet → ReceiveSharingIntent → ShareIntentHandler._handleShare()
    → _extractUrl() → QuickSaveService.quickSave(url)
```

## Dependencies
- `receive_sharing_intent: ^1.8.0`
- `AppDatabase` (for dedup check + insert)
- `UrlNormalizer`, `PlatformDetector`

## Local Storage
- SQLite via Drift: `saved_items` table (insert + findByCanonicalUrl)

## Known Issues
- Chỉ nhận `text/plain` — image share không xử lý
- Regex `https?://[^\s]+` chỉ match URL có scheme http/https
