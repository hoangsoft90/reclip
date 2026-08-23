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
**Why:** CI runs `./gradlew assembleDebug` — needs gradlew script + wrapper jar.

### 2. Gradle + AGP + Flutter version MUST match
| Component | WRONG | CORRECT |
|-----------|-------|--------|
| Gradle | 9.3.1 | 8.9 |
| AGP | 9.1.0 | 8.7.0 |
| Kotlin | 2.4.0 | 2.0.21 |

**Error:** `unable to resolve class groovy.xml.QName`
**Why:** Gradle 9.x removed `groovy.xml.QName` which `flutter.groovy` imports.

### 3. JVM target mismatch — use `kotlin.jvm.target.validation.mode=warning`
```properties
# gradle.properties
kotlin.jvm.target.validation.mode=warning
```
**Why:** `receive_sharing_intent` uses Java 1.8, main app uses Kotlin 17. Cannot override plugin's compileOptions (finalized). Set validation to warning.

### 4. DON'T use `kotlin { compilerOptions { ... } }` in app/build.gradle.kts
```kotlin
// WRONG - causes "Unresolved reference" error
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

// CORRECT - use compileOptions only
android {
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}
```

### 5. DON'T use `afterEvaluate` with `evaluationDependsOn`
```kotlin
// WRONG - "Cannot run Project.afterEvaluate when already evaluated"
subprojects {
    project.evaluationDependsOn(":app")
}
subprojects {
    afterEvaluate { ... }
}

// CORRECT - use plugins.withId (but be careful with extension types)
subprojects {
    plugins.withId("com.android.application") {
        // configure...
    }
}
```

### 6. Build output path may be redirected
```kotlin
// In android/build.gradle.kts
rootProject.layout.buildDirectory.value(newBuildDir)  // Redirects output!
```
**APK location:** `build/app/outputs/flutter-apk/app-debug.apk` (NOT `android/app/build/...`)

### 7. database.g.dart must be committed
Drift generated code must be in repo to prevent first-build failures.

### 8. Don't ignore too aggressive
**KHÔNG BAO GIỜ ignore:** gradlew, gradle/, .g.dart files, pubspec.lock

## Pre-push Checklist
```
[ ] flutter test — all pass
[ ] Kiem tra Gradle version — 8.9
[ ] Kiem tra AGP version — 8.7.0
[ ] Kiem tra .gitignore — gradlew NOT ignored
[ ] Kiem tra database.g.dart — committed
[ ] Kiem tra gradle.properties — kotlin.jvm.target.validation.mode=warning
[ ] KHONG co kotlin { compilerOptions } trong app/build.gradle.kts
```
