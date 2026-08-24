# settings

## Purpose
App settings screen with General, Storage, Data, About, and Developer sections. Persisted via SharedPreferences.

## Requirements

### REQ-1: Settings Provider
SettingsNotifier wraps SharedPreferences for persistent settings.

**Scenario: Load settings**
- Given: App starts
- When: `settingsProvider` initialized
- Then: Reads SharedPreferences for `gridView`, `autoDownloadThumbnails`, `resurfaceFrequency`
- Reference: `settings/domain/settings_provider.dart` — `AppSettings` model + `SettingsNotifier`

**Scenario: Toggle grid view**
- Given: Settings screen
- When: Toggle "Grid view by default" switch
- Then: `settingsProvider.notifier.toggleGridView()` → persists to SharedPreferences
- Reference: `SettingsNotifier.toggleGridView()`

**Scenario: Toggle auto-download**
- Given: Settings screen
- When: Toggle "Auto-download thumbnails" switch
- Then: `settingsProvider.notifier.toggleAutoDownload()` → persists to SharedPreferences
- Reference: `SettingsNotifier.toggleAutoDownload()`

**Scenario: Change resurface frequency**
- Given: Settings screen
- When: Select frequency from dialog (Never/Daily/Weekly/Monthly)
- Then: `settingsProvider.notifier.setResurfaceFrequency(value)` → persists
- Reference: `SettingsNotifier.setResurfaceFrequency()`

### REQ-2: General Section
Toggle switches for grid view, auto-download, and resurface frequency picker.

**Scenario: Render general section**
- Given: Settings screen
- When: Render
- Then: Section "📱 General" with SwitchListTile items + frequency dialog
- Reference: Settings screen — General section

### REQ-3: Storage Section
Display thumbnail cache size, total items count, clear actions.

**Scenario: Display stats**
- Given: Settings screen
- When: Load stats
- Then: Show "X thumbnails cached (Y KB)" and "Z total items"
- Reference: `_loadStats()` method — queries DB for counts + file sizes

**Scenario: Clear thumbnail cache**
- Given: User taps "Clear thumbnail cache"
- When: Confirm dialog → OK
- Then: Delete all thumbnail files from app directory, refresh stats
- Reference: `_clearThumbnailCache()` — deletes files, shows toast

**Scenario: Clear all data**
- Given: User taps "Clear all data"
- When: Dialog appears with "Type DELETE to confirm"
- Then: Must type "DELETE" exactly → double confirm → wipe all DB data
- Reference: `_clearAllData()` — TextEditingController validation with toast feedback

### REQ-4: Data Section
Backup & Restore and Quick Export.

**Scenario: Backup & Restore**
- Given: User taps "Backup & Restore"
- When: Navigate
- Then: Push `BackupSettingsScreen`
- Reference: Navigation to BackupSettingsScreen

**Scenario: Quick export**
- Given: User taps "Quick export"
- When: Trigger
- Then: `BackupExportService.export()` → share file via `shareBackupFile()`
- Reference: `_quickExport()` — export + share

### REQ-5: About Section
Version info, Privacy Policy, Send feedback, Rate this app.

**Scenario: Show version**
- Given: Settings screen
- When: Render
- Then: Display app version from `package_info_plus`
- Reference: About section — version display

**Scenario: Open Privacy Policy**
- Given: User taps "Privacy Policy"
- When: Tap
- Then: `url_launcher` opens privacy policy URL
- Reference: Privacy policy link

**Scenario: Send feedback**
- Given: User taps "Send feedback"
- When: Tap
- Then: Opens email compose with `mailto:haibasoftware@gmail.com`
- Reference: Feedback mailto link

**Scenario: Rate this app**
- Given: User taps "Rate this app"
- When: Tap
- Then: Opens Play Store listing URL
- Reference: Play Store link

### REQ-6: Developer Section (testAds only)
Developer tools visible only when `testAds = true`.

**Scenario: testAds enabled**
- Given: `AppConfig.testAds = true`
- When: Settings screen renders
- Then: "🛠️ Developer" section visible with "DB stats" button
- Reference: Conditional section rendering

**Scenario: DB stats dialog**
- Given: Developer section visible
- When: Tap "DB stats"
- Then: AlertDialog showing item count, favorite count, thumbnail count, tag count
- Reference: DB stats dialog

### REQ-7: Settings Access
Settings accessible from Library ⋮ menu.

**Scenario: Open settings**
- Given: Library screen
- When: Tap ⋮ menu → "Settings"
- Then: Push SettingsScreen
- Reference: Library screen menu → Settings navigation

## Cần làm rõ
- Settings provider uses Riverpod + SharedPreferences, overridden in `main.dart`
- `Icons.bug_report_outlined` used (not `Icons.bug_outlined` which doesn't exist)
- Clear all data dialog uses `addPostFrameCallback` to defer TextEditingController dispose
