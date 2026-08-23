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
- **HTTP Client:** Dio (shared HttpClient instance)
- **Image Cache:** flutter_cache_manager + cached_network_image
- **Connectivity:** connectivity_plus

## Code Conventions
- **Enums:** Defined in `lib/core/database/database.dart` (PlatformEnum, ContentTypeEnum, MetadataStatusEnum, etc.)
- **Strings:** All UI text in `lib/core/constants/app_strings.dart` — NEVER hardcode in widgets
- **IDs:** UUID v4 via `IdGenerator.generate()` in `lib/core/utils/id_generator.dart`
- **Database access:** Direct DAO methods in `AppDatabase` class (no repository pattern yet)
- **Metadata adapters:** MUST NEVER throw exceptions — catch all errors and return `MetadataResult.failed()`

## Folder Structure (Feature-First)
```
lib/
├── core/
│   ├── constants/          # AppStrings, PlatformInfo
│   ├── database/           # Drift AppDatabase + enums
│   ├── network/            # HttpClient (Dio), ConnectivityService
│   ├── url/                # UrlNormalizer, PlatformDetector
│   └── utils/              # IdGenerator
├── features/
│   ├── metadata/           # Phase 2 — Enrichment
│   │   ├── domain/         # PlatformAdapter, MetadataResult
│   │   ├── adapters/       # Reddit, YouTube, X, TikTok, Instagram, GenericOpenGraph
│   │   ├── application/    # EnrichmentOrchestrator, ThumbnailDownloadService, MetricsLogger
│   │   └── metadata_adapter_factory.dart
│   ├── share_intent/       # ShareIntentHandler, QuickSaveService
│   ├── library/            # LibraryScreen + FacetedFilter
│   │   ├── presentation/widgets/  # QuickLinkCard, OfflineBanner, FacetFilterBar
│   │   └── application/    # FacetFilterController
│   ├── item_detail/        # ItemDetailScreen, OpenOriginalService
│   ├── search/             # SearchScreen (FTS5)
│   ├── quick_save_toast/   # QuickSaveToast overlay
│   └── smart_save/         # SmartSaveBottomSheet
```

## Key Files
| File | Purpose |
|------|---------|
| `lib/core/database/database.dart` | All Drift tables + DAO methods |
| `lib/core/url/url_normalizer.dart` | Clean tracking params → canonical_url |
| `lib/core/url/platform_detector.dart` | Detect platform from URL |
| `lib/core/network/http_client.dart` | Shared Dio instance |
| `lib/core/network/connectivity_service.dart` | Online/offline detection |
| `lib/features/metadata/metadata_adapter_factory.dart` | Route to correct adapter |
| `lib/features/metadata/domain/platform_adapter.dart` | Abstract interface |
| `lib/features/metadata/adapters/*.dart` | 6 adapters (5 platform + 1 OG fallback) |
| `lib/features/metadata/application/enrichment_orchestrator.dart` | Process pending metadata queue |
| `lib/features/share_intent/quick_save_service.dart` | Quick Save flow with dedup |

## Testing Requirements
- Unit tests in `test/core/` for parsers
- Widget tests for Toast/Sheets when complex
- Run `flutter test` before every push

## Build Rules
- **NEVER build locally** — push to GitHub Actions
- Workflow: `.github/workflows/build-debug-apk.yml`
- Artifact: `reclip-debug-apk` on GitHub Actions
