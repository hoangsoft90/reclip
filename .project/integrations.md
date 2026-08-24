# Integrations & CI/CD

## 3rd Party Libraries

### Core Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.5.1 | State management |
| `drift` | ^2.20.0 | SQLite ORM + FTS5 |
| `sqlite3_flutter_libs` | ^0.5.24 | SQLite native libs |
| `dio` | ^5.7.0 | HTTP client |
| `receive_sharing_intent` | ^1.8.0 | Android Share Intent |
| `cached_network_image` | ^3.4.0 | Network image caching |
| `flutter_cache_manager` | ^3.4.1 | File cache (thumbnails) |
| `connectivity_plus` | ^6.0.5 | Online/offline detection |
| `url_launcher` | ^6.3.0 | Open URLs in browser |
| `html` | ^0.15.4 | Parse HTML for OG tags |
| `uuid` | ^4.4.2 | UUID v4 generation |
| `path_provider` | ^2.1.4 | App documents directory |
| `android_intent_plus` | ^5.1.0 | Android intents |

### Monetization
| Package | Version | Purpose |
|---------|---------|---------|
| `google_mobile_ads` | ^5.3.0 | AdMob (banner + interstitial) |

### Monitoring
| Package | Version | Purpose |
|---------|---------|---------|
| `sentry_flutter` | ^8.0.0 | Error tracking |
| `package_info_plus` | ^8.0.0 | App version info |
| `shared_preferences` | ^2.3.0 | Settings persistence |

### Dev Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | ^2.4.12 | Code generation |
| `drift_dev` | ^2.20.0 | Drift code gen |
| `mocktail` | ^1.0.4 | Mocking for tests |
| `flutter_lints` | ^5.0.0 | Lint rules |

## AdMob Configuration
- **App ID:** `ca-app-pub-6917313063209470~3883004257`
- **Banner:** `ca-app-pub-6917313063209470/8121632162`
- **Interstitial:** `ca-app-pub-6917313063209470/3499860875`
- **Rewarded:** `ca-app-pub-6917313063209470/9873697532`
- **Status:** Real ads enabled (`enableAds=true`, `testAds=false`)
- **Interstitial interval:** Every 5 saves from share intent
- **app-ads.txt:** `https://all-my-apps-5d52f.web.app/app-ads.txt`

## Sentry
- **DSN:** `https://2800d4f2840f11d317041a3d24a77194@o4505474077753344.ingest.us.sentry.io/4511963247083520`
- **Status:** Integrated in `main.dart` with `SentryFlutter.init()`

## Firebase Hosting
- **Project:** `all-my-apps-5d52f`
- **URL:** `https://all-my-apps-5d52f.web.app`
- **Files hosted:**
  - `/app-ads.txt` — AdMob verification
  - `/guide.html` — User guide (English)

## CI/CD: GitHub Actions

### Workflow 1: Build Debug APK
- **File:** `.github/workflows/build-debug-apk.yml`
- **Trigger:** push/PR to main, manual dispatch
- **Steps:** Checkout → Java 17 → Flutter 3.29.3 → pub get → build_runner → assembleDebug → upload artifact
- **Artifact:** `reclip-debug-apk` (7-day retention)
- **Retry:** 3x for Maven rate limiting

### Workflow 2: Build Release AAB
- **File:** `.github/workflows/build-release-aab.yml`
- **Trigger:** push to main, manual dispatch
- **Steps:** Checkout → Java 17 → Flutter 3.29.3 → pub get → build_runner → decode keystore → bundleRelease → verify signing → upload artifact
- **Artifact:** `reclip-release-aab` (30-day retention)
- **Keystore:** RSA 2048-bit, alias=reclip, password=83793900, validity 25 years
- **Signing:** Release keystore embedded in workflow (migrate to GH secret later)

### Build Lessons
| # | Error | Fix |
|---|-------|-----|
| 1 | `./gradlew: No such file` | Don't gitignore gradlew |
| 2 | `unable to resolve groovy.xml.QName` | Gradle 8.9 (not 9.x) |
| 3 | `Minimum supported Gradle 9.3.1` | AGP 8.7.0 (not 9.x) |
| 4 | `Unresolved reference: kotlin` | Remove kotlin compilerOptions block |
| 5 | `Inconsistent JVM-target` | `kotlin.jvm.target.validation.mode=warning` |
| 6 | `ClassNotFoundException: MainActivity` | Add `org.jetbrains.kotlin.android` plugin |
| 7 | APK path wrong | `build/app/outputs/flutter-apk/` |
| 8 | `Icons.bug_outlined` doesn't exist | Use `Icons.bug_report_outlined` |
| 9 | Maven HTTP 429 rate limiting | Add retry to Gradle build |
| 10 | `await` in non-async `runZonedGuarded` | Move before `SentryFlutter.init()` |

## Skills (AI Agent Reference)
- `.agents/skills/reclip-build.md` — Build workflow + rules + checklist
- `.agents/skills/reclip-project.md` — Project conventions + architecture
- `.agents/skills/reclip-lessons.md` — 22 lessons learned (build, code, platform)
