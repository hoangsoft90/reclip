# Reclip — Technical Brief: Phase 3 (Value Loop)

> Bổ sung cho `plan1_final_v2.md`, tiếp nối Phase 0–1–2. Phạm vi: **Rediscovery Engine, Notes/Why editing, Local Backup/Restore, đo Retrieval Rate + Week-1 Retention**. Viết với giả định Phase 2 đã pass Definition of Done và đã có bảng metrics thật theo platform.

---

## 0. Quyết định kiến trúc — chốt câu hỏi mở từ Phase 2

Phase 2 để ngỏ câu hỏi: có cần xây proxy backend nếu Instagram/TikTok failed rate cao? **Quyết định cho Phase 3 trở đi: không xây backend/proxy tự host.** Lý do:

- Chi phí vận hành, bảo trì, và rủi ro bảo mật (SSRF, allowlist, rate-limit) không tương xứng với giá trị ở giai đoạn chưa có người dùng thật ổn định.
- Quick Link Card (đã xây ở Phase 2) là **trải nghiệm mặc định lâu dài, chấp nhận được** cho Instagram/TikTok khi metadata fail — không phải trạng thái tạm bợ chờ backend giải quyết.
- Toàn bộ Phase 3 tiếp tục kiến trúc **client-only, local-first, zero server**. Nếu tương lai thực sự cần (ví dụ Cloud Sync ở Phase 4+), đó sẽ là managed service (Firebase/Supabase) chứ không phải self-host — nhưng quyết định đó **không nằm trong scope Phase 3**.

Toàn bộ thiết kế dưới đây tuân thủ nguyên tắc: **không có bất kỳ network call mới nào tới server của Reclip** — chỉ local DB, local file system, và network call đã có sẵn từ Phase 2 (metadata adapters).

---

## 1. Environment — package bổ sung

```yaml
dependencies:
  file_picker: ^8.1.2      # user chọn nơi lưu file backup / chọn file để restore
  share_plus: ^10.0.2      # chia sẻ file backup qua Google Drive, email, v.v.
  crypto: ^3.0.5           # checksum SHA-256 để verify file backup không bị hỏng khi restore
```

**Không thêm** package liên quan cloud storage SDK (firebase_storage, googleapis...) — ngoài scope Phase 3.

---

## 2. Cấu trúc thư mục bổ sung

```
lib/
├── core/
│   └── database/
│       └── tables/
│           ├── resurface_history_table.dart
│           └── app_events_table.dart        # chính thức hoá MetricsLogger tạm ở Phase 2
│
├── features/
│   ├── rediscovery/
│   │   ├── domain/
│   │   │   └── rediscovery_score.dart       # thuật toán scoring thuần, không phụ thuộc DB
│   │   ├── application/
│   │   │   └── rediscovery_service.dart
│   │   └── presentation/
│   │       ├── resurface_section.dart       # widget hiện trên Home/Library
│   │       └── resurface_card.dart
│   │
│   └── backup/
│       ├── domain/
│       │   └── backup_models.dart           # BackupPayload, BackupMetadata
│       ├── application/
│       │   ├── backup_export_service.dart
│       │   └── backup_import_service.dart
│       └── presentation/
│           └── backup_settings_screen.dart
│
└── features/item_detail/
    └── presentation/
        └── edit_note_why_sheet.dart         # cho phép sửa note/why SAU khi đã save
```

---

## 3. Rediscovery Engine

### 3.1. Quyết định thuật toán: không dùng SM-2, không dùng ML

Rediscovery score là hàm thuần (pure function), tính lại mỗi lần cần, **không lưu trạng thái "cấp độ ghi nhớ"** như spaced repetition thật — vì đây là bookmark, không phải flashcard học tập (đã chốt lý do ở `plan1_final_v2.md` mục 5).

