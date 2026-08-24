# Reclip — Technical Brief: Phase 0 + Phase 1

> Tài liệu này bổ sung cho `plan1_final_v2.md`, viết ở mức chi tiết đủ để AI coding agent bắt tay code trực tiếp cho **Phase 0 (Technical Spike)** và **Phase 1 (Core Habit / MVP)** mà không cần hỏi lại nhiều. Chỉ cover 2 phase này — vì đây là phần nếu làm sai kiến trúc sẽ phải sửa lại toàn bộ sau.

---

## 0. Môi trường & Package Versions

```yaml
# pubspec.yaml — dependencies chính, chốt version tối thiểu
environment:
  sdk: '>=3.4.0 <4.0.0'
  flutter: '>=3.24.0'

dependencies:
  flutter_riverpod: ^2.5.1
  drift: ^2.20.0
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.4
  path: ^1.9.0
  receive_sharing_intent: ^1.8.0
  cached_network_image: ^3.4.0
  go_router: ^14.2.0
  uuid: ^4.4.2
  url_launcher: ^6.3.0
  android_intent_plus: ^5.1.0   # để mở deep link app cụ thể trên Android
  intl: ^0.19.0

dev_dependencies:
  build_runner: ^2.4.12
  drift_dev: ^2.20.0
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
```

**Target:** Android 8.0 (API 26) trở lên. iOS không nằm trong scope Phase 0–1.

---

## 1. Cấu trúc project (feature-first)

```
lib/
├── main.dart
├── app.dart                          # MaterialApp + GoRouter setup
│
├── core/
│   ├── constants/
│   │   ├── platforms.dart            # enum Platform + display info
│   │   └── app_strings.dart          # toàn bộ text hiển thị (xem mục 6)
│   ├── database/
│   │   ├── database.dart             # Drift AppDatabase
│   │   ├── tables/
│   │   │   ├── saved_items_table.dart
│   │   │   ├── collections_table.dart
│   │   │   ├── item_collections_table.dart
│   │   │   ├── tags_table.dart
│   │   │   ├── item_tags_table.dart
│   │   │   └── thumbnails_table.dart
│   │   └── daos/
│   │       ├── saved_items_dao.dart
│   │       ├── collections_dao.dart
│   │       └── tags_dao.dart
│   ├── url/
│   │   ├── url_normalizer.dart       # clean tracking params → canonical_url
│   │   └── platform_detector.dart    # regex/domain matching (xem mục 4)
│   └── utils/
│       └── id_generator.dart         # uuid v4 wrapper
│
├── features/
│   ├── share_intent/
│   │   ├── share_intent_handler.dart # nhận Intent từ receive_sharing_intent
│   │   └── quick_save_service.dart   # orchestrate: normalize → save → toast
│   │
│   ├── library/
│   │   ├── presentation/
│   │   │   ├── library_screen.dart
│   │   │   └── widgets/
│   │   │       ├── item_grid_card.dart
│   │   │       └── item_list_tile.dart
│   │   └── application/
│   │       └── library_controller.dart   # Riverpod StateNotifier
│   │
│   ├── item_detail/
│   │   ├── presentation/
│   │   │   └── item_detail_screen.dart
│   │   └── application/
│   │       └── open_original_service.dart  # deep-link + browser fallback
│   │
│   ├── quick_save_toast/
│   │   └── presentation/
│   │       └── quick_save_toast.dart       # overlay toast + "Add details"
│   │
│   ├── smart_save/
│   │   └── presentation/
│   │       └── smart_save_bottom_sheet.dart
│   │
│   └── search/
│       ├── presentation/
│       │   └── search_screen.dart
│       └── application/
│           └── search_controller.dart      # dùng FTS5 query
│
└── test/
    ├── core/
    │   ├── url_normalizer_test.dart
    │   └── platform_detector_test.dart
    └── features/
        └── share_intent/
            └── quick_save_service_test.dart
```

**Nguyên tắc bắt buộc cho agent:**
- Không tạo thêm layer trừu tượng (Repository interface + Impl, UseCase class riêng cho từng action nhỏ...) trừ khi có từ 2 implementation trở lên. Ở Phase 0–1, DAO gọi thẳng từ Controller là đủ.
- Không tạo bảng `content_assets` generic — chỉ dùng `thumbnails` như đã chốt trong `plan1_final_v2.md` mục 3.

