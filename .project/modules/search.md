# Module: search

## Mục đích
Full-text search trên items đã lưu, dùng FTS5.

## Files
- `lib/features/search/presentation/search_screen.dart`

## Data Flow
```
TextField.onChanged → _search(query)
    → AppDatabase.searchSavedItems(query) → FTS5 MATCH
    → results → ListView.builder
```

## Local Storage
- SQLite FTS5: `saved_items_fts` virtual table
  - Indexed columns: `original_url`, `title`, `description`, `note`
  - Triggers auto-sync từ `saved_items`

## API Endpoints
Không có — search hoàn toàn local.

## Known Issues
- Không có debounce — mỗi keystroke tạo 1 DB query
- FTS5 input chưa sanitize (special chars `*`, `"`, `OR` có thể gây lỗi)
- "No results found" là hard-coded string, không dùng `AppStrings`
