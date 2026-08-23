#!/usr/bin/env python3
"""
Sync lessons learned to Simplenote via MCP.
Usage: python3 scripts/sync_simplenote.py
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
        # Parse the output
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
    """Search notes by query."""
    result = mcpc_call("search_notes", {"query": query, "limit": 10})
    if isinstance(result, dict) and "results" in result:
        return result["results"]
    return []


def create_note(content: str, tags: list) -> dict:
    """Create a new note."""
    return mcpc_call("create_note", {"content": content, "tags": tags})


def update_note(note_id: str, content: str, tags: list = None) -> dict:
    """Update an existing note."""
    args = {"id": note_id, "content": content}
    if tags:
        args["tags"] = tags
    return mcpc_call("update_note", args)


# === LESSONS LEARNED ===

FLUTTER_CI_CD_LESSON = """# Flutter CI/CD — Build Debug APK on GitHub Actions

> Universal lessons for ANY Flutter project. Not project-specific.

## 1. NEVER gitignore gradle wrapper files

```bash
# WRONG - breaks CI!
/android/gradlew
/android/gradlew.bat
/android/gradle/

# CORRECT
!/android/gradlew
!/android/gradlew.bat
!/android/gradle/
```

**Why:** CI runs `./gradlew assembleDebug` — needs gradlew script + wrapper jar.

## 2. Gradle + AGP + Flutter version MUST match

| Component | WRONG | CORRECT (Flutter 3.24) |
|-----------|-------|--------|
| Gradle | 9.3.1 | 8.9 |
| AGP | 9.1.0 | 8.7.0 |
| Kotlin | 2.4.0 | 2.0.21 |

**Error:** `unable to resolve class groovy.xml.QName`
**Why:** Gradle 9.x removed `groovy.xml.QName` which `flutter.groovy` imports.

## 3. JVM target mismatch — use gradle.properties

```properties
# gradle.properties
kotlin.jvm.target.validation.mode=warning
```

**Why:** Plugins like `receive_sharing_intent` use Java 1.8, main app uses Kotlin 17. Cannot override plugin's compileOptions (finalized).

## 4. Kotlin plugin MUST be explicitly in app/build.gradle.kts

```kotlin
// WRONG - ClassNotFoundException: MainActivity
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

// CORRECT
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")  // <-- ADD THIS!
    id("dev.flutter.flutter-gradle-plugin")
}
```

**Error:** `ClassNotFoundException: com.xxx.MainActivity`
**Why:** Without explicit Kotlin plugin, Kotlin source files (MainActivity.kt) are NOT compiled into APK.

## 5. DON'T use `kotlin { compilerOptions { ... } }` in app/build.gradle.kts

```kotlin
// WRONG - "Unresolved reference"
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

// CORRECT
android {
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}
```

## 6. DON'T use `afterEvaluate` with `evaluationDependsOn`

```kotlin
// WRONG - "Cannot run Project.afterEvaluate when already evaluated"
subprojects {
    project.evaluationDependsOn(":app")
}
subprojects {
    afterEvaluate { ... }
}
```

## 7. Build output path may be redirected

If `build.gradle.kts` redirects buildDir, APK is at:
`build/app/outputs/flutter-apk/app-debug.apk`
NOT `android/app/build/outputs/apk/debug/app-debug.apk`

## 8. database.g.dart must be committed

Generated code (Drift, BuildRunner) must be in repo to prevent first-build failures.

## Pre-push Checklist

```
[ ] flutter test — all pass
[ ] Gradle version — 8.9 (not 9.x)
[ ] AGP version — 8.7.0 (not 9.x)
[ ] .gitignore — gradlew NOT ignored
[ ] app/build.gradle.kts — has Kotlin plugin
[ ] gradle.properties — kotlin.jvm.target.validation.mode=warning
[ ] database.g.dart — committed (if using Drift/BuildRunner)
```

---
Last updated: August 2026
"""


def main():
    print("=== Syncing Flutter CI/CD lessons to Simplenote ===")

    # Search for existing note
    results = search_notes("Flutter CI/CD Build Debug APK GitHub Actions")

    if results:
        note_id = results[0]["id"]
        print(f"Found existing note: {note_id}")
        print("Updating...")
        update_result = update_note(note_id, FLUTTER_CI_CD_LESSON, [
            "flutter", "cicd", "github-actions", "lessons-learned",
            "gradle", "kotlin", "android", "reclip"
        ])
        print(f"Update result: {json.dumps(update_result, indent=2)}")
    else:
        print("No existing note found. Creating new...")
        create_result = create_note(FLUTTER_CI_CD_LESSON, [
            "flutter", "cicd", "github-actions", "lessons-learned",
            "gradle", "kotlin", "android", "reclip"
        ])
        print(f"Create result: {json.dumps(create_result, indent=2)}")

    print("\n=== Done! ===")


if __name__ == "__main__":
    main()
