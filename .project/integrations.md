# Tích hợp 3rd Party & CI/CD

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
| `go_router` | ^14.2.0 | Router (available, not used) |
| `android_intent_plus` | ^5.1.0 | Android intents |
| `intl` | ^0.19.0 | Internationalization (available) |

### Dev Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | ^2.4.12 | Code generation |
| `drift_dev` | ^2.20.0 | Drift code gen |
| `mocktail` | ^1.0.4 | Mocking for tests |
| `flutter_lints` | ^5.0.0 | Lint rules |

## Firebase / Supabase
**Không dùng.** App hoạt động hoàn toàn local-first.

## Push Notification
**Chưa implement.** Android 13+ cần `POST_NOTIFICATIONS` permission (đã plan trong Manifest nhưng chưa bật).

## Payment Gateway
**Không có.** App miễn phí.

## CI/CD: GitHub Actions

### Workflow: Build Debug APK
- **File:** `.github/workflows/build-debug-apk.yml`
- **Trigger:** push/PR to main, manual dispatch
- **Runner:** ubuntu-latest
- **Steps:**
  1. Checkout code
  2. Setup Java 17 (Zulu)
  3. Setup Flutter 3.24.0 stable
  4. `flutter pub get`
  5. `dart run build_runner build` (drift code gen)
  6. `cd android && ./gradlew assembleDebug` (gradle trực tiếp, không EAS)
  7. Upload artifact `reclip-debug-apk` (retained 7 ngày)

### Build Lessons Learned (từ Simplenote)
| # | Lỗi | Fix |
|---|------|-----|
| 1 | `./gradlew: No such file` | Không gitignore gradlew |
| 2 | `unable to resolve groovy.xml.QName` | Gradle 8.9 (không 9.x) |
| 3 | `Minimum supported Gradle 9.3.1` | AGP 8.7.0 (không 9.x) |
| 4 | `Unresolved reference: kotlin` | Xóa kotlin compilerOptions block |
| 5 | `Inconsistent JVM-target` | `kotlin.jvm.target.validation.mode=warning` |
| 6 | `ClassNotFoundException: MainActivity` | Thêm `org.jetbrains.kotlin.android` plugin |
| 7 | APK path wrong | `build/app/outputs/flutter-apk/` |

### Skills (AI Agent Reference)
- `.agents/skills/reclip-build.md` — Build workflow + rules + checklist
- `.agents/skills/reclip-project.md` — Project conventions + architecture
