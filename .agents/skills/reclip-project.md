---
name: reclip-project
description: Reclip mobile app project context — architecture, conventions, build workflow
---

# Reclip Project Skill

## Project
- **App:** Reclip — Save what you discover, find it again
- **Type:** Android mobile app (Flutter)
- **Package:** com.reclip
- **Repo:** https://github.com/hoangsoft90/reclip
- **Branch:** main

## Tech Stack
- Flutter 3.x, Dart 3.4+
- Drift (SQLite) for local database
- Riverpod for state management
- Dio for HTTP
- flutter_cache_manager for thumbnail caching
- Sentry for crash monitoring (sentry_flutter ^8.9.0)

## Architecture
- **Pattern:** Feature-first, simple Provider-based DI
- **Structure:** `lib/core/` (shared) + `lib/features/` (feature modules)
- **Data flow:** Service → Database → StreamBuilder → UI

## Build Workflow
- **NEVER build locally** — no Android SDK, no Gradle
- **ALWAYS push to GitHub → GitHub Actions builds debug APK**
- Build script: `.github/workflows/build-debug-apk.yml`
- Repo token in `.agents/skills/reclip-build.md`

## Key Commands
```bash
# Run tests locally
flutter test

# Check code (no build needed)
dart analyze

# Push to GitHub (triggers build)
git add -A && git commit -m "..." && git push origin main
```

## Current Phase: Phase 3 — Value Loop (DONE)
Phase 3 features:
1. **Rediscovery Engine** — resurface items saved >24h, scoring algorithm
2. **Edit Note/Why** — edit from Item Detail, shared widget
3. **Local Backup/Restore** — JSON export, merge import, share_plus
4. **Retention Metrics** — retrieval rate, week-1 retention (debug only)

## Folder Structure
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/ (app_strings.dart, platforms.dart)
│   ├── database/ (database.dart — Drift schema)
│   ├── network/ (http_client.dart, connectivity_service.dart)
│   ├── url/ (url_normalizer.dart, platform_detector.dart)
│   └── utils/ (id_generator.dart)
├── features/
│   ├── backup/ (export/import services, settings screen)
│   ├── item_detail/ (detail screen, open_original, edit_note_why)
│   ├── library/ (library screen, filter, quick_link_card, offline_banner)
│   ├── metadata/ (adapters, orchestrator, thumbnail, metrics)
│   ├── quick_save_toast/ (toast overlay)
│   ├── rediscovery/ (score, service, resurface_section)
│   ├── search/ (FTS5 search)
│   ├── share_intent/ (handler, quick_save_service)
│   └── smart_save/ (bottom_sheet, shared_note_why_fields)
└── core/
    └── database/
        └── tables/ (resurface_history, app_events)
```

## DB Schema (8 tables)
- saved_items, collections, item_collections, tags, item_tags, thumbnails
- resurface_history (Phase 3), app_events (Phase 3)

## OpenSpec
20 spec files in `openspec/specs/` — baseline for Phase 0-2.

## Related Skills
- `reclip-lessons` — **MUST READ** before writing code. All bugs, crashes, and anti-patterns found in this project.
- `reclip-build` — Build workflow + Gradle/Kotlin lessons learned

## Conventions
- Android manifest: `<queries>` required for url_launcher (Android 11+)
- Android manifest: `network_security_config.xml` + `usesCleartextTraffic=true` for HTTP
- No local APK builds — only GitHub Actions
- `flutter_cache_manager` for thumbnail caching (200MB LRU)
- Drift database with FTS5 for search
- Share Intent receives text only (no images)
- Sentry DSN in `lib/main.dart` — do NOT commit DSN to public repos if repo is public
