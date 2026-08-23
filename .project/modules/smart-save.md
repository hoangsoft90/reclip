# Module: smart-save

## Mục đích
BottomSheet cho user thêm chi tiết: note, why_saved. Collection/Tags là placeholder.

## Files
- `lib/features/smart_save/presentation/smart_save_bottom_sheet.dart`

## Data Flow
```
SmartSaveBottomSheet(item, db)
    ├── Display: URL preview
    ├── Input: Note (TextField, pre-filled)
    ├── Input: Why saved (5 ChoiceChips)
    ├── Placeholder: Collection, Tags
    └── Save → db.updateSavedItem(id, note, whySaved) → Navigator.pop()
```

## Local Storage
- SQLite: `saved_items` (UPDATE note, whySaved)

## Known Issues
- Collection và Tags chưa implement logic lưu — chỉ là placeholder UI
- BottomSheet mở từ 2 nơi: Item Detail + QuickSaveToast
