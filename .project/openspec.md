# OpenSpec — Progress, Bugs, Todo

## Current Status

### ✅ Completed (23 specs)
| Capability | Spec | Code | Notes |
|-----------|------|------|-------|
| url-normalization | ✅ | ✅ | |
| platform-detection | ✅ | ✅ | |
| local-database | ✅ | ✅ | Drift + FTS5 |
| share-intent | ✅ | ✅ | Cold start fix |
| quick-save | ✅ | ✅ | |
| library | ✅ | ✅ | Grid/list + filter |
| faceted-filter | ✅ | ✅ | **Updated:** search + dropdowns + collection/tag |
| offline-banner | ✅ | ✅ | |
| search | ✅ | ✅ | FTS5 |
| item-detail | ✅ | ✅ | **Updated:** merged edit, tappable thumb, open link top |
| open-original | ✅ | ✅ | url_launcher |
| smart-save | ✅ | ✅ | **Updated:** collection picker, keyboard fix |
| quick-save-toast | ✅ | ✅ | Navigate to detail |
| metadata-adapters | ✅ | ✅ | |
| enrichment-orchestrator | ✅ | ✅ | Batch processing |
| thumbnail-download | ✅ | ✅ | Local + remote |
| metrics-logger | ✅ | ✅ | In-memory |
| app-shell | ✅ | ✅ | Bottom nav, share intent listener |
| ui-constants | ✅ | ✅ | |
| http-client | ✅ | ✅ | Dio + retry |
| settings | ✅ | ✅ | **NEW:** Full settings screen |
| discover | ✅ | ✅ | **NEW:** Hacker News trending |
| ads | ✅ | ✅ | **NEW:** AdMob banner + interstitial |

### ⏳ In Progress / Pending
- [ ] Rediscovery Engine (age × last_seen × favorite)
- [ ] Deep link schemes (`instagram://`, `tiktok://`)
- [ ] Push notifications
- [ ] iOS support

### 🔜 Backlog
- [ ] Screenshot-to-Clip + OCR
- [ ] Smart Collections (rule-based)
- [ ] Batch import
- [ ] Cloud backup/sync
- [ ] Export Collection
- [ ] Moodboard
- [ ] Semantic search
- [ ] i18n

## Known Bugs
| # | Bug | Severity | Status |
|---|-----|----------|--------|
| 1 | FTS5 input not sanitized (special chars) | Low | Known |
| 2 | Search no debounce (perf with large library) | Low | Known |
| 3 | `PlatformEnum.x` uses `Icons.close` not X logo | Low | Known |
| 4 | Tag ID uses timestamp (millisecond collision risk) | Low | Known |
| 5 | Thumbnail download stuck if app killed | Low | Known |
| 6 | `_matchesAny` matches subdomain too broadly | Low | Known |

## Features Done This Session
| Feature | Files Changed |
|---------|--------------|
| Settings screen | `settings_screen.dart`, `settings_provider.dart`, `main.dart`, `library_screen.dart` |
| Discover (HN trending) | `discover_screen.dart`, `trending_service.dart`, `app.dart` |
| Filter redesign | `facet_filter_bar.dart`, `facet_filter_controller.dart`, `library_screen.dart` |
| Detail screen redesign | `item_detail_screen.dart` (merged edit, tappable thumb, open link top) |
| Collection picker fix | `smart_save_bottom_sheet.dart`, `item_detail_screen.dart` |
| AdMob integration | `ad_manager.dart`, `banner_ad_widget.dart`, `app_config.dart`, `app.dart` |
| Interstitial ads | `app.dart` (every 5 saves) |
| Release AAB workflow | `build-release-aab.yml`, `build.gradle.kts` |
| Debug banner removed | `app.dart` (debugShowCheckedModeBanner: false) |
| OpenSpec updated | 3 new specs, 3 updated specs |

## Build History
| Run | Status | Notes |
|-----|--------|-------|
| #1-#22 | ❌ Fail | Gradle/Kotlin/AGP issues |
| #23 | ✅ Success | First successful build |
| #24-#93 | ✅ Success | Stable |
| #94-#95 | ❌ Cancelled | Replaced by newer push |
| #96 | ✅ Success | Debug APK |
| #2 (Release) | ✅ Success | Release AAB signed |
| #4 (Release) | ✅ Success | Real ads enabled |
