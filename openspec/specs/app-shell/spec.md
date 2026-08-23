# app-shell

## Purpose
Entry point của app: ProviderScope, Riverpod providers, MaterialApp, navigation (IndexedStack + NavigationBar), lifecycle hooks.

## Requirements

### REQ-1: Provider definitions
`main.dart` định nghĩa tất cả providers chính.

**Providers:**
| Provider | Type | Dependencies |
|----------|------|-------------|
| `databaseProvider` | `Provider<AppDatabase>` | None (singleton, dispose on close) |
| `quickSaveServiceProvider` | `Provider<QuickSaveService>` | databaseProvider |
| `metadataAdapterFactoryProvider` | `Provider<MetadataAdapterFactory>` | HttpClient.instance |
| `thumbnailDownloadServiceProvider` | `Provider<ThumbnailDownloadService>` | databaseProvider |
| `enrichmentOrchestratorProvider` | `Provider<EnrichmentOrchestrator>` | database, adapterFactory, thumbnailService |
| `shareIntentHandlerProvider` | `Provider<ShareIntentHandler>` | quickSaveService |

- Reference: `lib/main.dart:9-50`

### REQ-2: App entry point
`main()` gọi `WidgetsFlutterBinding.ensureInitialized()` → `runApp(ProviderScope(child: ReclipApp()))`.

**Scenario: App khởi động**
- Given: User mở app
- When: `main()` chạy
- Then: Khởi tạo Flutter binding → tạo ProviderScope → mount ReclipApp
- Reference: `lib/main.dart:52-58`

### REQ-3: Navigation tabs
Bottom NavigationBar với 2 tabs: Library và Search. Dùng `IndexedStack` giữ state.

**Scenario: Chuyển tab**
- Given: Đang ở tab Library
- When: Bấm tab Search
- Then: `_currentIndex = 1` → `IndexedStack` hiển thị SearchScreen, LibraryScreen vẫn giữ state
- Reference: `lib/app.dart:93-110`

### REQ-4: Lifecycle hooks
`WidgetsBindingObserver` lắng nghe `didChangeAppLifecycleState`.

**Scenario: App resume**
- Given: App bị pause (user mở app khác)
- When: User quay lại app → `AppLifecycleState.resumed`
- Then: Gọi `_triggerEnrichment()` → process pending metadata
- Reference: `lib/app.dart:39-43`

### REQ-5: Share intent listener
`app.dart` lắng nghe `ShareIntentHandler.onShare` stream → hiển thị Toast.

**Scenario: Share URL**
- Given: User share URL từ app khác
- When: `handler.onShare` emit URL
- Then: Query DB → check `isNew` → hiện QuickSaveToastOverlay
- Reference: `lib/app.dart:45-63`

### REQ-6: Theme
MaterialApp dùng Material 3, `colorSchemeSeed: Colors.black`, brightness light.

**Scenario: Theme settings**
- Given: App render
- When: MaterialApp build
- Then: `ThemeData(colorSchemeSeed: Colors.black, useMaterial3: true, brightness: Brightness.light)`
- Reference: `lib/app.dart:83-88`

## Cần làm rõ
- Provider `shareIntentHandlerProvider` tự động gọi `handler.init()` khi tạo — nghĩa là share intent listener được setup ngay khi ProviderScope mount. Nếu có lỗi init, sẽ crash app startup.
- `databaseProvider` tạo `AppDatabase()` mới mỗi lần — nhưng thực tế Riverpod Provider caching đảm bảo chỉ tạo 1 lần. `ref.onDispose(() => db.close())` đảm bảo DB được đóng khi ProviderScope bị dispose.
- Không dùng GoRouter cho navigation mặc dù có trong dependencies — dùng Navigator.push trực tiếp. GoRouter available cho tương lai.