```dart
// features/rediscovery/domain/rediscovery_score.dart
class RediscoveryScore {
  /// Trả về điểm số càng cao = càng nên resurface.
  /// Không có giá trị tuyệt đối có ý nghĩa — chỉ dùng để SO SÁNH và sắp xếp.
  static double calculate({
    required DateTime savedAt,
    required DateTime? lastAccessedAt,
    required bool isFavorite,
    required String? whySaved,
    required DateTime now,
  }) {
    final daysSinceLastSeen = lastAccessedAt == null
        ? _daysBetween(savedAt, now)
        : _daysBetween(lastAccessedAt, now);

    // Base score: item càng lâu chưa xem lại càng đáng resurface,
    // nhưng có ngưỡng bão hoà (log) để tránh item quá cũ luôn đứng đầu mãi mãi.
    double score = _logCap(daysSinceLastSeen, cap: 30);

    // Item mới save trong 24h qua: KHÔNG resurface ngay (chưa có ý nghĩa "quên rồi nhớ lại")
    if (_daysBetween(savedAt, now) < 1) return -1; // loại khỏi candidate pool

    if (isFavorite) score *= 1.5;

    score *= _whySavedMultiplier(whySaved);

    return score;
  }

  static double _logCap(int days, {required int cap}) {
    final capped = days.clamp(0, cap * 3);
    return (1 + capped).clamp(1, cap * 3).toDouble().clamp(0, cap.toDouble() * 1.5);
  }

  static double _whySavedMultiplier(String? whySaved) {
    switch (whySaved) {
      case 'learn_this':
        return 1.4;   // ưu tiên cao nhất — người dùng chủ động đánh dấu muốn học
      case 'try_this':
        return 1.3;
      case 'read_later':
        return 1.2;
      case 'inspiration':
        return 1.0;
      case 'just_interesting':
        return 0.8;
      default: // null — user không gắn why_saved
        return 1.0;
    }
  }

  static int _daysBetween(DateTime a, DateTime b) => b.difference(a).inDays;
}
```

### 3.2. Chọn item để resurface — tránh lặp lại liên tục

```dart
// features/rediscovery/application/rediscovery_service.dart
class RediscoveryService {
  final SavedItemsDao _itemsDao;
  final ResurfaceHistoryDao _historyDao;

  static const int _dailyCount = 5;
  static const int _excludeRecentlyShownDays = 3; // item đã resurface trong 3 ngày qua thì loại

  Future<List<SavedItem>> getTodaysResurfaceItems() async {
    final now = DateTime.now();
    final candidates = await _itemsDao.findActiveItems(); // is_archived = false
    final recentlyShownIds = await _historyDao.findShownItemIds(
      since: now.subtract(const Duration(days: _excludeRecentlyShownDays)),
    );

    final scored = candidates
        .where((item) => !recentlyShownIds.contains(item.id))
        .map((item) => (
              item: item,
              score: RediscoveryScore.calculate(
                savedAt: DateTime.fromMillisecondsSinceEpoch(item.savedAt),
                lastAccessedAt: item.lastAccessedAt != null
                    ? DateTime.fromMillisecondsSinceEpoch(item.lastAccessedAt!)
                    : null,
                isFavorite: item.isFavorite,
                whySaved: item.whySaved,
                now: now,
              ),
            ))
        .where((entry) => entry.score >= 0)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    // Lấy top candidates rồi random hoá nhẹ trong top 15 để tránh cảm giác
    // "luôn đúng công thức, nhàm chán" — vẫn ưu tiên điểm cao nhưng có yếu tố bất ngờ.
    final topPool = scored.take(15).map((e) => e.item).toList()..shuffle();
    final selected = topPool.take(_dailyCount).toList();

    for (final item in selected) {
      await _historyDao.recordShown(item.id, now);
    }
    return selected;
  }
}
```

### 3.3. Schema bổ sung

```sql
-- resurface_history
id TEXT PRIMARY KEY
item_id TEXT REFERENCES saved_items(id) ON DELETE CASCADE
shown_at INTEGER NOT NULL
```

### 3.4. UI — vị trí hiển thị

`ResurfaceSection` là 1 khối nằm ở đầu Library screen (không phải màn hình riêng — tránh thêm 1 tab mới ở Phase 3, giữ navigation đơn giản):

```
┌─────────────────────────────────────┐
│  ✨ Resurface                        │
│  ┌────────┐ ┌────────┐ ┌────────┐   │
│  │ item 1 │ │ item 2 │ │ item 3 │ → │  (horizontal scroll)
│  └────────┘ └────────┘ └────────┘   │
└─────────────────────────────────────┘
[ Library grid bình thường bên dưới ]
```

String bổ sung:
```dart
static const resurfaceSectionTitle = '✨ Resurface';
static const resurfaceEmptyState = 'Save a few more things to see resurfaced items here.';
```

**Điều kiện hiện section:** chỉ hiện nếu `candidates.isNotEmpty`. Nếu library có < 5 item hợp lệ (đã qua 24h), ẩn hẳn section thay vì hiện rỗng hoặc hiện ít hơn 5 — tránh cảm giác sản phẩm "nghèo nàn" khi mới dùng.

---

## 4. Notes + Why — cho phép sửa sau khi save

