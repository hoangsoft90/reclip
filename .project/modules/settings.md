# Module: Settings

## Purpose
App settings screen with General, Storage, Data, About, and Developer sections.

## Files
| File | Purpose |
|------|---------|
| `lib/features/settings/domain/settings_provider.dart` | SettingsNotifier + AppSettings model + SharedPreferences |
| `lib/features/settings/presentation/settings_screen.dart` | Full settings UI |

## Key Behaviors
- **Grid view toggle:** Persists to SharedPreferences
- **Auto-download thumbnails:** Persists to SharedPreferences
- **Resurface frequency:** Never/Daily/Weekly/Monthly dialog
- **Storage stats:** Real-time thumbnail cache size + item count
- **Clear thumbnail cache:** Deletes files, shows toast
- **Clear all data:** Type "DELETE" to confirm, double confirm, wipes DB
- **Quick export:** Exports JSON + share via share_plus
- **Backup & Restore:** Navigates to BackupSettingsScreen
- **Rate this app:** Opens Play Store listing
- **Send feedback:** Opens email compose

## Access
Library → ⋮ menu → Settings

## Dependencies
- `shared_preferences` for persistence
- `url_launcher` for external links
- `share_plus` for quick export
- `package_info_plus` for version
- `backup_export_service.dart` for export
