---
name: reclip-lessons
description: "LESSONS LEARNED — All bugs, crashes, and pitfalls found in Reclip project. MUST READ before writing any code. Prevents wasting hours on fix-build-fix loops. Covers: Drift database, AdMob, Android system, Flutter patterns, CI/CD."
---

# Reclip — Lessons Learned (Anti-Pattern Library)

> **Purpose:** Every item below was a REAL bug that caused CI build failure or runtime crash. Read this before writing code to avoid repeating them. Each lesson includes: the error, root cause, and correct pattern.

---

## 1. 🚨 Drift Database — textEnum + withDefault CRASH

### Error
```
Internal error while deserializing DriftElementId(package:reclip/core/database/database.dart, saved_items):
  type 'Null' is not a subtype of type 'Map<dynamic, dynamic>' in type cast
```
→ `database.g.dart` generated WITHOUT `SavedItem` class → ALL files importing it fail.

### Root Cause
`drift_dev 2.34.x` has an internal serialization bug when a `textEnum` column uses `.withDefault(const Constant(...))`.

### ❌ WRONG
```dart
TextColumn get contentType => textEnum<ContentTypeEnum>()()
    .withDefault(const Constant('unknown'))();  // ← CRASHES drift_dev

TextColumn get metadataStatus => textEnum<MetadataStatusEnum>()()
    .withDefault(const Constant('pending'))();  // ← CRASHES drift_dev

TextColumn get linkStatus => textEnum<LinkStatusEnum>()()
    .withDefault(const Constant('unknown'))();  // ← CRASHES drift_dev

TextColumn get downloadStatus => textEnum<DownloadStatusEnum>()()
    .withDefault(const Constant('pending'))();  // ← CRASHES drift_dev
```

### ✅ CORRECT
```dart
// Schema: no withDefault on textEnum columns
TextColumn get contentType => textEnum<ContentTypeEnum>()();
TextColumn get metadataStatus => textEnum<MetadataStatusEnum>()();
TextColumn get linkStatus => textEnum<LinkStatusEnum>()();
TextColumn get downloadStatus => textEnum<DownloadStatusEnum>()();

// Application code: set defaults explicitly in insert
await into(savedItems).insert(
  SavedItemsCompanion.insert(
    id: id,
    originalUrl: originalUrl,
    canonicalUrl: canonicalUrl,
    platform: platform,
    contentType: ContentTypeEnum.unknown,      // ← raw enum, NOT Value()
    metadataStatus: MetadataStatusEnum.pending, // ← raw enum
    linkStatus: LinkStatusEnum.unknown,         // ← raw enum
    savedAt: now,
  ),
);
```

### Rule
> **NEVER use `.withDefault(const Constant(...))` on `textEnum` columns in Drift tables.** Always set defaults in application code.

---

## 2. 🚨 Drift — Companion.insert() expects raw enum, NOT Value<Enum>

### Error
```
Error: The argument type 'Value<ContentTypeEnum>' can't be assigned to the parameter type 'ContentTypeEnum'.
```

### Root Cause
When `textEnum` columns have no `withDefault`, the generated `Companion.insert()` factory expects the **raw enum type**, not `Value<EnumType>`.

### ❌ WRONG
```dart
SavedItemsCompanion.insert(
  contentType: Value(ContentTypeEnum.unknown),     // ← WRONG
  metadataStatus: Value(MetadataStatusEnum.pending), // ← WRONG
  linkStatus: Value(LinkStatusEnum.unknown),         // ← WRONG
)
```

### ✅ CORRECT
```dart
SavedItemsCompanion.insert(
  contentType: ContentTypeEnum.unknown,     // ← raw enum
  metadataStatus: MetadataStatusEnum.pending, // ← raw enum
  linkStatus: LinkStatusEnum.unknown,         // ← raw enum
)
```

### Note
- `Value<Enum>` is correct in **update** operations: `SavedItemsCompanion(contentType: Value(x))`
- `Value<Enum>` is correct for **nullable** columns in insert: `SavedItemsCompanion.insert(title: Value(null))`
- Only `textEnum` columns **without** `withDefault` in `.insert()` require raw type

---

## 3. 🚨 Drift — database.g.dart must be regenerated after ANY schema change

### Symptom
Build fails with `SavedItem isn't a type` or similar "missing class" errors.

### Root Cause
`database.g.dart` is in `.gitignore`. CI runs `build_runner` to generate it. If schema changes aren't compatible with current drift_dev version, generation fails silently (produces incomplete file).

### ✅ CORRECT Workflow
```bash
# After editing database.dart:
dart run build_runner build --delete-conflicting-outputs

# Verify generated file exists and has the expected classes:
grep "class SavedItem" lib/core/database/database.g.dart

# THEN commit + push
```

### Rule
> **After ANY change to `database.dart`, always check CI build log for `build_runner` output.** If you see "Internal error while deserializing", it's a drift_dev version issue — check for textEnum+withDefault.

---

## 4. 🚨 AdMob — google_mobile_ads 5.x API Changes

