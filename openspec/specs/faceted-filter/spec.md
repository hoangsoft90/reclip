# faceted-filter

## Purpose
Lọc items trong Library theo nhiều tiêu chí kết hợp: platform, content type, ngày lưu, có note, why_saved. Chạy hoàn toàn local trên danh sách items từ DB.

## Requirements

### REQ-1: Filter theo platform
User chọn 1 hoặc nhiều platform → chỉ hiện items thuộc platform đã chọn.

**Scenario: Chọn Reddit**
- Given: Library có items Reddit, YouTube, TikTok
- When: Bấm chip "Reddit" trong FacetFilterBar
- Then: Chỉ hiện items Reddit
- Reference: `lib/features/library/application/facet_filter_controller.dart:24-31`, `lib/features/library/presentation/widgets/facet_filter_bar.dart:30-44`

**Scenario: Chọn nhiều platform**
- Given: Chọn Reddit + YouTube
- When: Filter applied
- Then: Hiện items Reddit HOẶC YouTube (OR logic)
- Reference: `_state.platforms.contains(item.platform)` — set contains = OR

### REQ-2: Filter theo content type
User chọn video, image, hoặc text.

**Scenario: Chọn video**
- Given: Library có items video, image, text
- When: Bấm chip "video"
- Then: Chỉ hiện items có `contentType = video`
- Reference: `lib/features/library/application/facet_filter_controller.dart:33-40`

### REQ-3: Filter theo "Has note"
Chip "Has note" toggle: null (không lọc) → true (có note) → null.

**Scenario: Bật Has note**
- Given: Library có items có note và không có note
- When: Bấm chip "Has note"
- Then: Chỉ hiện items có `note != null && note.isNotEmpty`
- Reference: `lib/features/library/application/facet_filter_controller.dart:48-50`, filter logic line 84-89

### REQ-4: Filter theo "Why saved"
User chọn 1 trong 5 options: read_later, try_this, learn_this, inspiration, just_interesting.

**Scenario: Chọn "Read later"**
- Given: Library có items với nhiều why_saved values
- When: Mở bottom sheet → chọn "Read later"
- Then: Chỉ hiện items có `whySaved == "read_later"`
- Reference: `lib/features/library/application/facet_filter_controller.dart:52-54`, `facet_filter_bar.dart:82-100`

### REQ-5: Filter theo ngày lưu (date range)
User chọn date range → chỉ hiện items saved trong khoảng đó.

**Scenario: Chọn range**
- Given: Library có items từ nhiều ngày
- When: Set `savedDateRange = DateTimeRange(start: ..., end: ...)`
- Then: Chỉ hiện items có `savedAt` nằm trong range (so sánh epoch millis)
- Reference: `lib/features/library/application/facet_filter_controller.dart:96-102`

### REQ-6: Kết hợp nhiều filter (AND logic)
Nhiều filter cùng lúc = AND giữa các nhóm, OR trong cùng nhóm.

**Scenario: Platform + Has note**
- Given: Chọn platform = TikTok, Has note = true
- When: Filter applied
- Then: Chỉ hiện items TikTok VÀ có note
- Reference: Filter logic `lib/features/library/application/facet_filter_controller.dart:78-105`

### REQ-7: Clear all filters
Nút "Clear" hiện khi có filter active, bấm → xóa tất cả filter.

**Scenario: Clear**
- Given: Đang filter Reddit + Has note
- When: Bấm chip "Clear"
- Then: Tất cả filter bị xóa, hiện lại toàn bộ items
- Reference: `lib/features/library/application/facet_filter_controller.dart:60-63`, `facet_filter_bar.dart:70-76`

### REQ-8: No match state
Khi filter trả về 0 results → hiện text "No items match filter".

**Scenario: Không có kết quả**
- Given: Library có items nhưng filter không match cái nào
- When: Filter applied
- Then: Hiện "No items match filter" thay vì list rỗng
- Reference: `lib/features/library/presentation/library_screen.dart:72-77`

### REQ-9: FacetFilterBar UI
Thanh filter ngang phía trên Library, có thể scroll ngang.

**Scenario: Render filter bar**
- Given: Library screen
- When: Render
- Then: SizedBox height 48, ListView horizontal chứa các FilterChip (platform, content type, has note) + ActionChip (why saved, clear)
- Reference: `lib/features/library/presentation/widgets/facet_filter_bar.dart:17-78`

## Cần làm rõ
- Filter chạy client-side trên danh sách items từ `StreamBuilder` — KHÔNG query DB. Nghĩa là tất cả items phải được load vào memory trước khi filter. Nếu library rất lớn (hàng nghìn items), performance có thể chậm. Ở Phase 2-3 với quy mô MVP, điều này chấp nhận được.
- Date range picker hiện chưa có UI — `setDateRange` có method nhưng FacetFilterBar chưa render date picker chip. Cần thêm UI nếu muốn dùng tính năng này.
