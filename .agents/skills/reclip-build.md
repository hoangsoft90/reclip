---
name: reclip-build
description: Build debug APK for Reclip Flutter app using GitHub Actions. Use when user says "build apk", "build debug", "push and build", or needs to verify Android build. NEVER build locally — always push to GitHub and let CI build.
---

# Reclip Build Skill

## Project Info
- **Repo:** https://github.com/hoangsoft90/reclip
- **Branch:** main
- **Framework:** Flutter 3.24+ with Drift (SQLite)
- **Build:** Gradle 8.9 + AGP 8.7.0 (no EAS token needed)
- **gh_token:** Ask user if not in environment

## Build Workflow

### Step 1: Run unit tests first
```bash
cd /home/kythuat_hoangweb/reclip
/google/flutter/bin/flutter test
```

### Step 2: Run code generation (if database.dart changed)
```bash
/google/flutter/bin/dart run build_runner build --delete-conflicting-outputs
```

### Step 3: Commit + Push
```bash
cd /home/kythuat_hoangweb/reclip
git add -A
git commit -m "your message"
git push origin main
```

### Step 4: Monitor GitHub Actions
- Workflow: `.github/workflows/build-debug-apk.yml`
- Artifact: `reclip-debug-apk` (retained 7 days)
- Download from: https://github.com/hoangsoft90/reclip/actions

## Key Rules
1. **NEVER build APK locally** — no Android SDK on this machine
2. **Always push to GitHub** — CI handles the build
3. **Don't wait for build** — just push and tell user to check Actions
4. **gh_token** — ask user if not in environment

## ⚠️ ALL Lessons Learned (CRITICAL)

### 1. NEVER gitignore gradle wrapper files
```
/android/gradlew
/android/gradlew.bat
/android/gradle/
```

### 2. Gradle + AGP + Flutter version MUST match
| Component | WRONG | CORRECT |
|-----------|-------|--------|
| Gradle | 9.3.1 | 8.9 |
| AGP | 9.1.0 | 8.7.0 |
| Kotlin | 2.4.0 | 2.0.21 |

### 3. JVM target mismatch — use gradle.properties
```properties
kotlin.jvm.target.validation.mode=warning
```

### 4. Kotlin plugin MUST be in app/build.gradle.kts
```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")  // <-- ADD THIS!
    id("dev.flutter.flutter-gradle-plugin")
}
```
**Error:** `ClassNotFoundException: com.xxx.MainActivity`

### 5. url_launcher needs `<queries>` in AndroidManifest.xml
```xml
<!-- Required for url_launcher to work on Android 11+ -->
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" />
    </intent>
</queries>
```
**Error:** `UrlLauncher: component name for ... is null`
**Why:** Android 11+ requires apps to declare which other apps they query.

### 6. DON'T use `kotlin { compilerOptions { ... } }` in app/build.gradle.kts
### 7. DON'T use `afterEvaluate` with `evaluationDependsOn`
### 8. Build output path may be redirected
### 9. database.g.dart must be committed

## Pre-push Checklist
```
[ ] flutter test — all pass
[ ] Gradle version — 8.9
[ ] AGP version — 8.7.0
[ ] .gitignore — gradlew NOT ignored
[ ] app/build.gradle.kts — has Kotlin plugin
[ ] AndroidManifest.xml — has <queries> for url_launcher
[ ] gradle.properties — kotlin.jvm.target.validation.mode=warning
[ ] pubspec.yaml — package_info_plus pinned to ^8.1.3 (9.x crashes Kotlin compiler)
```