### Error 1
```
Error: The argument type 'Ad' can't be assigned to the parameter type 'BannerAd'.
```

### Root Cause
In google_mobile_ads 5.x, `BannerAdListener.onAdLoaded` callback parameter type is `Ad`, not `BannerAd`.

### ❌ WRONG
```dart
listener: BannerAdListener(
  onAdLoaded: (ad) {
    onLoaded(ad);  // ← ad is type Ad, not BannerAd
  },
)
```

### ✅ CORRECT
```dart
listener: BannerAdListener(
  onAdLoaded: (ad) {
    onLoaded(ad as BannerAd);  // ← cast required
  },
)
```

---

### Error 2
```
Error: No named parameter with the name 'adLoadCallback'.
```

### Root Cause
In google_mobile_ads 5.x, `RewardedAd.load()` parameter renamed.

### ❌ WRONG
```dart
RewardedAd.load(
  adUnitId: id,
  request: const AdRequest(),
  adLoadCallback: RewardedAdLoadCallback(...),  // ← WRONG name
)
```

### ✅ CORRECT
```dart
RewardedAd.load(
  adUnitId: id,
  request: const AdRequest(),
  rewardedAdLoadCallback: RewardedAdLoadCallback(...),  // ← CORRECT name
)
```

---

## 5. 🚨 Android — HTTP Cleartext Blocked on Release APK

### Symptom
HTTP requests work on debug APK but fail silently on release APK.

### Root Cause
Android 9+ (API 28+) blocks cleartext (HTTP) traffic by default. Debug builds may have different network security defaults.

### ✅ CORRECT — 2 files needed

**File 1:** `android/app/src/main/res/xml/network_security_config.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

**File 2:** `android/app/src/main/AndroidManifest.xml`
```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    android:usesCleartextTraffic="true"
    ...>
```

---

## 6. 🚨 Android — Overlay/Toast Hidden by Navigation Bar

### Symptom
Toast appears at screen bottom but is partially or fully hidden by Android's 3-button navigation bar.

### Root Cause
Overlay positioned at `bottom: 0` doesn't account for system insets (navigation bar height ~48dp).

### ❌ WRONG
```dart
Positioned(
  bottom: 0,  // ← hidden by nav bar
  left: 16,
  right: 16,
  child: toast,
)
```

### ✅ CORRECT
```dart
Positioned(
  bottom: 0,
  left: 16,
  right: 16,
  child: SafeArea(
    top: false,  // Only protect bottom
    child: toast,
  ),
)
```

### Rule
> **Every bottom-positioned overlay/widget must be wrapped in `SafeArea(top: false)`** to avoid Android nav bar.

---

## 7. 🚨 Flutter — OverlayEntry.remove() Crashes

### Symptom
```
setState() or markNeedsBuild() called during build.
```

### Root Cause
`OverlayEntry.remove()` called outside the overlay's build cycle or after overlay is already removed.

### ✅ CORRECT
```dart
void _removeOverlay() {
  try {
    if (_overlayEntry.mounted) {
      _overlayEntry.remove();
    }
  } catch (_) {
    // Overlay already removed or unmounted — safe to ignore
  }
}
```

---

## 8. 🚨 Flutter — PopScope Required on Every Screen

### Symptom
System back button behavior inconsistent — some screens exit app unexpectedly, some don't go back at all.

### Root Cause
No `PopScope` widget wrapping screens, so Flutter uses default back behavior.

### ✅ CORRECT — Every pushed screen
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,  // or false if you need custom handling
      child: Scaffold(
        appBar: AppBar(...),
        body: ...,
      ),
    );
  }
}
```

---

## 9. 🚨 Flutter — dart:io Import Removal Breaks File()

### Error
```
Error: The getter 'io' isn't defined for the class '_MyScreenState'.
```

### Root Cause
Removed `import 'dart:io as io'` but code still uses `io.File(...)`.

### ✅ CORRECT
- Either re-add the import: `import 'dart:io';` then use `File(...)`
- Or use full import: `import 'dart:io' as io;` then use `io.File(...)`

### Rule
> **When removing an import, grep for ALL usages of that import's prefix before removing.**

---

## 10. 🚨 Flutter — Global Error Handler Required

### Symptom
App crashes silently with no Sentry report. Users see white screen.

