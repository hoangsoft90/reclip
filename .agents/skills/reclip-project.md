---
name: reclip-project
description: Reclip project conventions and architecture. Use when working on Reclip codebase to follow existing patterns, naming, and structure.
---

# Reclip Project Conventions

## Architecture
- **State Management:** flutter_riverpod (Provider-based)
- **Database:** Drift (SQLite) with FTS5 full-text search
- **Navigation:** Material + Navigator (GoRouter available but not primary)
- **Testing:** flutter_test + mocktail

## Code Conventions
- **Enums:** Defined in `lib/core/database/database.dart` (PlatformEnum, ContentTypeEnum, etc.)
- **Strings:** All UI text in `lib/core/constants/app_strings.dart` — NEVER hardcode in widgets
- **IDs:** UUID v4 via `IdGenerator.generate()` in `lib/core/utils/id_generator.dart`
- **Database access:** Direct DAO methods in `AppDatabase` class (no repository pattern yet)

## Folder Structure (Feature-First)
```
lib/features/<feature>/
├── presentation/     # UI widgets
│   ├── <screen>.dart
│   └── widgets/      # (optional)
├── application/      # Business logic, controllers
│   └── <service>.dart
```

## Key Files
| File | Purpose |
|------|---------|
| `lib/core/database/database.dart` | All Drift tables + DAO methods |
| `lib/core/url/url_normalizer.dart` | Clean tracking params → canonical_url |
| `lib/core/url/platform_detector.dart` | Detect platform from URL |
| `lib/features/share_intent/quick_save_service.dart` | Quick Save flow with dedup |
| `lib/features/item_detail/application/open_original_service.dart` | Deep link + browser fallback |

## Testing Requirements
- Unit tests in `test/core/` for parsers
- Widget tests for Toast/Sheets when complex
- Run `flutter test` before every push

## Build Rules
- **NEVER build locally** — push to GitHub Actions
- Workflow: `.github/workflows/build-debug-apk.yml`
- Artifact: `reclip-debug-apk` on GitHub Actions
