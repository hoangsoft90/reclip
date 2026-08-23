# quick-save

## Purpose
Lưu URL nhanh (< 300ms) với dedup logic: nếu URL đã tồn tại → cập nhật `lastAccessedAt`, nếu chưa → tạo bản ghi mới. Không fetch metadata, không hiện UI bổ sung.

## Requirements

### REQ-1: Quick Save flow mới (URL chưa tồn tại)
Flow: normalize → detect platform → check dedup → insert → return result.

**Scenario: Save URL mới**
- Given: DB không có item với canonical_url tương ứng
- When: Gọi `quickSave("https://reddit.com/r/flutter?utm_source=twitter")`
- Then:
  1. `UrlNormalizer.canonicalize()` → `"https://reddit.com/r/flutter"`
  2. `PlatformDetector.detect()` → `PlatformEnum.reddit`
  3. `findByCanonicalUrl()` → `null`
  4. Insert item mới với `metadataStatus = pending`, `savedAt = now`
  5. Trả về `SaveResult.savedNew(item)`
  6. Log `[QuickSave] New item saved in Xms`
- Reference: `lib/features/share_intent/quick_save_service.dart:24-40`

### REQ-2: Quick Save flow dedup (URL đã tồn tại)
Nếu canonical_url trùng → KHÔNG tạo bản ghi mới, chỉ cập nhật `lastAccessedAt`.

**Scenario: Save URL trùng**
- Given: DB có item với `canonical_url = "https://reddit.com/r/flutter"`
- When: Gọi `quickSave("https://reddit.com/r/flutter")`
- Then:
  1. `findByCanonicalUrl()` trả về item hiện có
  2. `touchLastAccessed(item.id)` cập nhật `last_accessed_at = now`
  3. Trả về `SaveResult.alreadyExists(item)`
  4. Log `[QuickSave] Already exists, touched in Xms`
- Reference: `lib/features/share_intent/quick_save_service.dart:42-56`

### REQ-3: Time-to-Save < 300ms
Toàn bộ quick save flow (normalize + detect + DB query + insert/update) phải hoàn thành trong < 300ms.

**Scenario: Đo thời gian**
- Given: URL hợp lệ
- When: Gọi `quickSave(url)`
- Then: Stopwatch đo thời gian, log ra console với milliseconds
- Reference: `lib/features/share_intent/quick_save_service.dart:22,40,52`

### REQ-4: SaveResult type
`SaveResult` có 2 type: `savedNew` (item mới) và `alreadyExists` (trùng). UI dùng phân biệt này để hiện Toast khác nhau.

**Scenario: savedNew**
- Given: URL mới
- When: Save thành công
- Then: `result.isNew == true`, `result.isDuplicate == false`
- Reference: `lib/features/share_intent/quick_save_service.dart:4-16`

**Scenario: alreadyExists**
- Given: URL đã tồn tại
- When: Dedup xảy ra
- Then: `result.isNew == false`, `result.isDuplicate == true`
- Reference: `lib/features/share_intent/quick_save_service.dart:4-16`

### REQ-5: Dedup bằng canonical_url (không phải original_url)
Hai URL khác nhau nhưng canonical giống nhau → dedup.

**Scenario: URL khác nhau nhưng canonical giống**
- Given: Item đã save với `original_url = "https://reddit.com/r/flutter?utm_source=twitter"`
- When: Save `"https://reddit.com/r/flutter?utm_medium=social"`
- Then: Canonical đều là `"https://reddit.com/r/flutter"` → dedup xảy ra
- Reference: Logic dedup dùng `findByCanonicalUrl` trên `canonical_url`, `lib/features/share_intent/quick_save_service.dart:24`

### REQ-6: Platform = other vẫn save thành công
URL không thuộc platform nào vẫn save được.

**Scenario: URL platform unknown**
- Given: URL `https://example.com/article`
- When: Gọi `quickSave(url)`
- Then: Item được insert với `platform = PlatformEnum.other`, trả về `SaveResult.savedNew`
- Reference: `lib/core/url/platform_detector.dart:35` (return other)

### REQ-7: saveAsNewEntry (Smart Save)
Muốn tạo bản ghi thứ 2 cho cùng 1 link → chỉ qua Smart Save flow, có nút "Save as new entry".

**Scenario: Smart Save tạo bản ghi mới**
- Given: Item đã tồn tại với canonical_url X
- When: User mở Smart Save → bấm "Save as new entry"
- Then: Tạo bản ghi mới với cùng canonical_url nhưng id khác
- Reference: Plan `plan1_final_v2.md` mục 2 (Smart Save flow). **Chưa implement code** — SmartSaveBottomSheet hiện tại chỉ có UI, nút Save gọi `Navigator.pop()` mà không insert DB.

## Cần làm rõ
- `SaveResult.item` chứa `SavedItem` object — nhưng trong flow dedup, item được re-fetch từ DB để có `lastAccessedAt` mới nhất. Có 1 extra DB query trong dedup case.
- Smart Save "Save as new entry" được mô tả trong plan nhưng **chưa implement** trong code — `SmartSaveBottomSheet` nút Save hiện tại chỉ dismiss sheet.
