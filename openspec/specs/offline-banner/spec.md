# offline-banner

## Purpose
Hiển thị banner cảnh báo khi thiết bị mất kết nối internet, ẩn tự động khi có lại kết nối.

## Requirements

### REQ-1: OfflineBanner widget
Widget hiển thị icon wifi_off + text "⚠ Online to view" trên nền màu cam.

**Scenario: Render offline banner**
- Given: Device offline
- When: Library screen render
- Then: Hiện Container với `Colors.orange.shade50`, chứa Row với icon `Icons.wifi_off` (size 16, color orange) + text "⚠ Online to view"
- Reference: `lib/features/library/presentation/widgets/offline_banner.dart`

### REQ-2: Hiện/ẩn theo ConnectivityService
Banner hiện khi `isOnline == false`, ẩn khi `isOnline == true`.

**Scenario: Device offline → banner hiện**
- Given: Device mất Wi-Fi và mobile data
- When: `ConnectivityService.onlineStatusStream` emit `false`
- Then: `_isOnline = false`, banner được render
- Reference: `lib/features/library/presentation/library_screen.dart:31-34`

**Scenario: Device online → banner ẩn**
- Given: Device có kết nối
- When: `ConnectivityService.onlineStatusStream` emit `true`
- Then: `_isOnline = true`, banner KHÔNG render
- Reference: `lib/features/library/presentation/library_screen.dart:66` (`if (!_isOnline)`)

### REQ-3: Kiểm tra online khi app khởi động
`ConnectivityService.isOnline` được gọi 1 lần khi `initState` để set trạng thái ban đầu.

**Scenario: App khởi động offline**
- Given: Device offline
- When: Library screen initState
- Then: `_connectivityService.isOnline.then((online) => setState(() => _isOnline = online))` → banner hiện ngay
- Reference: `lib/features/library/presentation/library_screen.dart:33-35`

### REQ-4: ConnectivityService implementation
Dùng `connectivity_plus` package. Stream `onConnectivityChanged` map thành `bool` (true = online, false = offline).

**Scenario: Connectivity check**
- Given: Device có Wi-Fi
- When: Gọi `_connectivity.checkConnectivity()`
- Then: Kết quả không chứa `ConnectivityResult.none` → `isOnline = true`
- Reference: `lib/core/network/connectivity_service.dart:10-12`

### REQ-5: Vị trí trong UI
Banner nằm phía trên FacetFilterBar, phía dưới AppBar.

**Scenario: Layout**
- Given: Library screen
- When: Render Column
- Then: Thứ tự: OfflineBanner (nếu offline) → FacetFilterBar → Items list
- Reference: `lib/features/library/presentation/library_screen.dart:66-72`

## Cần làm rõ
- `connectivity_plus` chỉ kiểm tra device có kết nối mạng hay không — KHÔNG kiểm tra internet thực sự có hoạt động không (device có thể connect Wi-Fi nhưng Wi-Fi không có internet). Ở Phase 2-3, điều này chấp nhận được.
- Banner dùng string `AppStrings.badgeOnlineToView` ("⚠ Online to view") — cùng string dùng trong Item Detail Screen cho badge online. Ý nghĩa: "Cần online để xem nội dung gốc".
