# smart-save

## Purpose
BottomSheet cho user thêm chi tiết vào saved item: note, why_saved. Collection và Tags hiện là placeholder (Phase 2+).

## Requirements

### REQ-1: BottomSheet UI
DraggableScrollableSheet với handle bar, initial size 0.6, max 0.9.

**Scenario: Mở Smart Save**
- Given: Item detail screen
- When: Bấm "Add details" hoặc nút "Add details" trên Toast
- Then: `showModalBottomSheet(isScrollControlled: true)` → DraggableScrollableSheet với ListView
- Reference: `lib/features/smart_save/presentation/smart_save_bottom_sheet.dart`

### REQ-2: URL preview
Hiển thị `item.originalUrl` trong container xám nhạt.

**Scenario: Render URL**
- Given: Smart Save sheet mở
- When: Render
- Then: Hiện text URL với `fontSize 12`, `color grey.shade600`, maxLines 2
- Reference: `lib/features/smart_save/presentation/smart_save_bottom_sheet.dart:55-63`

### REQ-3: Note input
TextField multi-line (maxLines 3) với hint "Why did you save this?", pre-fill từ `item.note`.

**Scenario: Nhập note**
- Given: Sheet mở, item chưa có note
- When: Nhập "Read this later" vào note field
- Then: `_noteController.text = "Read this later"`
- Reference: `lib/features/smart_save/presentation/smart_save_bottom_sheet.dart:30,83-92`

**Scenario: Edit note có sẵn**
- Given: Item có `note = "Old note"`
- When: Sheet mở
- Then: TextField pre-filled với "Old note"
- Reference: `lib/features/smart_save/presentation/smart_save_bottom_sheet.dart:30`

### REQ-4: Why saved picker
5 ChoiceChips: Read later, Try this, Learn this, Inspiration, Just interesting.

**Scenario: Chọn why_saved**
- Given: Sheet mở
- When: Bấm chip "Read later"
- Then: `_selectedWhySaved = "read_later"`, chip được selected
- Reference: `lib/features/smart_save/presentation/smart_save_bottom_sheet.dart:70-82`

**Scenario: Bỏ chọn**
- Given: Đã chọn "Read later"
- When: Bấm lại chip "Read later"
- Then: `_selectedWhySaved = null`
- Reference: `lib/features/smart_save/presentation/smart_save_bottom_sheet.dart:75-78`

### REQ-5: Collection placeholder
Hiển thị text "No collection selected" — chưa implement logic.

**Scenario: Collection section**
- Given: Sheet mở
- When: Render
- Then: Hiện text "No collection selected" trong container border
- Reference: `lib/features/smart_save/presentation/smart_save_bottom_sheet.dart:64-69`

### REQ-6: Tags placeholder
Hiển thị text "No tags added" — chưa implement logic.

**Scenario: Tags section**
- Given: Sheet mở
- When: Render
- Then: Hiện text "No tags added" trong container border
- Reference: `lib/features/smart_save/presentation/smart_save_bottom_sheet.dart:71-76`

### REQ-7: Save button
Nút "Save" → update note + whySaved vào DB → dismiss sheet.

**Scenario: Bấm Save**
- Given: Sheet mở, user đã nhập note "Read later" và chọn whySaved = "read_later"
- When: Bấm nút "Save"
- Then: Gọi `db.updateSavedItem(id: item.id, note: "Read later", whySaved: "read_later")` → dismiss sheet
- Reference: `lib/features/smart_save/presentation/smart_save_bottom_sheet.dart:155-161`

### REQ-8: Cancel button
Nút "Cancel" → dismiss sheet.

**Scenario: Bấm Cancel**
- Given: Sheet mở
- When: Bấm nút "Cancel"
- Then: `Navigator.of(context).pop()`
- Reference: `lib/features/smart_save/presentation/smart_save_bottom_sheet.dart:106-114`

## Cần làm rõ
- **Collection và Tags** vẫn là placeholder — chưa implement logic lưu vào DB. Save button chỉ lưu note + whySaved.
- Smart Save sheet có thể được mở từ 2 nơi: (1) Item Detail Screen nút "Add details", (2) QuickSaveToastOverlay nút "Add details". Cả hai đều truyền `SavedItem` + `AppDatabase` vào sheet.
- `SmartSaveBottomSheet` nhận `AppDatabase db` param — các call sites phải truyền db vào.