Ở Phase 1, `note`/`why_saved` chỉ nhập được qua Smart Save lúc save. Phase 3 bổ sung: sửa được bất kỳ lúc nào từ Item Detail screen.

```dart
// features/item_detail/presentation/edit_note_why_sheet.dart
// BottomSheet đơn giản, tái sử dụng đúng UI component đã có ở Smart Save
// (KHÔNG viết lại từ đầu — extract phần Note + Why field ở Smart Save
// thành widget dùng chung SharedNoteWhyFields, dùng lại ở cả 2 nơi).
```

**Quyết định:** refactor nhỏ — tách phần input Note + Why ở `smart_save_bottom_sheet.dart` (Phase 1) thành widget dùng chung, tránh trùng lặp code giữa Save flow và Edit flow. Đây là refactor hợp lý (không phải thêm abstraction thừa) vì giờ có ≥ 2 nơi dùng chung logic thật.

---

## 5. Local Backup & Restore

### 5.1. Format file backup

Chọn **JSON thuần, không nén thành zip** — lý do: đơn giản hoá Phase 3, dữ liệu text (không có thumbnail binary) nên kích thước nhỏ, không cần nén. Nếu sau này thấy file quá lớn (nhiều nghìn item), có thể nén ở Phase 4+.

**Quyết định quan trọng: backup KHÔNG bao gồm file ảnh thumbnail nhị phân.** Chỉ backup dữ liệu có cấu trúc (bảng SQL). Sau khi restore, `local_path` của thumbnail sẽ trỏ tới file không tồn tại — app cần tự phát hiện và **tải lại thumbnail từ `remote_url`** nếu link gốc còn sống, hoặc rơi về Quick Link card nếu không. Lý do quyết định này: giữ backup nhẹ, nhanh, và tận dụng lại chính cơ chế enrichment đã xây ở Phase 2 thay vì viết thêm logic bundle/unbundle ảnh.

```dart
// features/backup/domain/backup_models.dart
class BackupPayload {
  final String exportVersion;      // '1.0' — để Phase sau biết cách migrate nếu format đổi
  final int exportedAt;
  final int itemCount;
  final List<Map<String, dynamic>> savedItems;
  final List<Map<String, dynamic>> collections;
  final List<Map<String, dynamic>> tags;
  final List<Map<String, dynamic>> itemCollections;
  final List<Map<String, dynamic>> itemTags;

  Map<String, dynamic> toJson() => {
        'export_version': exportVersion,
        'exported_at': exportedAt,
        'item_count': itemCount,
        'saved_items': savedItems,
        'collections': collections,
        'tags': tags,
        'item_collections': itemCollections,
        'item_tags': itemTags,
      };
}
```

### 5.2. Export flow

```dart
// features/backup/application/backup_export_service.dart
class BackupExportService {
  Future<File> export() async {
    final payload = await _buildPayload();
    final jsonString = jsonEncode(payload.toJson());
    final checksum = sha256.convert(utf8.encode(jsonString)).toString();

    final wrapped = {
      'checksum': checksum,
      'data': payload.toJson(),
    };

    final dir = await getTemporaryDirectory();
    final filename = 'reclip_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${dir.path}/$filename');
    await file.writeAsString(jsonEncode(wrapped));
    return file;
  }

  /// Gọi sau export() — dùng share_plus để user tự chọn nơi lưu
  /// (Google Drive, Files app, email...) thay vì Reclip tự quản lý vị trí lưu.
  Future<void> shareBackupFile(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'Reclip backup');
  }
}
```

**Quyết định:** dùng `share_plus` thay vì tự implement chọn thư mục lưu qua Storage Access Framework — đơn giản hơn nhiều, và để user tự quyết định lưu vào đâu (Drive, local Downloads, gửi qua email cho chính mình...) theo thói quen sẵn có của họ, Reclip không cần quản lý việc đó.

### 5.3. Import/Restore flow — chiến lược merge, không phải replace

