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
- **HTTP:** Dio ^5.7.0
- **Platform:** Android only (API 26+)
- **Current Phase:** Phase 2 (Enrichment) ✅ Done
- **Next Phase:** Phase 3 (Value Loop — Notes, Rediscovery, Backup)
- **Repo:** https://github.com/hoangsoft90/reclip
- **Branch:** main (single branch workflow)

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
- **Dedup** by `canonical_url` (no UNIQUE constraint in DB — logic in service layer)

### Folder Structure (Feature-First)
```
lib/
├── main.dart + app.dart          # Entry + providers + navigation
├── core/                         # Shared: DB, URL, network, constants
│   ├── constants/                # AppStrings, PlatformInfo
│   ├── database/                 # Drift 6 tables + FTS5 + DAO
│   ├── network/                  # Dio, ConnectivityService
│   ├── url/                      # UrlNormalizer, PlatformDetector
│   └── utils/                    # IdGenerator
└── features/                     # Feature modules
    ├── share_intent/             # Receive share + quick save
    ├── library/                  # Grid/List view + filter + thumbnails
    ├── search/                   # FTS5 search
    ├── item_detail/              # Detail + Open Original
    ├── smart_save/               # BottomSheet add details
    ├── metadata/                 # 5 adapters + orchestrator + thumbnails
    └── quick_save_toast/         # Toast overlay
```

### Testing
- Run `flutter test` before every push
- Unit tests in `test/core/` for parsers
- Current: **25 tests passing**

### Git
- Commit messages: conventional (feat/fix/docs/chore)
- Always add 🤖 footer + Co-Authored-By
- Push to `main` branch
- Never force push

## Key Files
| File | Purpose |
|------|---------|
| `lib/main.dart` | Entry point + all 6 Riverpod providers |
| `lib/app.dart` | MaterialApp + NavigationBar + lifecycle + share listener |
| `lib/core/database/database.dart` | 6 tables + DAO + FTS5 + triggers |
| `lib/core/url/url_normalizer.dart` | Clean 16 tracking params → canonical URL |
| `lib/core/url/platform_detector.dart` | Detect Reddit/IG/TikTok/YouTube/X from URL |
| `lib/features/share_intent/quick_save_service.dart` | Quick Save + dedup (<300ms) |
| `lib/features/share_intent/share_intent_handler.dart` | Receive Android share intent |
| `lib/features/metadata/metadata_adapter_factory.dart` | Route to adapter by platform |
| `lib/features/metadata/application/enrichment_orchestrator.dart` | Queue processor (max 3 concurrent, retry 2x) |
| `lib/features/metadata/application/thumbnail_download_service.dart` | Download + 200MB LRU cache |
| `lib/features/library/presentation/library_screen.dart` | Main library UI with thumbnails + filter |

## Skills
Load before working:
- `reclip-build` — Build workflow + Gradle/Kotlin lessons learned
- `reclip-project` — Project conventions + architecture

## OpenSpec
**20 capability specs** in `openspec/specs/` — read before modifying any feature.

## Documentation
| File | Purpose |
|------|---------|
| `.project/README.md` | Knowledge base entry point |
| `.project/overview.md` | App goals, tech stack, phases |
| `.project/architecture.md` | Folder structure, data flow, DB schema |
| `.project/modules/*.md` | Per-feature documentation |
| `.project/openspec.md` | Progress tracker, known bugs |
| `context.md` | Project context summary |
| `working.md` | Current working state |
| `operating_rules.md` | Never/always do rules |
| `guide.md` | User-facing guide |

## Recent Changes
- Thumbnail display connected to DB (Library + ItemDetail)
- Smart Save button now persists note + whySaved to DB
- OpenSpec baseline: 20 capability specs
- Knowledge base: `.project/` with 15 files
- Memory files: AGENTS.md, CLAUDE.md, context.md, working.md, operating_rules.md