### ✅ CORRECT — main.dart
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_DSN';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runZonedGuarded(() {
      // Global Flutter framework error handler
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        Sentry.captureException(details.exception, stackTrace: details.stack);
      };
      runApp(const MyApp());
    }, (error, stack) {
      // Global async error handler
      Sentry.captureException(error, stackTrace: stack);
    }),
  );
}
```

---

## 11. 🚨 Flutter — Don't Pop Screen on Non-Navigation Actions

### Error
Tapping ⭐ favorite toggle on Item Detail screen unexpectedly pops the screen.

### Root Cause
`Navigator.of(context).pop()` was called inside the favorite toggle handler, which isn't a navigation action.

### ❌ WRONG
```dart
onPressed: () async {
  await db.updateSavedItem(id: item.id, isFavorite: !item.isFavorite);
  Navigator.of(context).pop();  // ← WRONG — user wanted to toggle, not go back
}
```

### ✅ CORRECT
```dart
onPressed: () async {
  await db.updateSavedItem(id: item.id, isFavorite: !item.isFavorite);
  // Don't pop — StreamBuilder in Library auto-refreshes the list
  if (mounted) setState(() {});
}
```

### Rule
> **Never call `Navigator.pop()` in a toggle/action handler. Only pop in explicit navigation handlers (Back button, "Done" button, etc.).**

---

## 12. 🚨 Concurrency — Batch Processing > Pool Logic

### Error
Enrichment orchestrator using complex pool with `completer` map → infinite loop or deadlock.

### ✅ CORRECT — Simple batch
```dart
const maxConcurrent = 3;
for (var i = 0; i < pendingItems.length; i += maxConcurrent) {
  final batch = pendingItems.sublist(
    i,
    (i + maxConcurrent).clamp(0, pendingItems.length),
  );
  await Future.wait(
    batch.map((item) => _enrichOne(item)),
    eagerError: true,
  );
}
```

### Rule
> **For concurrent batch processing, use simple `Future.wait` in chunks. Avoid custom pool/completer maps — they're error-prone and hard to debug.**

---

## 13. 🚨 CI/CD — Flutter Version Mismatch Causes Android SDK Errors

### Error
```
flutter_plugin_android_lifecycle requires Android SDK version 35
package_info_plus: compileSdkVersion is not specified
```

### Root Cause
Flutter 3.24.x ships with older Android SDK defaults. Newer packages require SDK 35.

### ✅ CORRECT — CI Workflow
```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.29.3'  # ← Must support Android SDK 35
    channel: 'stable'
```

### ✅ CORRECT — build.gradle.kts
```kotlin
android {
    compileSdk = 35  // ← Explicit, not flutter.compileSdkVersion
}
```

---

## 14. 🚨 package_info_plus 9.x Kotlin Compiler Crash

### Error
```
package_info_plus-9.0.1/android/src/main/kotlin/.../PackageInfoPlugin.kt:20:5:
  java.lang.IllegalArgumentException: source must not be null
```
→ Task :package_info_plus:compileDebugKotlin FAILED

### Root Cause
`package_info_plus 9.0.1` has an internal Kotlin compiler bug with Kotlin 2.0.x. This is a transitive dependency (e.g., pulled by `google_mobile_ads` or `connectivity_plus`).

### ❌ WRONG
```yaml
# pubspec.yaml — no explicit package_info_plus, resolves to 9.0.1
# No error locally, but CI Kotlin compiler crashes
```

### ✅ CORRECT
```yaml
# pubspec.yaml — pin to 8.x
package_info_plus: ^8.1.3
```

### Rule
> **After adding any new dependency, check if it brings in `package_info_plus`. If CI shows Kotlin compiler crash on package_info_plus, pin to `^8.1.3`.**

---

## Quick Reference Checklist

Before EVERY commit to main, verify:

```
[ ] database.dart changes: ran build_runner + verified SavedItem class exists
[ ] textEnum columns: NO withDefault(const Constant(...))
[ ] Companion.insert(): raw enum, not Value<Enum> for non-nullable textEnum
[ ] New screens: wrapped with PopScope
[ ] Bottom overlays: wrapped with SafeArea(top: false)
[ ] Removed imports: grepped for all usages of prefix
[ ] AdMob callbacks: cast Ad→BannerAd, use rewardedAdLoadCallback
[ ] Navigator.pop(): only in navigation handlers, not action handlers
[ ] OverlayEntry.remove(): wrapped in try-catch with .mounted check
```

---

## Version History

| Date | Lesson | Severity |
|------|--------|----------|
| 2026-08-24 | textEnum + withDefault crashes drift_dev 2.34.x | 🔴 Critical |
| 2026-08-24 | Companion.insert() needs raw enum for textEnum | 🔴 Critical |
| 2026-08-24 | AdMob 5.x: Ad→BannerAd cast + param rename | 🔴 Critical |
| 2026-08-24 | HTTP cleartext blocked on release APK | 🔴 Critical |
| 2026-08-24 | Toast hidden by Android nav bar | 🟡 Medium |
| 2026-08-24 | OverlayEntry.remove() crash | 🟡 Medium |
| 2026-08-24 | PopScope missing on screens | 🟡 Medium |
| 2026-08-24 | dart:io import removal breaks File() | 🟡 Medium |
| 2026-08-24 | Global error handler required | 🟡 Medium |
| 2026-08-24 | Don't pop on toggle actions | 🟡 Medium |
| 2026-08-24 | Batch > pool for concurrency | 🟢 Low |
| 2026-08-24 | Flutter 3.29.3 for SDK 35 compat | 🟡 Medium |
| 2026-08-24 | package_info_plus 9.x Kotlin compiler crash — pin ^8.1.3 | 🔴 Critical |
