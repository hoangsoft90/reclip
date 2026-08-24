#!/usr/bin/env python3
"""
Sync UNIVERSAL lessons learned to SimpleNote via MCP.
These lessons apply to ANY Flutter/Android project, not just Reclip.

Usage: python3 scripts/sync_universal_lessons.py
"""

import subprocess
import json
import sys
import os
import tempfile


def mcpc_call(tool_name: str, arguments: dict) -> dict:
    """Call an MCP tool via mcpc CLI using temp file to avoid shell escaping."""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump(arguments, f)
        tmpfile = f.name

    try:
        cmd = f'mcpc @simplenote tools-call {tool_name} "$(cat {tmpfile})"'
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=30)
        if result.returncode != 0:
            print(f"Error: {result.stderr}", file=sys.stderr)
            return {"error": result.stderr}
        lines = result.stdout.strip().split('\n')
        for i, line in enumerate(lines):
            if line.startswith('{'):
                try:
                    return json.loads('\n'.join(lines[i:]))
                except json.JSONDecodeError:
                    pass
        return {"raw": result.stdout}
    finally:
        os.unlink(tmpfile)


def search_notes(query: str) -> list:
    result = mcpc_call("search_notes", {"query": query, "limit": 10})
    if isinstance(result, dict) and "results" in result:
        return result["results"]
    return []


def create_note(content: str, tags: list) -> dict:
    return mcpc_call("create_note", {"content": content, "tags": tags})


def update_note(note_id: str, content: str, tags: list = None) -> dict:
    args = {"id": note_id, "content": content}
    if tags:
        args["tags"] = tags
    return mcpc_call("update_note", args)


# ═══════════════════════════════════════════════════════════════
# UNIVERSAL LESSONS — Grouped by topic, applicable to ANY project
# ═══════════════════════════════════════════════════════════════

LESSON_1_DRIFT_DATABASE = """# Flutter Drift Database — Common Pitfalls & Fixes

> Universal lessons for ANY Flutter project using Drift (formerly Moor).
> Tags: #flutter #drift #database #reclip

---

## 1. textEnum + withDefault CRASHES drift_dev

**Error:** `Internal error while deserializing DriftElementId` → `database.g.dart` generated WITHOUT model class.

**Root Cause:** `drift_dev 2.34.x` has an internal serialization bug when `textEnum` columns use `.withDefault(const Constant(...))`.

**❌ WRONG:**
```dart
TextColumn get contentType => textEnum<ContentTypeEnum>()()
    .withDefault(const Constant('unknown'))();  // ← CRASHES
```

**✅ CORRECT:**
```dart
// Schema: no withDefault on textEnum
TextColumn get contentType => textEnum<ContentTypeEnum>()();

// Application code: set defaults explicitly
await into(savedItems).insert(
  SavedItemsCompanion.insert(
    contentType: ContentTypeEnum.unknown,  // ← raw enum, NOT Value()
    savedAt: now,
  ),
);
```

**Rule:** NEVER use `.withDefault()` on `textEnum` columns. Set defaults in application code.

---

## 2. Companion.insert() needs raw enum, NOT Value<Enum>

**Error:** `The argument type 'Value<ContentTypeEnum>' can't be assigned to 'ContentTypeEnum'`

**❌ WRONG:**
```dart
SavedItemsCompanion.insert(
  contentType: Value(ContentTypeEnum.unknown),  // ← WRONG
)
```

**✅ CORRECT:**
```dart
SavedItemsCompanion.insert(
  contentType: ContentTypeEnum.unknown,  // ← raw enum
)
```

**Note:** `Value<Enum>` IS correct in **update** operations and for **nullable** columns in insert.

---

## 3. database.g.dart must be regenerated after ANY schema change

**Symptom:** Build fails with `SavedItem isn't a type`.

**✅ CORRECT workflow:**
```bash
# After editing database.dart:
dart run build_runner build --delete-conflicting-outputs

# Verify:
grep "class SavedItem" lib/core/database/database.g.dart

# THEN commit + push
```

---

## 4. Drift select() not public outside database class

**Error:** `The method 'select' isn't defined for the type 'AppDatabase'`

**✅ CORRECT — Add public methods to database.dart:**
```dart
// In database.dart:
Future<SavedItem?> getSavedItemById(String id) async {
  return (select(savedItems)..where((t) => t.id.equals(id))).getSingleOrNull();
}

// In other files:
final item = await db.getSavedItemById(id);  // ← OK
```

**Rule:** Never call `select()` from outside database.dart. Always add public query methods.

---

## Pre-commit Checklist for Drift:
```
[ ] database.dart changes: ran build_runner + verified model class exists
[ ] textEnum columns: NO withDefault(const Constant(...))
[ ] Companion.insert(): raw enum, not Value<Enum> for non-nullable textEnum
[ ] New query methods added as public functions in database.dart
```
"""

