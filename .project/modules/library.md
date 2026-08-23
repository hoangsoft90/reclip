# Module: library

## Mục đích
Hiển thị tất cả items đã lưu dưới dạng Grid/List, kèm thumbnails, Quick Link Card, filter.

## Files
- `lib/features/library/presentation/library_screen.dart` — Main screen
- `lib/features/library/presentation/widgets/quick_link_card.dart` — Card cho metadata pending/failed
- `lib/features/library/presentation/widgets/facet_filter_bar.dart` — Filter chips
- `lib/features/library/presentation/widgets/offline_banner.dart` — Offline indicator
- `lib/features/library/application/facet_filter_controller.dart` — Filter logic

## Data Flow
```
StreamBuilder(savedItems.watch()) → allItems
    → FacetFilterController.applyFilter(allItems) → filtered items
    → [metadata pending/failed] → QuickLinkCard
    → [metadata success] → GridCard/ListTile (with thumbnail)
```

## Local Storage
- SQLite: `saved_items` table (read-only stream via `watch()`)
- SQLite: `thumbnails` table (preloaded via `getThumbnailPathsForItems()`)

## UI Components
| Component | Description |
|-----------|-------------|
| Grid Card | Thumbnail + title + platform icon |
| List Tile | Thumbnail 48x48 + title + platform + date + favorite star |
| Quick Link Card | Domain name + platform icon + "Edit title" button |
| Facet Filter Bar | Horizontal scrollable chips |
| Offline Banner | Orange banner "⚠ Online to view" |

## Known Issues
- Date range picker trong FacetFilter chưa có UI
- Filter chạy client-side (load all items vào memory)
