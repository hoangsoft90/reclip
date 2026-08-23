# Code Patterns

## Patterns đang dùng

### 1. Provider Pattern (Riverpod)
Mọi service được inject qua Riverpod Provider. Không dùng dependency injection framework riêng.

```dart
// Definition
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Usage in widget
final db = ref.watch(databaseProvider);
```

### 2. Stream Pattern (Drift)
Database queries dùng `watch()` để reactive stream. UI dùng `StreamBuilder` để tự động rebuild.

```dart
StreamBuilder<List<SavedItem>>(
  stream: widget.db.select(widget.db.savedItems).watch(),
  builder: (context, snapshot) { ... },
)
```

### 3. Adapter Pattern (Metadata)
5 adapter riêng implement cùng interface `PlatformAdapter`. Factory route theo platform.

```dart
abstract class PlatformAdapter {
  Duration get timeout;
  Future<MetadataResult> fetch(String canonicalUrl);
}
```

### 4. Fallback Chain Pattern
Mọi failure có fallback: adapter → retry → OpenGraph → Quick Link Card.

```
fetch() → [fail] → retry(2x) → openGraphFallback() → [fail] → Quick Link Card UI
```

### 5. Overlay Pattern (Toast)
Toast dùng `OverlayEntry` + `Overlay.of(context)` thay vì `SnackBar`. Quản lý 1 entry duy nhất.

```dart
class QuickSaveToastOverlay {
  static OverlayEntry? _currentEntry;
  static void show(...) { _currentEntry?.remove(); ... }
}
```

### 6. ChangeNotifier Pattern (Filter)
`FacetFilterController` extends `ChangeNotifier` — dùng `ListenableBuilder` trong UI.

```dart
class FacetFilterController extends ChangeNotifier {
  FacetFilterState _state = const FacetFilterState();
  void togglePlatform(PlatformEnum p) { ... notifyListeners(); }
}
```

## Patterns KHÔNG dùng

| Pattern | Lý do |
|---------|-------|
| Repository Pattern | DAO gọi thẳng từ Service — chưa cần abstraction |
| BLoC/Cubit | Riverpod đủ đơn giản cho MVP |
| UseCase Pattern | Quá nhiều lớp trừu tượng cho quy mô hiện tại |
| GetIt / Injectable | Riverpod đã làm DI |
| Freezed / json_serializable | Không có API response cần serialize |

## Naming Conventions

| Item | Convention | Ví dụ |
|------|-----------|-------|
| Files | snake_case | `quick_save_service.dart` |
| Classes | PascalCase | `QuickSaveService` |
| Variables | camelCase | `canonicalUrl` |
| Constants | camelCase (static const) | `AppStrings.savedToast` |
| Enums | PascalCase | `PlatformEnum.reddit` |
| Providers | camelCase + Provider suffix | `databaseProvider` |

## File Naming
- Screens: `*_screen.dart` (e.g., `library_screen.dart`)
- Widgets: descriptive names (e.g., `quick_link_card.dart`)
- Services: `*_service.dart` (e.g., `quick_save_service.dart`)
- Adapters: `*_adapter.dart` (e.g., `reddit_adapter.dart`)
- Controllers: `*_controller.dart` (e.g., `facet_filter_controller.dart`)