---

## 2. Drift Schema — code thật (không phải giả định)

```dart
// core/database/tables/saved_items_table.dart
import 'package:drift/drift.dart';

class SavedItems extends Table {
  TextColumn get id => text()();
  TextColumn get originalUrl => text()();
  TextColumn get canonicalUrl => text()();
  TextColumn get platform => textEnum<PlatformEnum>()();
  TextColumn get contentType => textEnum<ContentTypeEnum>()
      .withDefault(const Constant('unknown'))();
  TextColumn get metadataStatus => textEnum<MetadataStatusEnum>()
      .withDefault(const Constant('pending'))();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get authorUrl => text().nullable()();
  IntColumn get savedAt => integer()();          // epoch millis
  IntColumn get lastAccessedAt => integer().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  TextColumn get whySaved => text().nullable()(); // read_later/try_this/learn_this/inspiration/just_interesting
  TextColumn get linkStatus => textEnum<LinkStatusEnum>()
      .withDefault(const Constant('unknown'))();
  IntColumn get lastCheckedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum PlatformEnum { reddit, instagram, tiktok, youtube, x, other }
enum ContentTypeEnum { video, image, gallery, text, link, mixed, unknown }
enum MetadataStatusEnum { pending, success, partial, failed }
enum LinkStatusEnum { alive, broken, unknown }
```

```dart
// core/database/tables/collections_table.dart
class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get parentId => text().nullable()
      .references(Collections, #id)();
  BoolColumn get isSmart => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
```

```dart
// core/database/tables/item_collections_table.dart
class ItemCollections extends Table {
  TextColumn get itemId => text()
      .references(SavedItems, #id, onDelete: KeyAction.cascade)();
  TextColumn get collectionId => text()
      .references(Collections, #id, onDelete: KeyAction.cascade)();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {itemId, collectionId};
}
```

```dart
// core/database/tables/tags_table.dart
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// core/database/tables/item_tags_table.dart
class ItemTags extends Table {
  TextColumn get itemId => text()
      .references(SavedItems, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId => text()
      .references(Tags, #id, onDelete: KeyAction.cascade)();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {itemId, tagId};
}
```

```dart
// core/database/tables/thumbnails_table.dart
class Thumbnails extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()
      .references(SavedItems, #id, onDelete: KeyAction.cascade)();
  TextColumn get remoteUrl => text().nullable()();
  TextColumn get localPath => text().nullable()();
  TextColumn get downloadStatus => textEnum<DownloadStatusEnum>()
      .withDefault(const Constant('pending'))();
  IntColumn get sizeBytes => integer().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

enum DownloadStatusEnum { pending, downloading, done, failed }
```

**FTS5 virtual table** (tạo qua raw SQL trong migration, Drift chưa hỗ trợ FTS5 declarative đầy đủ):

```sql
CREATE VIRTUAL TABLE saved_items_fts USING fts5(
  item_id UNINDEXED,
  title,
  description,
  note,
  content='',
  tokenize='unicode61'
);

-- Trigger đồng bộ khi insert/update/delete saved_items
CREATE TRIGGER saved_items_ai AFTER INSERT ON saved_items BEGIN
  INSERT INTO saved_items_fts(item_id, title, description, note)
  VALUES (new.id, new.title, new.description, new.note);
END;

CREATE TRIGGER saved_items_au AFTER UPDATE ON saved_items BEGIN
  UPDATE saved_items_fts SET title = new.title, description = new.description, note = new.note
  WHERE item_id = new.id;
END;

CREATE TRIGGER saved_items_ad AFTER DELETE ON saved_items BEGIN
  DELETE FROM saved_items_fts WHERE item_id = old.id;
END;
```

**Migration:** dùng `MigrationStrategy` của Drift, `schemaVersion = 1` cho lần đầu. Agent phải viết sẵn khung `onUpgrade` dù chưa có logic (để tránh quên khi cần migrate sau này).

---

## 3. Nguyên tắc dedup (thay cho UNIQUE constraint)

Không có UNIQUE constraint trên `canonical_url` ở DB. Xử lý ở tầng service:

