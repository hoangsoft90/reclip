# library

## Purpose
Hiển thị tất cả items đã lưu dưới dạng Grid hoặc List, kèm thumbnail (nếu có), Quick Link Card (nếu metadata failed/pending), và empty state.

## Requirements

### REQ-1: Grid/List toggle
User có thể chuyển đổi giữa Grid view và List view bằng nút toggle trên AppBar.

**Scenario: Mặc định là Grid**
- Given: Library screen mở lần đầu
- When: Render UI
- Then: Hiển thị Grid view (2 cột)
- Reference: `lib/features/library/presentation/library_screen.dart:21` (`_isGridView = true`)

**Scenario: Chuyển sang List**
- Given: Đang ở Grid view
- When: Bấm nút toggle trên AppBar
- Then: Chuyển sang List view
- Reference: `lib/features/library/presentation/library_screen.dart:37-40`

### REQ-2: Realtime updates qua StreamBuilder
Library tự động refresh khi DB thay đổi (không cần pull-to-refresh).

**Scenario: Item mới được save**
- Given: Library đang hiển thị 3 items
- When: User share thêm 1 URL → item mới được insert vào DB
- Then: StreamBuilder nhận stream update → UI tự động hiển thị item mới
- Reference: `lib/features/library/presentation/library_screen.dart:62` (`stream: widget.db.select(widget.db.savedItems).watch()`)

### REQ-3: Empty state
Khi chưa có item nào, hiện empty state với icon + text.

**Scenario: Library trống**
- Given: DB không có item nào
- When: Library screen render
- Then: Hiện icon bookmark + "Nothing saved yet" + "Share a post from any app to save it here."
- Reference: `lib/features/library/presentation/library_screen.dart:82-98`, `lib/core/constants/app_strings.dart`

### REQ-4: Quick Link Card cho metadata pending/failed
Items có `metadataStatus = pending` hoặc `failed` hiển thị bằng QuickLinkCard thay vì card thường.

**Scenario: Item pending metadata**
- Given: Item có `metadataStatus = pending`
- When: Library render item đó
- Then: Hiển thị QuickLinkCard với domain name, platform icon, nút "Edit title"
- Reference: `lib/features/library/presentation/library_screen.dart:107-113`, `lib/features/library/presentation/widgets/quick_link_card.dart`

### REQ-5: Card thường cho metadata success/partial
Items có `metadataStatus = success` hoặc `partial` hiển thị card với thumbnail + title + platform.

**Scenario: Item có metadata đầy đủ**
- Given: Item có `metadataStatus = success`, `title = "Flutter Tutorial"`
- When: Library render trong Grid view
- Then: Card hiển thị thumbnail (nếu có) hoặc placeholder icon + title + platform name
- Reference: `lib/features/library/presentation/library_screen.dart:120-149`

### REQ-6: Display title fallback
Khi `title = null` (metadata chưa fetch), hiển thị domain từ `canonical_url`.

**Scenario: Title null**
- Given: Item có `title = null`, `canonicalUrl = "https://reddit.com/r/flutter"`
- When: Card render
- Then: Hiển thị `"reddit.com"` làm title
- Reference: `lib/features/library/presentation/library_screen.dart:123` (`item.title ?? _extractDomain(item.canonicalUrl)`)

### REQ-7: Sort by savedAt descending
Items được sắp xếp theo `savedAt` giảm dần (mới nhất lên trên).

**Scenario: Sort order**
- Given: Items A (saved 1h ago), B (saved 5m ago), C (saved 2h ago)
- When: Library render
- Then: Thứ tự hiển thị: B → A → C
- Reference: Query `getAllSavedItems` dùng `OrderingTerm.desc(t.savedAt)`, `lib/core/database/database.dart:168-170`

### REQ-8: Edit title dialog
Quick Link Card có nút "Edit title" mở dialog cho user nhập title thủ công.

**Scenario: Mở dialog**
- Given: Quick Link Card hiển thị
- When: Bấm "Edit title"
- Then: Hiện AlertDialog với TextField, user nhập title → bấm Save → update DB
- Reference: `lib/features/library/presentation/library_screen.dart:191-216`

### REQ-9: Grid card layout
Grid view: 2 cột, `childAspectRatio = 0.75`, spacing 8px.

**Scenario: Grid layout**
- Given: Library ở Grid view
- When: Render
- Then: GridView.builder với `crossAxisCount: 2`, `childAspectRatio: 0.75`, `mainAxisSpacing: 8`, `crossAxisSpacing: 8`
- Reference: `lib/features/library/presentation/library_screen.dart:101-106`

### REQ-10: Favorite star
Items có `isFavorite = true` hiện star icon.

**Scenario: Item yêu thích**
- Given: Item có `isFavorite = true`
- When: Render trong List view
- Then: Hiện star icon (amber color) ở trailing
- Reference: `lib/features/library/presentation/library_screen.dart:169` (`item.isFavorite`)

## Cần làm rõ
- Thumbnail display đã được kết nối với DB qua `getThumbnailPathsForItems()` batch query. LibraryScreen preload thumbnails khi items thay đổi, dùng `Image.file()` cho local cached thumbnails. Fallback sang placeholder icon khi chưa có thumbnail.
- Offline banner và Faceted Filter được render trong cùng screen nhưng là capability riêng, xem spec `offline-banner` và `faceted-filter`.
