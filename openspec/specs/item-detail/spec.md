# item-detail

## Purpose
Display full details of a saved item: tappable thumbnail, title, platform, author, content type badge, description, collections, tags, notes, why-saved, and actions (Open link, Edit all details).

## Requirements

### REQ-1: Tappable Thumbnail
Thumbnail is tappable — opens the original URL in browser.

**Scenario: Tap thumbnail**
- Given: Item detail screen with thumbnail
- When: User taps the thumbnail image
- Then: Opens `item.originalUrl` via `url_launcher` in external browser
- Reference: `_buildThumbnail()` wraps FutureBuilder in `GestureDetector(onTap: _openOriginal)`

**Scenario: Thumbnail with local file**
- Given: Item has thumbnail with `downloadStatus = done` and `localPath` set
- When: Render
- Then: `Image.file(io.File(thumb.localPath!))` with height 200, BoxFit.cover
- Reference: `_buildThumbnail()` — local file path check

**Scenario: Thumbnail with remote URL**
- Given: Item has thumbnail with `remoteUrl` set
- When: Render
- Then: `Image.network(thumb.remoteUrl!)` with loading indicator
- Reference: `_buildThumbnail()` — network URL fallback

**Scenario: No thumbnail**
- Given: Item has no thumbnail
- When: Render
- Then: Placeholder container with platform icon (size 64) and tinted background
- Reference: `_buildThumbnailPlaceholder()`

### REQ-2: Title + Platform Info
Display title (or domain if null), platform icon + name, and "Saved X ago".

**Scenario: Render header**
- Given: Item has `title = "Flutter Guide"`, `platform = reddit`, `savedAt = 1h ago`
- When: Render
- Then: Title "Flutter Guide" (fontSize 20, bold) + Row(reddit icon + "Reddit" + "Saved 1h ago")
- Reference: `item_detail_screen.dart` — title and platform row

### REQ-3: Content Type Badge
Item with `contentType != unknown` shows a small badge chip.

**Scenario: Video item**
- Given: Item has `contentType = video`
- When: Render
- Then: Chip with videocam icon + "VIDEO" (uppercase, fontSize 11, bold)
- Reference: Content type badge section

### REQ-4: Author Info
Item with `author != null` shows author row.

**Scenario: Item has author**
- Given: Item has `author = "u/flutter_dev"`
- When: Render
- Then: Row with person_outline icon + "u/flutter_dev"
- Reference: Author section

### REQ-5: Video Badge
Item with `contentType = video` shows "Video requires Internet" warning.

**Scenario: Video item**
- Given: Item has `contentType = video`
- When: Render
- Then: Orange container with videocam_off icon + "Video requires Internet"
- Reference: Video badge section

### REQ-6: Online Badge
All items show "⚠ Online to view" badge.

**Scenario: Always shown**
- Given: Any item
- When: Render
- Then: Orange container with wifi_off icon + "⚠ Online to view"
- Reference: Online badge section

### REQ-7: Description
Item with `description != null && description.isNotEmpty` shows description text.

**Scenario: Has description**
- Given: Item has `description = "A comprehensive guide..."`
- When: Render
- Then: Text with fontSize 14, height 1.5, color grey.shade700
- Reference: Description section

### REQ-8: Open Link Button
Compact button at top of detail section opens original URL.

**Scenario: Tap Open link**
- Given: Item detail screen
- When: User taps the "Open link" button
- Then: `url_launcher` opens `item.originalUrl` in external browser
- Reference: `_openOriginal()` method — uses `canLaunchUrl` + `launchUrl`

**Scenario: Button shows domain**
- Given: Item has `canonicalUrl = "https://reddit.com/r/flutter"`
- When: Render
- Then: Button shows "reddit.com" as label with open_in_new icon
- Reference: Open link button — `_extractDomain(_item.canonicalUrl)`

### REQ-9: Note + Why Saved Inline Display
When note or why-saved exists, show inline with tap to edit.

**Scenario: Has note or why-saved**
- Given: Item has `note = "Read this"` or `whySaved = "read_later"`
- When: Render
- Then: Blue container with "Edit note & why" header + chevron_right, note text (italic), why-saved chip
- Reference: `_hasNoteOrWhy()` check + GestureDetector wrapping inline display

