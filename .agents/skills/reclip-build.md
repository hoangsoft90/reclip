---
name: reclip-build
description: Build debug APK for Reclip Flutter app using GitHub Actions. Use when user says "build apk", "build debug", "push and build", or needs to verify Android build. NEVER build locally — always push to GitHub and let CI build.
---

# Reclip Build Skill

## Project Info
- **Repo:** https://github.com/hoangsoft90/reclip
- **Branch:** main
- **Framework:** Flutter 3.24+ with Drift (SQLite)
- **Build:** Gradle directly (no EAS token needed)
- **gh_token:** Ask user if not in environment

## Build Workflow

### Step 1: Run unit tests first
```bash
cd /home/kythuat_hoangweb/reclip
/google/flutter/bin/flutter test
```
All 23 tests must pass before pushing.

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

## ⚠️ Lessons Learned (CRITICAL)

### 1. NEVER gitignore gradle wrapper files
```
# WRONG - will break CI build!
/android/gradlew
/android/gradlew.bat
/android/gradle/

# CORRECT - keep them, only ignore build artifacts
!/android/gradlew
!/android/gradlew.bat
!/android/gradle/
```
**Why:** CI runs `./gradlew assembleDebug` — needs gradlew script + wrapper jar.

### 2. database.g.dart must be committed
Drift generated code (`lib/core/database/database.g.dart`) must be in repo.
CI runs `build_runner` anyway, but having it committed prevents first-build failures.

### 3. JVM Target Mismatch (Gradle)
**Lỗi:** `compileDebugJavaWithJavac (Java 1.8) vs compileDebugKotlin (Kotlin 17)`
**Fix:** Trong `android/build.gradle`, thêm block:
```groovy
subprojects {
    afterEvaluate { project ->
        if (project.hasProperty("android")) {
            project.android {
                compileOptions {
                    sourceCompatibility JavaVersion.VERSION_17
                    targetCompatibility JavaVersion.VERSION_17
                }
            }
        }
        if (project.plugins.hasPlugin("kotlin-android")) {
            project.tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile).configureEach {
                kotlinOptions {
                    jvmTarget = "17"
                }
            }
        }
    }
}
```
**Cảnh báo:** KHÔNG dùng `gradle.projectsEvaluated` — nó trigger early evaluation và crash flutter.groovy.

### 4. Unused import warnings
```bash
flutter analyze
```
Xoá tất cả unused import. Một số workflow dùng `--fatal-warnings` sẽ fail.

### 5. Don't ignore too aggressively
Khi tạo .gitignore cho Flutter, chỉ ignore:
- Build outputs (`/build/`, `android/app/build/`)
- IDE files (`.idea/`, `.vscode/`)
- Generated plugins (`.flutter-plugins`)
- Local config (`local.properties`)

**KHÔNG BAO GIỜ ignore:** gradlew, gradle/, .g.dart files, pubspec.lock

## Pre-push Checklist
```
[ ] flutter analyze — 0 errors
[ ] flutter test — all pass
[ ] Kiem tra imports — khong co unused import
[ ] Kiem tra subprojects — JVM target match
[ ] Kiem tra .gitignore — gradlew NOT ignored
[ ] Kiem tra database.g.dart — committed
```

## File Structure
```
lib/
├── main.dart + app.dart
├── core/ (constants, database, url, utils)
├── features/ (share_intent, library, item_detail, search, etc.)
test/
├── core/ (url_normalizer_test, platform_detector_test)
├── features/share_intent/ (quick_save_service_test)
android/
├── gradlew          ← MUST be committed!
├── gradlew.bat      ← MUST be committed!
├── gradle/wrapper/  ← MUST be committed!
```
