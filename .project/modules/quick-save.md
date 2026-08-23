# Module: quick-save

## Mục đích
Lưu URL nhanh (<300ms) với dedup logic. Không fetch metadata, không hiện UI bổ sung.

## Files
- `lib/features/share_intent/quick_save_service.dart`

## Data Flow
```
rawUrl → UrlNormalizer.canonicalize() → PlatformDetector.detect()
    → findByCanonicalUrl() → [new: insertSavedItem | existing: touchLastAccessed]
    → SaveResult.savedNew | SaveResult.alreadyExists
```

## Local Storage
- SQLite: `saved_items` table
  - INSERT (new item): `metadataStatus = pending`, `contentType = unknown`
  - UPDATE (dedup): `last_accessed_at = now`

## API Endpoints
Không có — hoạt động hoàn toàn offline.

## Known Issues
- Smart Save "Save as new entry" chưa implement code (chỉ có UI placeholder)