```dart
// Giả mã — quick_save_service.dart
Future<SaveResult> quickSave(String rawUrl) async {
  final canonical = UrlNormalizer.canonicalize(rawUrl);
  final existing = await savedItemsDao.findByCanonicalUrl(canonical);

  if (existing == null) {
    // Case A: chưa từng save → tạo mới ngay, không hỏi gì cả
    final item = await savedItemsDao.insertMinimal(
      originalUrl: rawUrl,
      canonicalUrl: canonical,
      platform: PlatformDetector.detect(rawUrl),
    );
    _scheduleEnrichment(item.id); // background, không await
    return SaveResult.savedNew(item);
  } else {
    // Case B: đã tồn tại → Quick Save flow KHÔNG hỏi user (giữ tốc độ <1s).
    // Cập nhật lastAccessedAt, KHÔNG tạo bản ghi trùng, KHÔNG xoá note cũ.
    await savedItemsDao.touchLastAccessed(existing.id);
    return SaveResult.alreadyExists(existing);
    // UI: Toast hiển thị "Already saved · View" thay vì "Saved ✓"
    // Việc hỏi "cập nhật note hay tạo bản ghi mới" CHỈ xảy ra nếu user
    // vào Smart Save và chủ động sửa — không chặn luồng Quick Save.
  }
}
```

**Quyết định rõ ràng (khác với mô tả chung chung ở v2):** Quick Save không bao giờ tạo duplicate record và không bao giờ hỏi user giữa chừng. Nếu link đã tồn tại → chỉ cập nhật `last_accessed_at` và báo "Already saved". Muốn tạo bản ghi thứ 2 có chủ đích (2 note khác nhau cho cùng 1 link) → chỉ làm được qua Smart Save, có nút rõ ràng "Save as new entry".

---

## 4. Platform Detection — regex cụ thể

```dart
// core/url/platform_detector.dart
class PlatformDetector {
  static PlatformEnum detect(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return PlatformEnum.other;
    final host = uri.host.toLowerCase();

    if (_matchesAny(host, [
      'reddit.com', 'www.reddit.com', 'redd.it', 'v.redd.it',
    ])) return PlatformEnum.reddit;

    if (_matchesAny(host, [
      'instagram.com', 'www.instagram.com', 'instagr.am',
    ])) return PlatformEnum.instagram;

    if (_matchesAny(host, [
      'tiktok.com', 'www.tiktok.com', 'vt.tiktok.com', 'vm.tiktok.com',
    ])) return PlatformEnum.tiktok;

    if (_matchesAny(host, [
      'youtube.com', 'www.youtube.com', 'youtu.be', 'm.youtube.com',
    ])) return PlatformEnum.youtube;

    if (_matchesAny(host, [
      'twitter.com', 'x.com', 'www.x.com', 'www.twitter.com', 't.co',
    ])) return PlatformEnum.x;

    return PlatformEnum.other;
  }

  static bool _matchesAny(String host, List<String> domains) {
    return domains.any((d) => host == d || host.endsWith('.$d'));
  }
}
```

**Lưu ý bắt buộc cho agent:**
- Các domain rút gọn (`vt.tiktok.com`, `redd.it`, `youtu.be`, `t.co`) là **link redirect**, không tự resolve ở bước detect — chỉ detect platform theo domain. Việc resolve redirect (theo `HEAD` request để lấy URL cuối) là việc của **Metadata Adapter ở Phase 2**, KHÔNG làm ở Phase 0–1. Ở Phase 0–1, `canonical_url` giữ nguyên link rút gọn nếu chưa resolve được.
- `platform = other` là kết quả hợp lệ, không phải lỗi — vẫn phải save được (Save phải luôn thành công, theo nguyên tắc ở `plan1_final_v2.md`).

### URL Normalizer — canonical_url

```dart
// core/url/url_normalizer.dart
class UrlNormalizer {
  static const _trackingParams = {
    'utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term',
    'igsh', 'igshid', 'fbclid', 'gclid', 'si', 'ref', 'ref_src', 'ref_url',
    's', 't', 'feature',
  };

  static String canonicalize(String rawUrl) {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) return rawUrl.trim();

    final cleanParams = Map<String, String>.from(uri.queryParameters)
      ..removeWhere((key, _) => _trackingParams.contains(key.toLowerCase()));

    final cleaned = uri.replace(
      queryParameters: cleanParams.isEmpty ? null : cleanParams,
      fragment: '', // bỏ #fragment
    );

    // Bỏ trailing slash, lowercase host
    var result = cleaned.toString();
    if (result.endsWith('/') && cleaned.path != '/') {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }
}
```

