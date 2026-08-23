# AGENTS.md — AI Agent Instructions

> This file tells AI agents how to work with this project.
> Read this FIRST before any code change.

## Project: Reclip
**Save what you discover. Find it again.**

Personal social library app — save URLs from Reddit/Instagram/TikTok/YouTube/X, organize, find again.

## Quick Context
- **Framework:** Flutter 3.24, Dart >=3.4.0
- **State:** flutter_riverpod ^2.5.1
- **DB:** drift (SQLite) + FTS5
- **Platform:** Android only (API 26+)
- **Current Phase:** Phase 2 (Enrichment) ✅ Done
- **Next Phase:** Phase 3 (Value Loop — Notes, Rediscovery, Backup)

## Rules — MUST Follow

### Build
- **NEVER build locally.** Push to GitHub Actions.
- Workflow: `.github/workflows/build-debug-apk.yml`
- Check build: `curl -s -H "Authorization: token $GH_TOKEN" "https://api.github.com/repos/hoangsoft90/reclip/actions/runs?per_page=1"`

### Code Conventions
- **All UI strings** in `lib/core/constants/app_strings.dart` — NEVER hardcode in widgets
- **All enums** in `lib/core/database/database.dart`
- **IDs** via `IdGenerator.generate()` (UUID v4)
- **DB access** via direct DAO methods in `AppDatabase` (no repository pattern)
- **Metadata adapters** MUST NEVER throw — catch all, return `MetadataResult.failed()`

### Folder Structure (Feature-First)
```
lib/features/<feature>/
├── presentation/     # UI widgets
├── application/      # Business logic
└── domain/           # Interfaces, models (only in metadata/)
```

### Testing
- Run `flutter test` before every push
- Unit tests in `test/core/` for parsers
- Current: 25 tests passing

### Git
- Commit messages: conventional (feat/fix/docs/chore)
- Always add 🤖 footer
- Push to `main` branch

## Key Files
| File | Purpose |
|------|---------|
| `lib/main.dart` | Entry point + all providers |
| `lib/app.dart` | MaterialApp + lifecycle + share intent |
| `lib/core/database/database.dart` | All 6 tables + DAO + FTS5 |
| `lib/core/url/url_normalizer.dart` | Clean tracking params |
| `lib/core/url/platform_detector.dart` | Detect platform from URL |
| `lib/features/share_intent/quick_save_service.dart` | Quick Save + dedup |
| `lib/features/metadata/metadata_adapter_factory.dart` | Adapter routing |
| `lib/features/metadata/application/enrichment_orchestrator.dart` | Background metadata |

## Skills
Load before working:
- `reclip-build` — Build workflow + lessons learned
- `reclip-project` — Project conventions

## OpenSpec
20 capability specs in `openspec/specs/` — read before modifying any feature.

## Documentation
- `.project/` — Full project knowledge base (15 files)
- `guide.md` — User-facing guide
- `plan1_final_v2.md` — Master plan (outside repo, in htdocs_apps/reclip/)