LESSON_2_FLUTTER_UI = """# Flutter UI Anti-Patterns — Navigation, Overlay, State

> Universal lessons for ANY Flutter project.
> Tags: #flutter #ui #navigation #overlay #reclip

---

## 1. PopScope Required on Every Screen

**Symptom:** System back button exits app unexpectedly.

**✅ CORRECT — Every pushed screen:**
```dart
return PopScope(
  canPop: true,
  child: Scaffold(
    appBar: AppBar(...),
    body: ...,
  ),
);
```

---

## 2. Overlay/Toast Hidden by Android Navigation Bar

**Symptom:** Toast at screen bottom hidden by 3-button nav bar.

**❌ WRONG:**
```dart
Positioned(bottom: 0, child: toast)  // ← hidden by nav bar
```

**✅ CORRECT:**
```dart
Positioned(
  bottom: 0,
  child: SafeArea(
    top: false,  // Only protect bottom
    child: toast,
  ),
)
```

**Rule:** Every bottom-positioned overlay must use `SafeArea(top: false)`.

---

## 3. OverlayEntry.remove() Crashes

**Error:** `setState() or markNeedsBuild() called during build`

**✅ CORRECT:**
```dart
void _removeOverlay() {
  try {
    if (_overlayEntry.mounted) {
      _overlayEntry.remove();
    }
  } catch (_) {}
}
```

---

## 4. Don't Pop Screen on Non-Navigation Actions

**Symptom:** Tapping favorite toggle pops the detail screen.

**❌ WRONG:**
```dart
onPressed: () async {
  await db.updateItem(id: item.id, isFavorite: !item.isFavorite);
  Navigator.of(context).pop();  // ← WRONG
}
```

**✅ CORRECT:**
```dart
onPressed: () async {
  await db.updateItem(id: item.id, isFavorite: !item.isFavorite);
  if (mounted) setState(() {});  // ← Stay on screen
}
```

**Rule:** Only call `Navigator.pop()` in explicit navigation handlers (Back, Done, Cancel).

---

## 5. StatelessWidget Won't Update After DB Edits

**Symptom:** User edits data, saves, but UI shows old values.

**✅ CORRECT — Use StatefulWidget + reload:**
```dart
class DetailScreen extends StatefulWidget {
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Item _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _reloadItem() async {
    final fresh = await widget.db.getItemById(_item.id);
    if (fresh != null && mounted) setState(() => _item = fresh);
  }
}
```

**Rule:** Any screen where user can edit data MUST be StatefulWidget with `_reloadItem()`.

---

## 6. IndexedStack + autofocus = Keyboard on Wrong Tab

**Symptom:** App opens on Tab A but keyboard appears for Tab B's TextField.

**Root Cause:** `IndexedStack` builds ALL children simultaneously.

**❌ WRONG:**
```dart
IndexedStack(
  index: _currentIndex,
  children: [
    LibraryScreen(),
    SearchScreen(),  // ← built even when hidden!
  ],
)

// search_screen.dart
TextField(autofocus: true)  // ← triggers on app start
```

**✅ CORRECT:**
```dart
// Remove autofocus, use manual focus:
TextField(
  onTapOutside: (_) => FocusScope.of(context).unfocus(),
)
```

**Rule:** With IndexedStack, NEVER use `autofocus: true` on non-default tabs.

---

## 7. dart:io Import Removal Breaks File()

**Error:** `The getter 'io' isn't defined`

**Rule:** When removing an import, grep for ALL usages of that prefix first.
"""