**Scenario: Tap inline display**
- Given: Inline note display visible
- When: User taps the container
- Then: Opens SmartSaveBottomSheet for editing
- Reference: `onTap: _openEditSheet`

### REQ-10: Single Edit Button
One button that opens SmartSaveBottomSheet with all fields (note, why, collections, tags).

**Scenario: No existing data**
- Given: Item has no note, no why-saved
- When: Render
- Then: Button shows "Add note, why & details"
- Reference: `_hasNoteOrWhy() == false` → button label

**Scenario: Has existing data**
- Given: Item has note or why-saved
- When: Render
- Then: Button shows "Edit all details"
- Reference: `_hasNoteOrWhy() == true` → button label

**Scenario: Tap edit button**
- Given: Item detail screen
- When: User taps the edit button
- Then: `showModalBottomSheet` → `SmartSaveBottomSheet(item: _item, db: widget.db)` → reload item + collections + tags on dismiss
- Reference: `_openEditSheet()` method

### REQ-11: Collections Section
Display collections assigned to this item with add/remove.

**Scenario: Has collections**
- Given: Item belongs to collections ["Recipes", "Travel"]
- When: Render
- Then: Wrap with Chips showing collection names, each with delete icon
- Reference: `_buildCollectionsSection()`

**Scenario: No collections**
- Given: Item has no collections
- When: Render
- Then: "No collections yet" text
- Reference: `_buildCollectionsSection()`

**Scenario: Add collection**
- Given: User taps "+ Add" in collections section
- When: `_showAddCollectionSheet()` called
- Then: BottomSheet with collection picker (existing + inline create new)
- Reference: `_CollectionPickerSheet` widget

### REQ-12: Tags Section
Display tags assigned to this item with add/remove.

**Scenario: Has tags**
- Given: Item has tags ["tutorial", "flutter"]
- When: Render
- Then: Wrap with green Chips showing "#tutorial", "#flutter", each with delete icon
- Reference: `_buildTagsSection()`

**Scenario: Add tag**
- Given: User taps "+ Add" in tags section
- When: `_showAddTagDialog()` called
- Then: AlertDialog with TextField → user types tag name → Add
- Reference: `_showAddTagDialog()` method

### REQ-13: Favorite Toggle
Star icon in AppBar toggles `isFavorite`.

**Scenario: Toggle favorite on**
- Given: Item has `isFavorite = false`
- When: Tap star icon
- Then: `db.updateSavedItem(id: item.id, isFavorite: true)` → reload item → star turns amber
- Reference: AppBar actions — star IconButton

**Scenario: Toggle favorite off**
- Given: Item has `isFavorite = true`
- When: Tap star icon
- Then: `db.updateSavedItem(id: item.id, isFavorite: false)` → reload item → star turns border only
- Reference: AppBar actions — star IconButton

### REQ-14: Menu Actions
Three-dot menu with Edit, Archive, Delete.

**Scenario: Edit**
- Given: Tap ⋮ → "Edit all details"
- When: Selected
- Then: Opens SmartSaveBottomSheet
- Reference: `_handleMenuAction('edit')`

**Scenario: Archive/Unarchive**
- Given: Tap ⋮ → "Archive"
- When: Selected
- Then: Toggle `isArchived` → show SnackBar confirmation
- Reference: `_handleMenuAction('archive')`

**Scenario: Delete**
- Given: Tap ⋮ → "Delete"
- When: Selected
- Then: AlertDialog confirmation → `db.deleteItem(id)` → Navigator.pop
- Reference: `_handleMenuAction('delete')`

### REQ-15: PopScope Back Handling
Back button touches last accessed timestamp.

**Scenario: Pop screen**
- Given: User presses back
- When: `onPopInvokedWithResult` fires with `didPop = true`
- Then: `db.touchLastAccessed(item.id)` updates timestamp
- Reference: PopScope wrapper

## Cần làm rõ
- `edit_note_why_sheet.dart` đã bị xóa — tất cả edit giờ qua `SmartSaveBottomSheet`
- Thumbnail dùng `FutureBuilder<Thumbnail?>` query từ DB, hỗ trợ local file → network URL → placeholder
- `_openOriginal()` dùng `url_launcher` trực tiếp thay vì `OpenOriginalService`