---

## 5. Save flow — timeline & orchestration chi tiết

```
[Android Share Sheet] → user chọn "Reclip"
        │
        ▼
ReceiveSharingIntent nhận raw text/URL
        │
        ▼
QuickSaveService.quickSave(rawUrl)   ← PHẢI chạy < 300ms tới bước hiện Toast
        │
        ├── UrlNormalizer.canonicalize()      (đồng bộ, tức thì)
        ├── PlatformDetector.detect()          (đồng bộ, tức thì)
        ├── Check duplicate (DB query, index trên canonical_url)
        ├── Insert saved_items (metadata_status = 'pending')
        │
        ▼
Hiện QuickSaveToast NGAY (không chờ bước dưới)
        │
        ▼
[Background, không chặn UI, không await trong luồng chính]
        ├── Fetch metadata (Phase 2 — CHƯA làm ở Phase 1, để metadata_status = 'pending')
        └── (Phase 1 chỉ cần: item tồn tại trong DB + hiện trong Library ngay, title = null tạm thời hiển thị domain)
```

**Ở Phase 1, KHÔNG cần implement metadata fetching thật.** Chỉ cần:
- `metadata_status` mặc định `'pending'`.
- Library hiển thị item với `title` = domain rút gọn từ `canonical_url` khi `title == null` (ví dụ: hiện "instagram.com" thay vì chuỗi trống).
- Metadata Adapter thật (Reddit/TikTok/Instagram/YouTube/X) là việc của **Phase 2**, không nằm trong scope brief này.

---

## 6. UI Copy — chính xác từng string (không diễn giải)

```dart
// core/constants/app_strings.dart
class AppStrings {
  // Quick Save Toast
  static const savedToast = 'Saved to Library ✓';
  static const alreadySavedToast = 'Already saved';
  static const addDetailsAction = 'Add details';
  static const viewAction = 'View';
  static const toastDurationMs = 2000;

  // Item card badges
  static const badgeOnlineToView = '⚠ Online to view';
  static const badgeVideoUnavailableOffline = 'Video requires Internet';

  // Open Original
  static const openOriginalButton = 'Open Original';
  static const openOriginalFailedSnackbar =
      "Couldn't open the app or browser for this link.";

  // Fallback / metadata pending
  static const metadataPendingTitle = 'Fetching details…';
  static const metadataFailedTitle = 'Quick Link';
  static const metadataFailedSubtitle = "Couldn't load preview — tap to edit";

  // Smart Save bottom sheet
  static const smartSaveTitle = 'Add details';
  static const collectionLabel = 'Collection';
  static const tagsLabel = 'Tags';
  static const whySavedLabel = 'Why saving?';
  static const noteLabel = 'Note';
  static const saveButton = 'Save';
  static const cancelButton = 'Cancel';
  static const saveAsNewEntryButton = 'Save as new entry';

  static const whySavedOptions = <String, String>{
    'read_later': 'Read later',
    'try_this': 'Try this',
    'learn_this': 'Learn this',
    'inspiration': 'Inspiration',
    'just_interesting': 'Just interesting',
  };

  // Empty states
  static const libraryEmptyTitle = 'Nothing saved yet';
  static const libraryEmptySubtitle =
      'Share a post from any app to save it here.';
}
```

**Ngôn ngữ:** toàn bộ string tiếng Anh cho Phase 0–1 (để tránh phải làm i18n song song khi chưa chốt thị trường mục tiêu — xem `plan1_final_v2.md` mục 9). Nếu quyết định nhắm Việt Nam trước, việc thêm bản dịch tiếng Việt qua `intl`/`.arb` files nên làm ở Phase 2, không chặn Phase 0–1.

---

## 7. Android Permissions & Manifest

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<!-- KHÔNG cần READ/WRITE_EXTERNAL_STORAGE — dùng app-private storage
     (path_provider getApplicationDocumentsDirectory) cho thumbnail cache -->

