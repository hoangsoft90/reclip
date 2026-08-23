# CLAUDE.md

> Claude Code project instructions. See also: AGENTS.md

## Project
Reclip — Personal social library Flutter app (Android).
Save URLs from social media → organize → find again.

## Stack
Flutter 3.24 | Riverpod | Drift/SQLite+FTS5 | Dio | Android only

## Status
Phase 0 ✅ → Phase 1 ✅ → Phase 2 ✅ → Phase 3 ⏳

## Critical Rules
1. **NEVER build APK locally** — push to GitHub Actions
2. **NEVER hardcode strings** — use `AppStrings`
3. **NEVER throw in adapters** — return `MetadataResult.failed()`
4. **Run `flutter test` before push** (25 tests)
5. **Read `.agents/skills/reclip-project.md`** before coding

## Build
```bash
# DON'T. Push to GitHub Actions instead.
# .github/workflows/build-debug-apk.yml
```

## Test
```bash
flutter test  # 25 tests, must all pass
```

## Code Gen
```bash
dart run build_runner build  # drift code generation
```

## Key Paths
- Entry: `lib/main.dart` + `lib/app.dart`
- DB: `lib/core/database/database.dart`
- Quick Save: `lib/features/share_intent/quick_save_service.dart`
- Metadata: `lib/features/metadata/`
- OpenSpec: `openspec/specs/`
- Knowledge: `.project/`
- Skills: `.agents/skills/`