```dart
// features/backup/application/backup_import_service.dart
class BackupImportService {
  Future<ImportResult> importFromFile(File file) async {
    final content = await file.readAsString();
    final wrapped = jsonDecode(content) as Map<String, dynamic>;

    final expectedChecksum = wrapped['checksum'] as String;
    final dataJson = jsonEncode(wrapped['data']);
    final actualChecksum = sha256.convert(utf8.encode(dataJson)).toString();

    if (expectedChecksum != actualChecksum) {
      return ImportResult.failed('File có vẻ bị hỏng hoặc chỉnh sửa (checksum không khớp)');
    }

    final payload = wrapped['data'] as Map<String, dynamic>;
    final exportVersion = payload['export_version'] as String;
    if (exportVersion != '1.0') {
      return ImportResult.failed('Phiên bản backup không tương thích: $exportVersion');
    }

    return _mergeImport(payload);
  }

  /// Chiến lược MẶC ĐỊNH: merge theo canonical_url, KHÔNG xoá dữ liệu hiện có.
  /// - Nếu canonical_url đã tồn tại trong máy: giữ bản hiện tại, CHỈ merge tags/collections
  ///   không bị mất (union), không ghi đè note đang có trừ khi note hiện tại đang rỗng.
  /// - Nếu canonical_url chưa tồn tại: insert mới nguyên vẹn.
  Future<ImportResult> _mergeImport(Map<String, dynamic> payload) async {
    int inserted = 0, skipped = 0, merged = 0;
    // ... implement theo mô tả trên, dùng transaction Drift để đảm bảo atomic
    return ImportResult.success(inserted: inserted, merged: merged, skipped: skipped);
  }
}
```

**Quyết định rõ ràng:** import mặc định là **merge an toàn**, không có tuỳ chọn "Replace all / xoá hết rồi restore" ở Phase 3 — vì nguy cơ mất dữ liệu do thao tác nhầm cao hơn giá trị mang lại ở giai đoạn này. Nếu thực sự cần "restore sạch" (ví dụ đổi máy mới, máy đang trống), merge vào DB trống cho kết quả tương đương replace — không cần code riêng cho case đó.

### 5.4. UI — Backup Settings screen

```
┌─────────────────────────────┐
│  Backup & Restore            │
│                               │
│  Last backup: Never           │
│  [ Export backup now ]        │
│                               │
│  ──────────────                │
│  [ Restore from file ]        │
│  Restoring merges data —      │
│  nothing on this device       │
│  will be deleted.             │
└─────────────────────────────┘
```

String bổ sung:
```dart
static const backupScreenTitle = 'Backup & Restore';
static const exportBackupButton = 'Export backup now';
static const restoreBackupButton = 'Restore from file';
static const restoreMergeNotice =
    'Restoring merges data — nothing on this device will be deleted.';
static const restoreSuccessMessage = 'Restored successfully';
static const restoreChecksumError =
    'This backup file looks corrupted or was edited outside Reclip.';
```

---

## 6. Metrics — Retrieval Rate & Week-1 Retention

### 6.1. Chính thức hoá `app_events` table (thay cho MetricsLogger tạm ở Phase 2)

```sql
-- app_events
id TEXT PRIMARY KEY
event_type TEXT NOT NULL      -- 'item_saved' | 'item_opened' | 'metadata_result' | 'app_opened'
item_id TEXT                  -- nullable, chỉ áp dụng cho event liên quan tới 1 item
platform TEXT                 -- nullable
metadata_status TEXT          -- nullable, chỉ dùng cho event_type = 'metadata_result'
created_at INTEGER NOT NULL
```

Toàn bộ log giữ **hoàn toàn local**, không gửi đi đâu — đúng nguyên tắc privacy-first đã chốt xuyên suốt các phase trước.

### 6.2. Định nghĩa chính xác "Retrieval" — tránh đếm sai

Một sự kiện được tính là **retrieval** khi:
- User mở Item Detail screen, HOẶC bấm "Open Original", cho một item
- VÀ item đó đã được save **từ ≥ 24 giờ trước** thời điểm mở lại

(Loại trừ việc mở ngay sau khi vừa save — vì đó không phải "nhớ lại", chỉ là xác nhận save thành công.)

```dart
// Gọi tại nơi user mở Item Detail hoặc bấm Open Original
Future<void> logRetrievalIfEligible(SavedItem item) async {
  final savedAt = DateTime.fromMillisecondsSinceEpoch(item.savedAt);
  final isEligible = DateTime.now().difference(savedAt).inHours >= 24;
  if (!isEligible) return;

  await appEventsDao.insert(AppEventsCompanion.insert(
    id: const Uuid().v4(),
    eventType: 'item_opened',
    itemId: Value(item.id),
    platform: Value(item.platform.name),
    createdAt: DateTime.now().millisecondsSinceEpoch,
  ));
}
```

### 6.3. Công thức tính