<!-- Android 13+ cần permission riêng nếu có notification (Phase 2+, chưa cần Phase 0-1) -->
<!-- <uses-permission android:name="android.permission.POST_NOTIFICATIONS" /> -->

<application ...>
  <activity android:name=".MainActivity" ...>
    <!-- Intent filter để nhận Share từ các app khác -->
    <intent-filter>
      <action android:name="android.intent.action.SEND" />
      <category android:name="android.intent.category.DEFAULT" />
      <data android:mimeType="text/plain" />
    </intent-filter>
  </activity>
</application>
```

**Lưu ý:** `receive_sharing_intent` package tự động thêm phần lớn cấu hình này qua hướng dẫn cài đặt của package — agent cần kiểm tra README của đúng version đã pin (`^1.8.0`) vì package này đổi API khá thường xuyên giữa các major version.

---

## 8. Open Original — logic fallback cụ thể

```dart
// features/item_detail/application/open_original_service.dart
class OpenOriginalService {
  Future<bool> open(SavedItem item) async {
    // Bước 1: thử deep link app gốc (nếu platform hỗ trợ scheme rõ ràng)
    final deepLink = _buildDeepLink(item);
    if (deepLink != null) {
      final launched = await _tryLaunch(deepLink, mode: LaunchMode.externalApplication);
      if (launched) return true;
    }

    // Bước 2: fallback mở trong trình duyệt/tab ngoài
    final browserLaunched = await _tryLaunch(
      Uri.parse(item.originalUrl),
      mode: LaunchMode.externalApplication,
    );
    if (browserLaunched) return true;

    // Bước 3: cả hai đều fail → báo lỗi rõ ràng, không im lặng
    return false; // UI hiển thị openOriginalFailedSnackbar
  }

  Uri? _buildDeepLink(SavedItem item) {
    // Phase 1: chỉ cần fallback browser hoạt động chắc chắn.
    // Deep link scheme cụ thể (vd: instagram://, tiktok://) là optimization
    // của Phase 2 — nếu chưa implement, _buildDeepLink trả về null
    // và luôn đi thẳng qua Bước 2 (browser). Đây là hành vi CHẤP NHẬN ĐƯỢC ở Phase 1.
    return null;
  }

