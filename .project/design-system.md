# Design System & UI Components

## Theme

```dart
ThemeData(
  colorSchemeSeed: Colors.black,    // Primary color: đen
  useMaterial3: true,                // Material 3
  brightness: Brightness.light,      // Light theme only
)
```

## Platform Colors

| Platform | Color | Hex |
|----------|-------|-----|
| Reddit | Orange Red | `#FF4500` |
| Instagram | Pink | `#E4405F` |
| TikTok | Black | `#000000` |
| YouTube | Red | `#FF0000` |
| X (Twitter) | Blue | `#1DA1F2` |
| Other/Web | Grey | `Colors.grey` |

## Typography
Không custom font — dùng default Material 3 font (Roboto trên Android).

| Usage | Size | Weight |
|-------|------|--------|
| Screen title (AppBar) | 20 | bold |
| Card title | 13 | w500 |
| Card subtitle | 11-12 | normal |
| Detail title | 20 | bold |
| Detail body | 14 | normal |
| Badge/Chip text | 11-12 | w600 |
| Toast text | 14 | w500 |

## Spacing
Không có spacing system cố định — dùng `SizedBox` với giá trị tuỳ ý:

| Context | Spacing |
|---------|---------|
| Card padding | 8px |
| Screen padding | 16px |
| Between sections | 12-16px |
| Between chips | 8px |
| Toast margin | horizontal 16, vertical 8 |

## Shared Widgets

### QuickSaveToast
- Toast overlay ở底部 màn hình
- Background: green (new) / grey (already saved)
- Auto-dismiss sau 2 giây
- Nút "Add details" mở SmartSaveBottomSheet

### QuickLinkCard
- Card cho items có metadata pending/failed
- Icon link thay vì thumbnail
- Domain name làm title
- Nút "Edit title" mở dialog

### FacetFilterBar
- Horizontal scrollable chips
- Filter: platform, content type, has note, why saved
- Nút "Clear" hiện khi có filter active

### OfflineBanner
- Orange banner "⚠ Online to view"
- Hiện khi `ConnectivityService.isOnline == false`

### SmartSaveBottomSheet
- DraggableScrollableSheet (0.6 → 0.9)
- Handle bar + URL preview + Note input + Why saved chips
- Collection/Tags placeholder

## Color Usage

| Element | Color |
|---------|-------|
| AppBar background | White (default) |
| Bottom Nav | Black seed (Material 3) |
| Favorite star | Amber |
| Note container | Blue shade 50 |
| Why saved chip | Purple shade 50 |
| Video badge | Orange shade 50 |
| Online badge | Orange shade 50 |
| Error/SnackBar | Default Material |
