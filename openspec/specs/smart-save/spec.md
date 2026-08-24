# smart-save

## Purpose
BottomSheet for adding/editing details on a saved item: note, why_saved, collections, and tags. Fully functional collection/tag management with inline create-new.

## Requirements

### REQ-1: BottomSheet UI
Scaffold with resizeToAvoidBottomInset inside DraggableScrollableSheet.

**Scenario: Open Smart Save**
- Given: Item detail screen
- When: Tap "Edit all details" or "Add note, why & details"
- Then: `showModalBottomSheet(isScrollControlled: true)` → DraggableScrollableSheet with Scaffold → ListView
- Reference: `smart_save_bottom_sheet.dart` — Scaffold wrapper for keyboard handling

### REQ-2: URL Preview
Display `item.originalUrl` in a light gray container.

**Scenario: Render URL**
- Given: Smart Save sheet open
- When: Render
- Then: Text URL with fontSize 12, color grey.shade600, maxLines 2
- Reference: URL preview container

### REQ-3: Collection Section
Show assigned collections with add/remove and inline create-new.

**Scenario: Has collections**
- Given: Item belongs to collections ["Recipes", "Travel"]
- When: Render collection section
- Then: Wrap with Chips showing names, each with delete icon
- Reference: `_buildCollectionWidget()` — selected collections display

**Scenario: Add to collection**
- Given: User taps "Add to collection"
- When: `_showAddCollectionSheet()` called
- Then: BottomSheet with collection picker + inline "Create new collection" text field
- Reference: `_CollectionPickerSheet` widget

**Scenario: Create new collection inline**
- Given: Collection picker open
- When: Type "New Collection" + tap checkmark
- Then: Collection created in DB, list refreshes, sheet stays open for selection
- Reference: `_createCollection()` — refresh list, DON'T close sheet

**Scenario: Select existing collection**
- Given: Collection picker with list
- When: Tap a collection name
- Then: Collection added to `_selectedCollections`, sheet closes
- Reference: `onSelected` callback in `_CollectionPickerSheet`

### REQ-4: Tags Section
Show assigned tags with add/remove.

**Scenario: Has tags**
- Given: Item has tags ["tutorial", "flutter"]
- When: Render tags section
- Then: Wrap with green Chips showing "#tutorial", "#flutter", each with delete
- Reference: `_buildTagsWidget()` — selected tags display

**Scenario: Add tag**
- Given: User taps "Add tag"
- When: `_showAddTagDialog()` called
- Then: AlertDialog with TextField → type tag name → Add
- Reference: `_showAddTagDialog()` method

**Scenario: Tag already exists**
- Given: Tag "flutter" already on item
- When: Try to add "flutter" again
- Then: Tag not duplicated (checked via `_selectedTags.any((t) => t.name == result)`)
- Reference: Duplicate check in `_showAddTagDialog()`

### REQ-5: Note + Why Saved (SharedNoteWhyFields)
Shared widget with TextField for note and ChoiceChips for why-saved.

**Scenario: Note input**
- Given: Sheet open, item has no note
- When: Type "Read this later"
- Then: `_note = "Read this later"`
- Reference: `SharedNoteWhyFields` — onNoteChanged callback

**Scenario: Pre-fill existing note**
- Given: Item has `note = "Old note"`
- When: Sheet opens
- Then: TextField pre-filled with "Old note"
- Reference: `SharedNoteWhyFields` — initialNote param

**Scenario: Why saved selection**
- Given: Sheet open
- When: Tap "Read later" chip
- Then: `_selectedWhySaved = "read_later"`, chip highlighted
- Reference: `SharedNoteWhyFields` — onWhySavedChanged callback

### REQ-6: Save Button with Loading State
Save button with double-tap guard and loading spinner. ALWAYS closes sheet (even on error).

**Scenario: Normal save**
- Given: Sheet open with changes
- When: Tap "Save"
- Then: `_isSaving = true` → spinner → DB updates (note, why, collections, tags) → `Navigator.pop()` in finally block
- Reference: `_save()` method — try/finally ensures pop always runs

**Scenario: Double-tap guard**
- Given: Save in progress
- When: Tap "Save" again
- Then: `_isSaving` check returns early, no duplicate save
- Reference: `if (_isSaving) return;` at start of `_save()`

**Scenario: Save error**
- Given: DB operation throws
- When: Save attempted
- Then: Error caught in try block, `Navigator.pop()` still runs in finally
- Reference: `catch (e) { debugPrint(...); } finally { pop(); }`

### REQ-7: Cancel Button
Cancel button dismisses sheet.

**Scenario: Tap Cancel**
- Given: Sheet open
- When: Tap "Cancel"
- Then: `Navigator.of(context).pop()`
- Reference: Cancel button — TextButton

### REQ-8: Save Syncs Collections + Tags
Save syncs all changes: removes unselected, adds selected.

**Scenario: Save with collection changes**
- Given: Item was in ["Recipes"], user removed "Recipes" and added "Travel"
- When: Save
- Then: `removeCollectionFromItem("Recipes")` + `addToCollection("Travel")`
- Reference: `_save()` — sync collections logic

**Scenario: Save with tag changes**
- Given: Item had tag "old", user removed it and added "new"
- When: Save
- Then: `removeTagFromItem("old")` + `addTagToItem("new")`
- Reference: `_save()` — sync tags logic

## Cần làm rõ
- Smart Save sheet is opened from 2 places: (1) Item Detail Screen edit button, (2) QuickSaveToastOverlay
- Both pass `SavedItem` + `AppDatabase` to the sheet
- Collection picker uses `_CollectionPickerSheet` widget (defined in same file) — reusable inline create + select pattern
- `Scaffold(resizeToAvoidBottomInset: true)` wrapping fixes keyboard pushing Save button out of viewport