  Future<bool> _tryLaunch(Uri uri, {required LaunchMode mode}) async {
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: mode);
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
```

---

## 9. Acceptance Criteria — Definition of Done

### Phase 0 — DoD
- [ ] Share 1 link thật từ mỗi app: Reddit, Instagram, TikTok, YouTube, X (Twitter) trên thiết bị Android thật (không chỉ emulator) → Reclip nhận được Intent và log ra được `rawUrl`.
- [ ] `PlatformDetector.detect()` trả đúng platform cho ≥ 95% trong 25 URL mẫu thủ công (5 URL/platform, bao gồm cả dạng rút gọn).
- [ ] `UrlNormalizer.canonicalize()` loại bỏ đúng toàn bộ tracking param trong danh sách `_trackingParams` trên 10 URL mẫu có param thật.
- [ ] `OpenOriginalService.open()` mở được browser fallback thành công cho ≥ 1 URL mỗi platform trên thiết bị thật.
- [ ] Test tay 50–100 URL thật/platform (ghi vào file riêng `metadata_test_results.csv`, không cần code — chỉ cần số liệu) → có con số success rate thực tế theo từng platform, dùng làm input cho Phase 2 (không phải yêu cầu code).
- [ ] Unit test cho `PlatformDetector` và `UrlNormalizer` pass 100%, coverage các case biên (URL rỗng, URL không có scheme, URL có fragment `#`, URL viết hoa domain).

**Phase 0 KHÔNG được coi là xong nếu:** chưa test trên thiết bị Android thật (emulator không đủ để verify Share Intent hoạt động đúng với các app mạng xã hội thật).

### Phase 1 — DoD
- [ ] Từ lúc bấm Share đến lúc `QuickSaveToast` hiện ra: đo bằng `Stopwatch` trong code (log ra console/log file), trung bình < 1000ms qua 20 lần thử liên tiếp trên thiết bị thật, không có Wi-Fi (đo cả trường hợp offline để đảm bảo không phụ thuộc network).
- [ ] Save 1 item → tắt app hoàn toàn (kill process) → mở lại → item vẫn còn trong Library (verify local DB persistence).
- [ ] Save cùng 1 canonical_url 2 lần → chỉ có 1 record trong DB, `last_accessed_at` được cập nhật ở lần thứ 2, Toast hiện "Already saved" thay vì "Saved ✓".
- [ ] Library screen hiển thị đúng item vừa save trong vòng 1 giây sau khi Toast biến mất (không cần restart app hay pull-to-refresh).
- [ ] FTS5 search: search theo 1 từ khoá xuất hiện trong `title` của item đã save → trả về đúng kết quả trong danh sách.
- [ ] Tạo Collection mới, gán 1 item vào 2 collection khác nhau → verify cả 2 quan hệ tồn tại đúng trong bảng `item_collections` (test qua DAO, không cần UI để verify việc này).
- [ ] Tương tự cho Tags: gán 1 item 2 tag → verify đúng trong `item_tags`.
- [ ] `OpenOriginalService` hoạt động đúng từ Item Detail Screen với ít nhất 3/5 platform test thành công trên thiết bị thật.
- [ ] Toàn bộ string hiển thị dùng đúng từ `AppStrings`, không hard-code text rải rác trong widget.
- [ ] Widget test cho `QuickSaveToast` (hiện đúng text, tự ẩn sau đúng `toastDurationMs`, nút "Add details" mở đúng Smart Save sheet).

---

## 10. Test cases bắt buộc cho Parser (Phase 0–1)

```dart
// test/core/url_normalizer_test.dart — các case bắt buộc phải có
group('UrlNormalizer.canonicalize', () {
  test('loại bỏ utm_source, utm_medium, utm_campaign', () {});
  test('loại bỏ igsh param (Instagram share id)', () {});
  test('loại bỏ fbclid', () {});
  test('giữ nguyên query param không nằm trong danh sách tracking', () {});
  test('loại bỏ fragment (#...)', () {});
  test('bỏ trailing slash nhưng giữ nguyên path gốc / nếu là root', () {});
  test('URL rỗng hoặc không parse được → trả lại nguyên input đã trim', () {});
  test('URL có query params viết hoa (UTM_SOURCE) vẫn bị loại bỏ đúng (case-insensitive)', () {});
});

// test/core/platform_detector_test.dart
group('PlatformDetector.detect', () {
  test('reddit.com → reddit', () {});
  test('redd.it (short link) → reddit', () {});
  test('v.redd.it → reddit', () {});
  test('instagram.com/p/xxx → instagram', () {});
  test('instagr.am → instagram', () {});
  test('vt.tiktok.com (short link) → tiktok', () {});
  test('youtu.be (short link) → youtube', () {});
  test('x.com và twitter.com đều → x', () {});
  test('domain lạ hoàn toàn (vd: example.com) → other, KHÔNG throw exception', () {});
  test('URL không hợp lệ (không phải URL) → other, KHÔNG throw exception', () {});
});

// test/features/share_intent/quick_save_service_test.dart
group('QuickSaveService.quickSave', () {
  test('URL mới → tạo saved_items record với metadata_status = pending', () {});
  test('URL đã tồn tại (cùng canonical_url) → KHÔNG tạo record mới, chỉ update lastAccessedAt', () {});
  test('URL đã tồn tại → trả về SaveResult.alreadyExists, không phải savedNew', () {});
  test('platform = other vẫn save thành công bình thường', () {});
});
```

---

## 11. Những gì brief này CỐ TÌNH không cover (thuộc Phase 2+)

Để agent không tự ý mở rộng scope, liệt kê rõ các việc **không** làm ở Phase 0–1:

- Metadata Adapter thật cho từng platform (Reddit JSON API, oEmbed...).
- Thumbnail download & cache thật (bảng `thumbnails` đã có schema nhưng chưa cần logic tải).
- Proxy backend / serverless function.
- Deep link scheme cụ thể cho từng app (`instagram://`, `tiktok://`...).
- Faceted filter UI.
- Smart Collections, rediscovery engine, backup/restore.
- Bất kỳ dạng background job/WorkManager nào.
- i18n / bản dịch tiếng Việt.

Nếu agent tự thêm bất kỳ mục nào ở trên vào Phase 0–1, coi như lệch scope — cần dừng lại và xác nhận lại với người yêu cầu trước khi tiếp tục.