```dart
class RetentionMetricsCalculator {
  /// Retrieval Rate (7 ngày) = % item được save >= 8 ngày trước
  /// mà có ít nhất 1 event 'item_opened' hợp lệ trong vòng 7 ngày sau khi save.
  Future<double> retrievalRate7Days() async {
    final eligibleItems = await itemsDao.findSavedBefore(
      DateTime.now().subtract(const Duration(days: 8)),
    );
    if (eligibleItems.isEmpty) return 0;

    int retrievedCount = 0;
    for (final item in eligibleItems) {
      final hasRetrieval = await appEventsDao.hasOpenEventWithinDays(
        itemId: item.id,
        afterSavedAt: item.savedAt,
        withinDays: 7,
      );
      if (hasRetrieval) retrievedCount++;
    }
    return retrievedCount / eligibleItems.length;
  }

  /// Week-1 Retention = % ngày trong 7 ngày đầu tiên sau lần cài đặt
  /// mà có ít nhất 1 event 'app_opened'.
  Future<double> week1Retention(DateTime installDate) async {
    final daysWithActivity = await appEventsDao.countDistinctDaysWithEvent(
      eventType: 'app_opened',
      from: installDate,
      to: installDate.add(const Duration(days: 7)),
    );
    return daysWithActivity / 7;
  }
}
```

**Hiển thị:** Phase 3 **không cần** dashboard UI cho các số liệu này — chỉ cần method tính toán + có thể expose qua 1 màn hình debug đơn giản (`DebugMetricsScreen`, chỉ hiện trong debug build, không public cho user). Việc dựng dashboard đẹp cho metrics là việc của khi có nhiều người dùng thật, không phải Phase 3.

---

## 7. Acceptance Criteria — Definition of Done cho Phase 3

- [ ] `RediscoveryScore.calculate()` có unit test cho các case: item mới save <24h (loại khỏi pool), item favorite (score nhân 1.5), từng loại `why_saved` (đúng multiplier), item có `lastAccessedAt = null` dùng `savedAt` làm mốc.
- [ ] `RediscoveryService.getTodaysResurfaceItems()` verify: không trả về item đã hiện trong 3 ngày qua (test với `resurface_history` có sẵn dữ liệu), trả về đúng tối đa 5 item.
- [ ] Resurface section ẩn hoàn toàn khi candidate pool < 5 item hợp lệ — verify bằng test với DB có ít dữ liệu.
- [ ] Note/Why sửa được từ Item Detail screen, dùng chung widget với Smart Save (verify bằng cách kiểm tra code không có 2 bản UI trùng lặp).
- [ ] Export backup: tạo file JSON, verify checksum đúng, verify đầy đủ 5 nhóm dữ liệu (saved_items, collections, tags, item_collections, item_tags).
- [ ] Import backup: test với chính file vừa export → verify **0 dữ liệu bị mất hoặc trùng lặp** sau khi import lại vào cùng 1 máy (idempotent).
- [ ] Import backup với file đã chỉnh sửa thủ công (sai checksum) → báo lỗi rõ ràng, **không** import một phần dữ liệu bị hỏng.
- [ ] Import backup từ máy A sang máy B (2 thiết bị/2 instance khác nhau, dữ liệu gốc khác nhau) → verify merge đúng theo canonical_url, không tạo trùng lặp cho URL đã có ở cả 2 máy.
- [ ] `retrievalRate7Days()` và `week1Retention()` chạy được với dữ liệu test giả lập (seed data với timestamp cụ thể), trả về số đúng theo công thức đã định nghĩa.
- [ ] Toàn bộ tính năng Phase 3 hoạt động đúng khi **tắt hoàn toàn mạng internet** (trừ phần share file backup ra ngoài app, vốn phụ thuộc app đích như Drive) — verify không có network call mới nào phát sinh từ Rediscovery/Backup/Metrics.

---

## 8. Những gì brief này CỐ TÌNH không cover (thuộc Phase 4+)

- Cloud Sync / backend thật (đã quyết định ở mục 0 — không self-host, và cũng chưa chốt dùng managed service nào).
- Smart Collections rule-based.
- Screenshot-to-Clip / OCR.
- Moodboard / Context Canvas.
- Export Collection dạng PDF/ảnh dài (khác với Backup — Backup là dữ liệu thô cho chính mình, Export Collection là chia sẻ ra ngoài, thuộc Phase 4).
- Dashboard UI đẹp cho metrics (chỉ cần debug screen nội bộ ở Phase 3).
- Nén/bundle thumbnail vào file backup.

Nếu agent thấy cần làm điều gì thuộc danh sách trên để "hoàn thiện" Phase 3, dừng lại và xác nhận lại trước khi tiếp tục — giữ đúng kỷ luật scope đã áp dụng từ Phase 0.