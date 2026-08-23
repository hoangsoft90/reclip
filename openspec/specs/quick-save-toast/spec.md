# quick-save-toast

## Purpose
Toast overlay hiển thị ở底部 màn hình sau khi Quick Save, xác nhận "Saved ✓" hoặc "Already saved", tự ẩn sau 2 giây, có nút "Add details" mở Smart Save.

## Requirements

### REQ-1: Toast content theo loại save
Toast hiện text khác nhau tùy item mới hay trùng.

**Scenario: Item mới**
- Given: Item vừa được save lần đầu
- When: Toast render
- Then: Text "Saved ✓", background `Colors.green.shade700`, icon check_circle
- Reference: `lib/features/quick_save_toast/presentation/quick_save_toast.dart:72-75`

**Scenario: Item trùng**
- Given: Item đã tồn tại (dedup)
- When: Toast render
- Then: Text "Already saved", background `Colors.grey.shade800`, icon info_outline
- Reference: `lib/features/quick_save_toast/presentation/quick_save_toast.dart:72-75`

### REQ-2: Auto-dismiss sau 2 giây
Toast tự động biến mất sau `AppStrings.toastDurationMs` (2000ms).

**Scenario: Tự ẩn**
- Given: Toast hiển thị
- When: Đợi 2 giây
- Then: `_dismissTimer` trigger → `_controller.reverse()` → fade out → `onDismiss` callback
- Reference: `lib/features/quick_save_toast/presentation/quick_save_toast.dart:33-35`

### REQ-3: Fade animation
Toast có fade in/out animation 300ms.

**Scenario: Animation**
- Given: Toast mới hiển thị
- When: Render
- Then: `_controller.forward()` → fade in 300ms. Khi dismiss → `_controller.reverse()` → fade out 300ms
- Reference: `lib/features/quick_save_toast/presentation/quick_save_toast.dart:24-31`

### REQ-4: "Add details" button
Nút "Add details" mở SmartSaveBottomSheet, đồng thời hủy auto-dismiss timer.

**Scenario: Bấm Add details**
- Given: Toast đang hiển thị
- When: Bấm "Add details"
- Then: Hủy `_dismissTimer` → fade out toast → mở `SmartSaveBottomSheet(item: item)`
- Reference: `lib/features/quick_save_toast/presentation/quick_save_toast.dart:50-58`

### REQ-5: Overlay management
`QuickSaveToastOverlay.show()` quản lý 1 OverlayEntry duy nhất — toast mới thay thế toast cũ.

**Scenario: Toast mới thay toast cũ**
- Given: Toast A đang hiển thị
- When: Trigger toast B
- Then: `A.remove()` → tạo entry mới → `Overlay.of(context).insert(entry)`
- Reference: `lib/features/quick_save_toast/presentation/quick_save_toast.dart:107-129`

### REQ-6: Overlay fallback (try-catch)
Nếu `Overlay.of(context)` throw (overlay chưa sẵn sàng) → catch silently, không crash.

**Scenario: Overlay chưa sẵn sàng**
- Given: Context chưa có Overlay widget
- When: Gọi `QuickSaveToastOverlay.show(context, item, isNew)`
- Then: Catch exception → `entry.remove()` → no-op
- Reference: `lib/features/quick_save_toast/presentation/quick_save_toast.dart:126-129`

### REQ-7: Toast position
Toast hiển thị ở底部 màn hình, margin 16px horizontal, 8px vertical.

**Scenario: Vị trí**
- Given: Toast render
- When: Positioned widget
- Then: `bottom: 0`, `left: 0`, `right: 0`, Container margin `horizontal: 16, vertical: 8`
- Reference: `lib/features/quick_save_toast/presentation/quick_save_toast.dart:110-120`

### REQ-8: Trigger từ app.dart
`app.dart` lắng nghe `ShareIntentHandler.onShare` stream → query item từ DB → hiển thị Toast.

**Scenario: Share → Toast**
- Given: User share URL
- When: `handler.onShare` emit URL
- Then: Query DB theo canonicalUrl → kiểm tra `isNew` (savedAt gần đây < 2s) → gọi `QuickSaveToastOverlay.show(context, item, isNew)`
- Reference: `lib/app.dart:54-63`

## Cần làm rõ
- Toast dùng `Overlay.of(context)` — cần context có Overlay widget. Ở Phase 1-2, `MaterialApp` tự cung cấp Overlay. Nếu chuyển sang custom Navigator, cần đảm bảo context đúng.
- `isNew` check: `(now - item.savedAt) < 2000` — nếu user save item cách đây > 2 giây rồi trigger lại (vd: resume app), toast sẽ hiện "Already saved" thay vì "Saved ✓".
