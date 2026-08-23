# open-original

## Purpose
Mở URL gốc của saved item trong browser hoặc app gốc. Fallback: deep link → browser → error.

## Requirements

### REQ-1: Deep link attempt (Phase 1 = skip)
Thử mở deep link app gốc trước. Ở Phase 1, `_buildDeepLink` luôn trả về `null` → skip bước này.

**Scenario: Phase 1 — skip deep link**
- Given: Bất kỳ item nào
- When: Gọi `OpenOriginalService().open(item)`
- Then: `_buildDeepLink(item)` trả về `null` → bỏ qua bước deep link → chuyển sang browser
- Reference: `lib/features/item_detail/application/open_original_service.dart:12-16`

### REQ-2: Browser fallback
Mở `item.originalUrl` trong browser bằng `url_launcher`.

**Scenario: Browser mở thành công**
- Given: Item có `originalUrl = "https://reddit.com/r/flutter"`
- When: Gọi `open(item)`
- Then: `canLaunchUrl(uri)` = true → `launchUrl(uri, mode: LaunchMode.externalApplication)` → browser mở
- Reference: `lib/features/item_detail/application/open_original_service.dart:18-23`

**Scenario: Browser không mở được**
- Given: Device không có browser hoặc `canLaunchUrl` trả false
- When: Gọi `open(item)`
- Then: Trả về `false`
- Reference: `lib/features/item_detail/application/open_original_service.dart:21`

### REQ-3: Error fallback
Cả deep link và browser đều fail → trả `false`, UI hiện SnackBar error.

**Scenario: Cả hai fail**
- Given: `canLaunchUrl` = false cho cả deep link và browser
- When: Gọi `open(item)`
- Then: Trả về `false` → UI hiện SnackBar "Couldn't open the app or browser for this link."
- Reference: `lib/features/item_detail/application/open_original_service.dart:26-28`, `lib/features/item_detail/presentation/item_detail_screen.dart:175-181`

### REQ-4: Exception handling
Mọi exception từ `canLaunchUrl` / `launchUrl` được catch, trả `false`.

**Scenario: Exception xảy ra**
- Given: `launchUrl` throw exception
- When: Gọi `open(item)`
- Then: Catch exception, trả về `false`
- Reference: `lib/features/item_detail/application/open_original_service.dart:31-34`

### REQ-5:_queries intent trong AndroidManifest
Android 11+ yêu cầu `<queries>` để `url_launcher` tìm được browser app.

**Scenario: Android 11+ queries**
- Given: Device chạy Android 11+
- When: `url_launcher` gọi `canLaunchUrl(https://...)`
- Then: `<queries>` trong Manifest cho phép query `ACTION_VIEW` với scheme `https`
- Reference: `android/app/src/main/AndroidManifest.xml:28-35`

### REQ-6: Using externalApplication mode
Luôn dùng `LaunchMode.externalApplication` để mở ngoài app.

**Scenario: External launch**
- Given: User bấm "Open Original"
- When: `launchUrl` gọi
- Then: `mode: LaunchMode.externalApplication` — mở trong browser/app riêng, KHÔNG mở in-app WebView
- Reference: `lib/features/item_detail/application/open_original_service.dart:13,20`

## Cần làm rõ
- Deep link scheme cụ thể (`instagram://`, `tiktok://`, `reddit://`, etc.) chưa implement — `_buildDeepLink` trả về `null`. Đây là planned feature cho Phase 2+ nhưng chưa code.
- `item.originalUrl` được dùng (không phải `canonicalUrl`) — nghĩa là user mở đúng URL gốc他们 share, kể cả có tracking params.
