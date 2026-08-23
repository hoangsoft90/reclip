# Quản lý Trạng thái & Routing

## State Management: flutter_riverpod

### Providers đang dùng

| Provider | Type | Purpose |
|----------|------|---------|
| `databaseProvider` | `Provider<AppDatabase>` | Singleton DB instance |
| `quickSaveServiceProvider` | `Provider<QuickSaveService>` | Quick Save business logic |
| `metadataAdapterFactoryProvider` | `Provider<MetadataAdapterFactory>` | Adapter routing |
| `thumbnailDownloadServiceProvider` | `Provider<ThumbnailDownloadService>` | Thumbnail download |
| `enrichmentOrchestratorProvider` | `Provider<EnrichmentOrchestrator>` | Metadata processing queue |
| `shareIntentHandlerProvider` | `Provider<ShareIntentHandler>` | Share intent listener |

### Provider Dependency Graph

```
databaseProvider
├── quickSaveServiceProvider
├── thumbnailDownloadServiceProvider
└── enrichmentOrchestratorProvider
        ├── metadataAdapterFactoryProvider (→ HttpClient.instance)
        └── thumbnailDownloadServiceProvider

shareIntentHandlerProvider
└── quickSaveServiceProvider
```

### Provider Pattern
- **Không dùng StateNotifier/StateProvider** ở Phase 0-2 — provider chỉ inject dependencies
- **Dùng `ref.watch()`** trong widgets để reactive rebuild
- **Dùng `ref.read()`** trong event handlers để avoid rebuild

## Routing

### Navigation Method: Navigator 2.0 (Material)

App dùng `IndexedStack` + `NavigationBar` cho tab navigation, `Navigator.push` cho detail screens.

```
 MaterialApp
    └── Scaffold
         ├── IndexedStack (tab 0: Library, tab 1: Search)
         └── NavigationBar
```

### Navigation Flows

| From | To | Method |
|------|-----|--------|
| Library → Item Detail | `Navigator.push(MaterialPageRoute)` | user tap item |
| Search → Item Detail | `Navigator.push(MaterialPageRoute)` | user tap result |
| Toast → Smart Save | `showModalBottomSheet` | user tap "Add details" |
| Item Detail → Smart Save | `showModalBottomSheet` | user tap "Add details" |
| Item Detail → Browser | `url_launcher` (external) | user tap "Open Original" |

### Deep Link
- **Chưa implement** — `_buildDeepLink()` trong `OpenOriginalService` trả về `null`
- Luôn fallback sang browser qua `url_launcher`
- Planned: `instagram://`, `tiktok://`, `reddit://` schemes (Phase 2+)

### GoRouter
- Có trong dependencies (`^14.2.0`) nhưng **chưa dùng**
- Available cho tương lai nếu cần complex routing