LESSON_3_SHARE_INTENT = """# Flutter Share Intent & Deep Link Patterns

> Universal lessons for ANY Flutter project with share intent / deep linking.
> Tags: #flutter #share-intent #deep-link #navigation #reclip

---

## 1. Share Intent Must Navigate After Save

**Symptom:** Share from another app → saves but stays on old screen.

**Root Cause:** Handler only shows toast, no navigation.

**❌ WRONG:**
```dart
handler.onShare.listen((url) {
  _showToast(url);  // ← no navigation
});
```

**✅ CORRECT:**
```dart
// ShareIntentHandler — emit SaveResult (not raw URL)
final _onSaveController = StreamController<SaveResult>.broadcast();
Stream<SaveResult> get onSave => _onSaveController.stream;

// app.dart — show toast THEN navigate
handler.onSave.listen((result) {
  final item = result.item;
  QuickSaveToastOverlay.show(context, item, result.isNew, db);
  Future.delayed(const Duration(milliseconds: 800), () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
    );
  });
});
```

**Rule:** Share intent flow: save → emit SavedItem → navigate to detail. Never just toast.

---

## 2. Cold Start Timing Race

**Symptom:** Share intent works when app is running but not when launched from share.

**Root Cause:** Provider init fires before app.dart attaches its listener.

**✅ CORRECT — Queue pending result:**
```dart
SaveResult? _pendingResult;

void _handleShare(String rawContent) {
  final url = _extractUrl(rawContent);
  if (url != null) {
    _quickSaveService.save(url).then((result) {
      if (_onSaveController.hasListener) {
        _onSaveController.add(result);  // warm start
      } else {
        _pendingResult = result;         // cold start: queue
      }
    });
  }
}

// Called by app.dart after listener attached:
void emitPendingIfAny() {
  if (_pendingResult != null) {
    final result = _pendingResult!;
    _pendingResult = null;
    Future.microtask(() => _onSaveController.add(result));
  }
}
```

**Rule:** When using streams from provider init + post-frame listeners, always handle the cold-start race with a pending queue.
"""

LESSON_4_ANDROID_PLATFORM = """# Android Platform — HTTP, SafeArea, Release Build

> Universal lessons for ANY Flutter/Android project.
> Tags: #flutter #android #http #release #safearea #reclip

---

## 1. HTTP Cleartext Blocked on Release APK

**Symptom:** HTTP works on debug but fails silently on release.

**Root Cause:** Android 9+ (API 28+) blocks cleartext by default.

**✅ CORRECT — 2 files needed:**

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

## 2. Toast/Overlay Hidden by Navigation Bar

**Rule:** Every bottom-positioned widget must use `SafeArea(top: false)`.

```dart
Positioned(
  bottom: 0,
  child: SafeArea(
    top: false,
    child: MyToast(),
  ),
)
```

---

## 3. Global Error Handler Required

**Symptom:** App crashes silently, no error report.

**✅ CORRECT — main.dart:**
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
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        Sentry.captureException(details.exception, stackTrace: details.stack);
      };
      runApp(const MyApp());
    }, (error, stack) {
      Sentry.captureException(error, stackTrace: stack);
    }),
  );
}
```
"""

