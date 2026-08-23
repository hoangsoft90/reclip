# item-detail

## Purpose
Hiển thị chi tiết 1 saved item: thumbnail, title, platform, author, content type badge, description, note, why_saved badge, và các action (Open Original, Add details).

## Requirements

### REQ-1: Thumbnail / placeholder
Hiển thị thumbnail ảnh nếu có, nếu không → placeholder icon + màu theo platform.

**Scenario: Item có thumbnail**
- Given: Item có thumbnail trong thumbnails table
- When: Render detail screen
- Then: Hiển thị `Image.network(thumbnailUrl)` với height 200
- Reference: Container height 200 ở `lib/features/item_detail/presentation/item_detail_screen.dart:42-49`. **Hiện tại luôn hiện placeholder** vì `_getThumbnailLocalPath` chưa kết nối DB.

**Scenario: Item không có thumbnail**
- Given: Item không có thumbnail
- When: Render
- Then: Container màu `platformInfo.color.withOpacity(0.1)` + icon platform lớn (size 64)
- Reference: `lib/features/item_detail/presentation/item_detail_screen.dart:42-49`

### REQ-2: Title + platform info
Hiển thị title (hoặc domain nếu null), platform icon + name, và "Saved X ago".

**Scenario: Render header**
- Given: Item có `title = "Flutter Guide"`, `platform = reddit`, `savedAt = 1h ago`
- When: Render
- Then: Title "Flutter Guide" (fontSize 20, bold) + Row(reddit icon + "Reddit" + "Saved 1h ago")
- Reference: `lib/features/item_detail/presentation/item_detail_screen.dart:51-68`

### REQ-3: Content type badge
Item có `contentType != unknown` hiện badge chip nhỏ.

**Scenario: Video item**
- Given: Item có `contentType = video`
- When: Render
- Then: Hiện chip với icon videocam + "VIDEO" (uppercase, fontSize 11, bold)
- Reference: `lib/features/item_detail/presentation/item_detail_screen.dart:70-86`

### REQ-4: Author info
Item có `author != null` hiện dòng author.

**Scenario: Item có author**
- Given: Item có `author = "u/flutter_dev"`
- When: Render
- Then: Hiện Row với icon person_outline + "u/flutter_dev"
- Reference: `lib/features/item_detail/presentation/item_detail_screen.dart:88-99`

### REQ-5: Video badge "Video requires Internet"
Item có `contentType = video` hiện badge cảnh báo.

**Scenario: Video item**
- Given: Item có `contentType = video`
- When: Render
- Then: Hiện container cam với icon `videocam_off` + text "Video requires Internet"
- Reference: `lib/features/item_detail/presentation/item_detail_screen.dart:101-114`

### REQ-6: Online badge
Mọi item đều hiện badge "⚠ Online to view".

**Scenario: Luôn hiện**
- Given: Bất kỳ item nào
- When: Render
- Then: Hiện container cam với icon `wifi_off` + text "⚠ Online to view"
- Reference: `lib/features/item_detail/presentation/item_detail_screen.dart:116-128`

### REQ-7: Description
Item có `description != null && description.isNotEmpty` hiện text description.

**Scenario: Có description**
- Given: Item có `description = "A comprehensive guide..."`
- When: Render
- Then: Hiện text description với `fontSize 14`, `height 1.5`, color `grey.shade700`
- Reference: `lib/features/item_detail/presentation/item_detail_screen.dart:130-139`

### REQ-8: Note
Item có `note != null && note.isNotEmpty` hiện container xanh dương nhạt.

**Scenario: Có note**
- Given: Item có `note = "Read this later"`
- When: Render
- Then: Hiện Container `Colors.blue.shade50` với text italic `Colors.blue.shade800`
- Reference: `lib/features/item_detail/presentation/item_detail_screen.dart:141-152`

### REQ-9: Why saved badge
Item có `whySaved != null` hiện chip với label từ `AppStrings.whySavedOptions`.

**Scenario: Có why_saved**
- Given: Item có `whySaved = "read_later"`
- When: Render
- Then: Hiện Chip với text "Read later", background `Colors.purple.shade50`
- Reference: `lib/features/item_detail/presentation/item_detail_screen.dart:154-163`

### REQ-10: Open Original button
Nút "Open Original" mở URL gốc qua `OpenOriginalService`.

**Scenario: Bấm Open Original**
- Given: Item detail screen
- When: Bấm nút "Open Original"
- Then: Gọi `OpenOriginalService().open(item)` → mở browser. Nếu fail → hiện SnackBar error
- Reference: `lib/features/item_detail/presentation/item_detail_screen.dart:165-183`

### REQ-11: Add details button
Nút "Add details" mở SmartSaveBottomSheet.

**Scenario: Bấm Add details**
- Given: Item detail screen
- When: Bấm nút "Add details"
- Then: `showModalBottomSheet` → `SmartSaveBottomSheet(item: item)`
- Reference: `lib/features/item_detail/presentation/item_detail_screen.dart:185-199`

### REQ-12: Favorite toggle (chưa implement)
Nút star trên AppBar toggle `isFavorite`. Hiện tại chỉ render icon, onPressed rỗng.

**Scenario: Toggle favorite**
- Given: Item detail screen
- When: Bấm nút star
- Then: **Chưa implement** — `onPressed: () {}`
- Reference: `lib/features/item_detail/presentation/item_detail_screen.dart:22-29`

## Cần làm rõ
- Favorite toggle và Options menu đều có `onPressed: () {}` — chưa implement. Đây là Phase 3 work.
- Thumbnail display chưa hoạt động — `_getThumbnailLocalPath` không tồn tại trong ItemDetailScreen (trái với LibraryScreen). Placeholder luôn hiển thị.
- Cả "Online to view" và "Video requires Internet" badge đều hiện cùng lúc cho video items — có thể redundancy.
