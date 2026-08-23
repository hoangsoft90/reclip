# local-database

## Purpose
Lưu trữ tất cả dữ liệu app (saved items, collections, tags, thumbnails) trên SQLite cục bộ bằng Drift ORM, kèm FTS5 full-text search.

## Requirements

### REQ-1: Schema 6 bảng
Database gồm 6 bảng chính: `saved_items`, `collections`, `item_collections`, `tags`, `item_tags`, `thumbnails`.

**Scenario: Tạo database mới**
- Given: App chạy lần đầu (chưa có file `reclip.db`)
- When: `AppDatabase()` được khởi tạo
- Then: Tạo file `reclip.db` trong app documents directory, tạo tất cả 6 bảng + FTS5 virtual table + 3 triggers
- Reference: `lib/core/database/database.dart:107-139`, `lib/core/database/database.dart:207-213`

### REQ-2: Bảng saved_items
Bảng chính lưu thông tin item đã save.

| Column | Type | Constraints |
|--------|------|------------|
| id | TEXT | PRIMARY KEY |
| original_url | TEXT | NOT NULL |
| canonical_url | TEXT | NOT NULL |
| platform | TEXT | ENUM (reddit/instagram/tiktok/youtube/x/other) |
| content_type | TEXT | ENUM, DEFAULT 'unknown' |
| metadata_status | TEXT | ENUM, DEFAULT 'pending' |
| title | TEXT | NULLABLE |
| description | TEXT | NULLABLE |
| author | TEXT | NULLABLE |
| author_url | TEXT | NULLABLE |
| saved_at | INTEGER | NOT NULL (epoch millis) |
| last_accessed_at | INTEGER | NULLABLE |
| is_favorite | BOOLEAN | DEFAULT false |
| is_archived | BOOLEAN | DEFAULT false |
| note | TEXT | NULLABLE |
| why_saved | TEXT | NULLABLE |
| link_status | TEXT | ENUM, DEFAULT 'unknown' |
| last_checked_at | INTEGER | NULLABLE |

**Scenario: Insert saved item**
- Given: Dữ liệu `{id: "abc", originalUrl: "...", canonicalUrl: "...", platform: reddit}`
- When: Gọi `db.insertSavedItem(...)`
- Then: Item được insert với `savedAt = DateTime.now().millisecondsSinceEpoch`, `metadataStatus = pending`, `contentType = unknown`
- Reference: `lib/core/database/database.dart:143-159`

### REQ-3: Dedup qua canonical_url (không UNIQUE constraint)
Không có UNIQUE constraint trên `canonical_url`. Dedup xử lý ở tầng service bằng `findByCanonicalUrl`.

**Scenario: Tìm item theo canonical_url**
- Given: DB có item với `canonical_url = "https://reddit.com/r/flutter"`
- When: Gọi `db.findByCanonicalUrl("https://reddit.com/r/flutter")`
- Then: Trả về item đó
- Reference: `lib/core/database/database.dart:161-165`

### REQ-4: FTS5 full-text search
Virtual table `saved_items_fts` index: `original_url`, `title`, `description`, `note`.

**Scenario: Search theo title**
- Given: DB có item với `title = "Flutter Tutorial"`
- When: Gọi `db.searchSavedItems("Flutter")`
- Then: Trả về item đó
- Reference: `lib/core/database/database.dart:176-184`

**Scenario: Search trả rỗng**
- Given: DB không có item nào match query
- When: Gọi `db.searchSavedItems("nonexistent")`
- Then: Trả về list rỗng
- Reference: `lib/core/database/database.dart:179`

### REQ-5: Triggers đồng bộ FTS5
3 triggers tự động đồng bộ khi insert/update/delete `saved_items`.

**Trigger INSERT:** `saved_items_ai` — thêm dòng vào FTS5
**Trigger UPDATE:** `saved_items_au` — cập nhật FTS5
**Trigger DELETE:** `saved_items_ad` — xóa khỏi FTS5
- Reference: `lib/core/database/database.dart:117-138`

### REQ-6: Many-to-many relations
- `item_collections`: link items ↔ collections (PRIMARY KEY: item_id + collection_id)
- `item_tags`: link items ↔ tags (PRIMARY KEY: item_id + tag_id)
- Cả hai có `ON DELETE CASCADE`

**Scenario: Thêm item vào collection**
- Given: Item "abc" và collection "xyz" tồn tại
- When: Gọi `db.addToCollection("abc", "xyz")`
- Then: Dòng mới trong `item_collections` với `item_id="abc"`, `collection_id="xyz"`
- Reference: `lib/core/database/database.dart:189-200`

### REQ-7: Tag management (get-or-create)
`getOrCreateTag` tìm tag theo name, nếu chưa có thì tạo mới.

**Scenario: Tag đã tồn tại**
- Given: DB có tag `name = "flutter"`
- When: Gọi `db.getOrCreateTag("flutter")`
- Then: Trả về tag hiện có, KHÔNG tạo tag mới
- Reference: `lib/core/database/database.dart:218-223`

**Scenario: Tag chưa tồn tại**
- Given: DB không có tag nào tên `"flutter"`
- When: Gọi `db.getOrCreateTag("flutter")`
- Then: Tạo tag mới với `id = DateTime.now().millisecondsSinceEpoch.toString()`
- Reference: `lib/core/database/database.dart:224-226`

### REQ-8: Thumbnails DAO
Các method quản lý thumbnails: insert, find, update status/result, clear local path, sum size.

**Scenario: Insert thumbnail**
- Given: `{id: "t1", itemId: "abc", remoteUrl: "https://..."}`
- When: Gọi `db.insertThumbnail(...)`
- Then: Thumbnail được insert với `downloadStatus = pending`
- Reference: `lib/core/database/database.dart:250-262`

**Scenario: Sum size bytes**
- Given: DB có 3 thumbnails done: 100KB, 200KB, 50KB
- When: Gọi `db.sumThumbnailSizeBytes()`
- Then: Trả về `363520` (bytes)
- Reference: `lib/core/database/database.dart:285-290`

### REQ-9: Migration skeleton
`onUpgrade` được định nghĩa nhưng rỗng — sẵn sàng cho migration tương lai.

**Scenario: Schema version**
- Given: Database hiện tại
- When: Đọc `schemaVersion`
- Then: Trả về `1`
- Reference: `lib/core/database/database.dart:104`

## Cần làm rõ
- `Tag.id` dùng `DateTime.now().millisecondsSinceEpoch.toString()` thay vì UUID — có thể trùng nếu tạo 2 tag cùng millisecond. Đây là known limitation, không có logic retry hay UUID cho tags.
- `Collections.parentId` và `isSmart`/`smart_rule` columns tồn tại trong schema nhưng chưa có code sử dụng (Phase 4+).
- `lastCheckedAt` và `linkStatus` trên `saved_items` chưa có code cập nhật (Phase 3+ — on-demand link check).