LESSON_5_DEPENDENCIES_CICD = """# Flutter Dependencies & CI/CD Pitfalls

> Universal lessons for ANY Flutter project.
> Tags: #flutter #cicd #dependencies #kotlin #android #reclip

---

## 1. AdMob google_mobile_ads 5.x API Changes

**Error 1:** `The argument type 'Ad' can't be assigned to 'BannerAd'`

**✅ CORRECT:**
```dart
listener: BannerAdListener(
  onAdLoaded: (ad) {
    onLoaded(ad as BannerAd);  // ← cast required
  },
)
```

**Error 2:** `No named parameter with the name 'adLoadCallback'`

**✅ CORRECT:**
```dart
RewardedAd.load(
  adUnitId: id,
  request: const AdRequest(),
  rewardedAdLoadCallback: RewardedAdLoadCallback(...),  // ← renamed
)
```

---

## 2. package_info_plus 9.x Kotlin Compiler Crash

**Error:** `PackageInfoPlugin.kt:20:5: java.lang.IllegalArgumentException: source must not be null`

**Root Cause:** `package_info_plus 9.0.1` has Kotlin compiler bug with Kotlin 2.0.x.

**✅ CORRECT:**
```yaml
# pubspec.yaml — pin to 8.x
package_info_plus: ^8.1.3
```

**Rule:** After adding new deps, check if they bring `package_info_plus`. If CI crashes, pin `^8.1.3`.

---

## 3. Flutter Version Mismatch Causes Android SDK Errors

**Error:** `flutter_plugin_android_lifecycle requires Android SDK version 35`

**✅ CORRECT — CI Workflow:**
```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.29.3'  # ← Must support SDK 35
    channel: 'stable'
```

**✅ CORRECT — build.gradle.kts:**
```kotlin
android {
    compileSdk = 35  # ← Explicit, not flutter.compileSdkVersion
}
```

---

## 4. Concurrency — Batch Processing > Pool Logic

**Symptom:** Complex pool with completer map → infinite loop or deadlock.

**✅ CORRECT — Simple batch:**
```dart
const maxConcurrent = 3;
for (var i = 0; i < items.length; i += maxConcurrent) {
  final batch = items.sublist(
    i,
    (i + maxConcurrent).clamp(0, items.length),
  );
  await Future.wait(
    batch.map((item) => processOne(item)),
    eagerError: true,
  );
}
```

**Rule:** Use simple `Future.wait` in chunks. Avoid custom pool/completer maps.

---

## Pre-push Checklist:
```
[ ] Gradle version — 8.9 (not 9.x)
[ ] AGP version — 8.7.0 (not 9.x)
[ ] app/build.gradle.kts — has Kotlin plugin explicitly
[ ] package_info_plus — pinned to ^8.1.3 if present
[ ] Flutter version — 3.29.3+ for SDK 35 compat
```
"""


# ═══════════════════════════════════════════════════════════════
# SYNC LOGIC
# ═══════════════════════════════════════════════════════════════

NOTES = [
    {
        "title": "Flutter Drift Database — Common Pitfalls & Fixes",
        "search_query": "Flutter Drift Database Common Pitfalls Fixes",
        "content": LESSON_1_DRIFT_DATABASE,
        "tags": ["flutter", "drift", "database", "lessons-learned", "reclip"],
    },
    {
        "title": "Flutter UI Anti-Patterns — Navigation, Overlay, State",
        "search_query": "Flutter UI Anti-Patterns Navigation Overlay State",
        "content": LESSON_2_FLUTTER_UI,
        "tags": ["flutter", "ui", "navigation", "overlay", "lessons-learned", "reclip"],
    },
    {
        "title": "Flutter Share Intent & Deep Link Patterns",
        "search_query": "Flutter Share Intent Deep Link Patterns",
        "content": LESSON_3_SHARE_INTENT,
        "tags": ["flutter", "share-intent", "deep-link", "navigation", "lessons-learned", "reclip"],
    },
    {
        "title": "Android Platform — HTTP, SafeArea, Release Build",
        "search_query": "Android Platform HTTP SafeArea Release Build",
        "content": LESSON_4_ANDROID_PLATFORM,
        "tags": ["flutter", "android", "http", "release", "safearea", "lessons-learned", "reclip"],
    },
    {
        "title": "Flutter Dependencies & CI/CD Pitfalls",
        "search_query": "Flutter Dependencies CI/CD Pitfalls",
        "content": LESSON_5_DEPENDENCIES_CICD,
        "tags": ["flutter", "cicd", "dependencies", "kotlin", "android", "lessons-learned", "reclip"],
    },
]


def main():
    print("=" * 60)
    print("Syncing UNIVERSAL lessons to SimpleNote")
    print("=" * 60)

    for note_info in NOTES:
        title = note_info["title"]
        search_query = note_info["search_query"]
        content = note_info["content"]
        tags = note_info["tags"]

        print(f"\n--- {title} ---")

        # Search for existing note
        results = search_notes(search_query)

        if results:
            note_id = results[0]["id"]
            print(f"  Found existing note: {note_id}")
            print(f"  Updating...")
            update_result = update_note(note_id, content, tags)
            if "error" in update_result:
                print(f"  ❌ Update failed: {update_result['error']}")
            else:
                print(f"  ✅ Updated successfully")
        else:
            print(f"  No existing note found. Creating new...")
            create_result = create_note(content, tags)
            if "error" in create_result:
                print(f"  ❌ Create failed: {create_result['error']}")
            else:
                print(f"  ✅ Created successfully")

    print("\n" + "=" * 60)
    print("Done! All universal lessons synced to SimpleNote.")
    print("=" * 60)


if __name__ == "__main__":
    main()
