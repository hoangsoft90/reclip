# ui-constants

## Purpose
Tập trung toàn bộ string hiển thị (`AppStrings`) và thông tin platform (`PlatformInfo`) tại 1 nơi, tránh hardcode trong widgets.

## Requirements

### REQ-1: AppStrings
Tất cả text hiển thị trong app đều lấy từ `AppStrings` class. KHÔNG hardcode string trong widgets.

**Categories:**
- Quick Save Toast: `savedToast`, `alreadySavedToast`, `addDetailsAction`, `viewAction`
- Badges: `badgeOnlineToView`, `badgeVideoUnavailableOffline`
- Open Original: `openOriginalButton`, `openOriginalFailedSnackbar`
- Metadata fallback: `metadataPendingTitle`, `metadataFailedTitle`, `metadataFailedSubtitle`
- Smart Save: `smartSaveTitle`, `collectionLabel`, `tagsLabel`, `whySavedLabel`, `noteLabel`, `saveButton`, `cancelButton`, `saveAsNewEntryButton`
- Why saved options: map `read_later → "Read later"`, etc.
- Empty states: `libraryEmptyTitle`, `libraryEmptySubtitle`
- Phase 2: `editTitleAction`, `quickLinkDomainPrefix`, `editTitleHint`, `editTitleSave`, `editTitleCancel`
- Reference: `lib/core/constants/app_strings.dart`

### REQ-2: PlatformInfo mapping
`PlatformInfo.info` map `PlatformEnum` → `{displayName, color, icon}`.

| Platform | displayName | color | icon |
|----------|------------|-------|------|
| reddit | "Reddit" | #FF4500 | Icons.forum |
| instagram | "Instagram" | #E4405F | Icons.camera_alt |
| tiktok | "TikTok" | #000000 | Icons.music_note |
| youtube | "YouTube" | #FF0000 | Icons.play_circle_fill |
| x | "X" | #1DA1F2 | Icons.close |
| other | "Web" | grey | Icons.language |

- Reference: `lib/core/constants/platforms.dart`

### REQ-3: Re-export enums
`platforms.dart` re-export enums từ `database.dart` để tiện import.

**Scenario: Import platforms.dart**
- Given: Widget cần dùng `PlatformEnum`
- When: Import `package:reclip/core/constants/platforms.dart`
- Then: Có thể dùng `PlatformEnum.reddit`, `MetadataStatusEnum.success`, etc. mà không cần import `database.dart` riêng
- Reference: `lib/core/constants/platforms.dart:3-5`

### REQ-4: Toast duration constant
`toastDurationMs = 2000` — duration cho auto-dismiss toast.

**Scenario: Toast auto-dismiss**
- Given: Toast hiển thị
- When: Timer chạy `toastDurationMs` milliseconds
- Then: Toast dismiss sau đúng 2 giây
- Reference: `lib/core/constants/app_strings.dart`

## Cần làm rõ
- Toàn bộ string tiếng Anh — chưa có i18n. Nếu muốn thêm tiếng Việt, cần chuyển sang `.arb` files + `intl` package.
- `PlatformEnum.x` dùng `Icons.close` — icon X (đóng) thay vì logo X/Twitter. Cần custom SVG icon nếu muốn logo chính thức.
- Why saved options là `Map<String, String>` — key là enum string, value là display text. Có thể type-safe hơn bằng enum riêng.
