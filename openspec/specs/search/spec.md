# search

## Purpose
Full-text search trên toàn bộ items đã lưu, dùng FTS5 virtual table. Tìm kiếm trên original_url, title, description, note.

## Requirements

### REQ-1: Search input
SearchBar với `TextField` autofocus, hint "Search library…", nút clear khi có text.

**Scenario: Mở search screen**
- Given: User bấm tab Search
- When: Screen render
- Then: TextField autofocus, hiện hint "Search library…"
- Reference: `lib/features/search/presentation/search_screen.dart:36-44`

**Scenario: Xoá search query**
- Given: Đang search "flutter"
- When: Bấm nút clear (X icon)
- Then: TextField clear, results về rỗng, `_hasSearched = false`
- Reference: `lib/features/search/presentation/search_screen.dart:45-50`

### REQ-2: Real-time search
Search chạy mỗi khi user nhập text (debounce không được implement — chạy ngay `onChanged`).

**Scenario: Nhập text**
- Given: User nhập "flutter" vào search field
- When: Mỗi ký tự thay đổi
- Then: Gọi `_search(query)` → query DB → hiển thị kết quả
- Reference: `lib/features/search/presentation/search_screen.dart:38` (`onChanged: _search`)

### REQ-3: FTS5 query
Search dùng FTS5 MATCH query trên `saved_items_fts` table.

**Scenario: Search theo title**
- Given: DB có item `title = "Flutter Tutorial"`
- When: Search "Flutter"
- Then: FTS5 MATCH `"Flutter"` trả về item đó
- Reference: `lib/core/database/database.dart:176-184` (`saved_items_fts MATCH ?`)

**Scenario: Search theo URL**
- Given: DB có item `original_url = "https://reddit.com/r/flutter"`
- When: Search "reddit"
- Then: FTS5 tìm trong `original_url` column → trả về item
- Reference: FTS5 index includes `original_url`, `lib/core/database/database.dart:112`

### REQ-4: No results state
Khi search trả về rỗng, hiện text "No results found".

**Scenario: Không tìm thấy**
- Given: Search "xyznonexistent"
- When: Query trả về list rỗng
- Then: Hiện centered text "No results found" (color grey, fontSize 16)
- Reference: `lib/features/search/presentation/search_screen.dart:60-66`

### REQ-5: Search result items
Mỗi result hiển thị: platform icon (trailing 40x40) + title + platform name.

**Scenario: Render search result**
- Given: Search "flutter" trả về 3 items
- When: Render ListView.builder
- Then: Mỗi item là ListTile với leading = platform icon container, title = displayTitle, subtitle = platform name
- Reference: `lib/features/search/presentation/search_screen.dart:73-98`

### REQ-6: Tap result → Item Detail
User bấm vào search result → mở ItemDetailScreen.

**Scenario: Mở chi tiết**
- Given: Search results hiển thị
- When: Bấm vào item
- Then: `Navigator.push` → `ItemDetailScreen(item: item)`
- Reference: `lib/features/search/presentation/search_screen.dart:99-104`

### REQ-7: Display title fallback
Tương tự Library: khi `title = null`, hiện domain từ `canonical_url`.

**Scenario: Title null**
- Given: Item có `title = null`, `canonicalUrl = "https://youtube.com/watch?v=abc"`
- When: Render search result
- Then: Hiện `"youtube.com"` làm title
- Reference: `lib/features/search/presentation/search_screen.dart:76` (`item.title ?? _extractDomain(item.canonicalUrl)`)

## Cần làm rõ
- FTS5 MATCH query không.escape special characters. Nếu user nhập `*` hoặc `"` hoặc `OR`, query có thể fail hoặc trả kết quả bất ngờ. Không có input sanitization cho FTS5 syntax.
- Không có debounce — search chạy ngay mỗi ký tự thay đổi. Với library lớn, mỗi keystroke tạo 1 DB query. Ở quy mô MVP (< 500 items), điều này chấp nhận được.
- "No results found" là string hard-coded trong widget, KHÔNG dùng `AppStrings`.
