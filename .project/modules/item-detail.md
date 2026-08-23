# Module: item-detail

## Mục đích
Hiển thị chi tiết item: thumbnail, title, platform, author, content type, note, badges, actions.

## Files
- `lib/features/item_detail/presentation/item_detail_screen.dart` — Detail screen
- `lib/features/item_detail/application/open_original_service.dart` — Open URL in browser

## Data Flow
```
ItemDetailScreen(item, db)
    ├── FutureBuilder(db.findThumbnailByItemId()) → thumbnail
    ├── Display: title, platform, author, contentType badge
    ├── Display: description, note, whySaved badge
    └── Actions:
         ├── "Open Original" → OpenOriginalService.open() → url_launcher
         └── "Add details" → SmartSaveBottomSheet
```

## Local Storage
- SQLite: `saved_items` (read), `thumbnails` (read)
- Smart Save: `updateSavedItem(id, note, whySaved)` on Save

## API Endpoints
- OpenOriginalService: `url_launcher` → `canLaunchUrl()` + `launchUrl()` (external browser)

## Known Issues
- Favorite toggle chưa implement (`onPressed: () {}`)
- Options menu chưa implement
- Cả "Online to view" và "Video requires Internet" badge đều hiện cho video items
