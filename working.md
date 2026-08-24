# Working — Reclip Project

## Current State
- **Last Updated:** 2026-08-24
- **Phase:** Phase 3 — Value Loop DONE
- **Next:** Phase 4 — Polish (deep links, push notifications, iOS)
- **Ads:** Real ads enabled (`enableAds=true`, `testAds=false`)
- **AAB:** Release build signed with keystore (alias=reclip, pass=83793900)

## Current Path
```
/home/kythuat_hoangweb/htdocs_apps/reclip
```

## GitHub
- **Repo:** https://github.com/hoangsoft90/reclip
- **GH Token:** (stored in CI env, not in code)
- **Default branch:** main

## What's Built
- ✅ Share Intent (receive from any app)
- ✅ Quick Save + Toast + Navigate to detail
- ✅ Library (grid/list, realtime StreamBuilder)
- ✅ Search (FTS5 full-text)
- ✅ Item Detail (tappable thumbnail, open link, edit all details)
- ✅ Smart Save (note, why-saved, collections, tags)
- ✅ Faceted Filter (search + dropdowns + collection/tag)
- ✅ Discover (Hacker News trending)
- ✅ Settings (general, storage, data, about, developer)
- ✅ Backup & Restore (JSON export/import)
- ✅ Onboarding (spotlight overlay)
- ✅ Metadata Enrichment (batch processing)
- ✅ Thumbnail Download (local + remote)
- ✅ Offline Banner
- ✅ AdMob (banner + interstitial every 5 saves)
- ✅ Sentry error tracking
- ✅ Release AAB workflow (signed)
- ✅ Privacy Policy (GitHub Pages)
- ✅ User Guide (Firebase Hosting)
- ✅ app-ads.txt (Firebase Hosting)
- ✅ OpenSpec (23 specs)

## Recent Session Work (2026-08-24)
| Change | Files |
|--------|-------|
| Settings screen | `settings_provider.dart`, `settings_screen.dart`, `main.dart`, `library_screen.dart` |
| Discover (HN) | `trending_service.dart`, `discover_screen.dart`, `app.dart` |
| Filter redesign | `facet_filter_bar.dart`, `facet_filter_controller.dart`, `library_screen.dart` |
| Detail redesign | `item_detail_screen.dart` (merged edit, tappable thumb, open link top) |
| Collection picker fix | `smart_save_bottom_sheet.dart`, `item_detail_screen.dart` |
| AdMob integration | `ad_manager.dart`, `banner_ad_widget.dart`, `app_config.dart`, `app.dart` |
| Release AAB | `build-release-aab.yml`, `build.gradle.kts` |
| Debug banner off | `app.dart` |
| OpenSpec update | 3 new specs, 3 updated |
| Privacy Policy | `docs/privacy-policy.html`, gh-pages deploy |
| User Guide | `guide.html`, Firebase Hosting |
| app-ads.txt | `app-ads.txt`, Firebase Hosting |

## Known Issues
1. FTS5 input not sanitized (special chars)
2. Search no debounce (perf with large library)
3. `PlatformEnum.x` uses `Icons.close` not X logo
4. Tag ID uses timestamp (millisecond collision risk)
5. Thumbnail download stuck if app killed
6. `_matchesAny` matches subdomain too broadly

## Deployed URLs
| URL | Purpose |
|-----|---------|
| `https://all-my-apps-5d52f.web.app/guide.html` | User guide |
| `https://all-my-apps-5d52f.web.app/app-ads.txt` | AdMob verification |
| `https://hoangsoft90.github.io/reclip/privacy-policy.html` | Privacy Policy |

## Build Status
| Workflow | Last Status | Notes |
|----------|-------------|-------|
| Debug APK (#96+) | ✅ Success | Main branch |
| Release AAB (#4) | ✅ Success | Signed, real ads |

## Next Steps
1. Test real ads on device — verify banner + interstitial show
2. Submit to Google Play Console
3. Phase 4: Deep link schemes, push notifications
4. Consider iOS support
5. Migrate keystore from embedded to GH secret
