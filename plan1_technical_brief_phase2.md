# Reclip — Technical Brief: Phase 2 (Enrichment)

> Bổ sung cho `plan1_final_v2.md` và tiếp nối `plan1_technical_brief_phase0_1.md`. Phạm vi: **Platform Adapters, background metadata/thumbnail fetch, fallback Quick Link card, Offline UI, Faceted filter**. Viết với giả định Phase 0–1 đã pass Definition of Done.

---

## 0. Điều kiện tiên quyết — bắt buộc đọc trước khi code

**Trước khi viết bất kỳ adapter nào, agent phải đọc file `metadata_test_results.csv`** được tạo ở Phase 0 (50–100 URL thật/platform, đo tay). File này quyết định thứ tự ưu tiên xây adapter và mức độ đầu tư fallback cho từng platform.

Nếu chưa có file này hoặc dữ liệu không đủ tin cậy (< 30 URL/platform), **dừng lại, chạy lại Phase 0 mục test tay trước**, không code Phase 2 dựa trên ước tính trong `plan1_final_v2.md` (con số ở đó chỉ là giả định ban đầu, chưa kiểm chứng).

**Thứ tự xây adapter theo độ ưu tiên (dựa trên giả định độ ổn định ở `plan1_final_v2.md` mục 4 — agent phải verify lại bằng số liệu thật từ CSV, có thể đảo thứ tự nếu số liệu khác):**
1. Reddit (JSON API công khai)
2. YouTube (oEmbed chính thức)
3. X/Twitter (oEmbed chính thức)
4. TikTok (best-effort)
5. Instagram (best-effort, đầu tư fallback nhiều nhất)

---

## 1. Environment — package bổ sung

```yaml
dependencies:
  dio: ^5.7.0                    # HTTP client, hỗ trợ timeout/interceptor tốt hơn http package thuần
  html: ^0.15.4                  # parse og:title/og:image khi platform không có API/oEmbed
  connectivity_plus: ^6.0.5      # detect online/offline cho Offline UI
  flutter_cache_manager: ^3.4.1  # quản lý cache thumbnail có giới hạn dung lượng
```

**Không thêm** `workmanager` hay bất kỳ package OS-level background job nào ở Phase 2 — xem lý do ở mục 4.

---

## 2. Cấu trúc thư mục bổ sung

```
lib/
├── core/
│   └── network/
│       ├── http_client.dart          # Dio instance dùng chung, config timeout
│       └── connectivity_service.dart # wrap connectivity_plus
│
├── features/
│   └── metadata/
│       ├── domain/
│       │   ├── metadata_result.dart       # model kết quả trả về từ adapter
│       │   └── platform_adapter.dart      # abstract interface
│       ├── adapters/
│       │   ├── reddit_adapter.dart
│       │   ├── youtube_adapter.dart
│       │   ├── x_adapter.dart
│       │   ├── tiktok_adapter.dart
│       │   ├── instagram_adapter.dart
│       │   └── generic_opengraph_adapter.dart   # fallback cuối cùng, dùng og: tags
│       ├── application/
│       │   ├── enrichment_orchestrator.dart     # điều phối, retry, concurrency limit
│       │   └── thumbnail_download_service.dart
│       └── metadata_adapter_factory.dart        # chọn đúng adapter theo PlatformEnum
│
├── features/library/
│   └── application/
│       └── facet_filter_controller.dart
│
└── features/library/presentation/widgets/
    ├── facet_filter_bar.dart
    ├── quick_link_card.dart          # UI khi metadata_status = failed/partial
    └── offline_banner.dart
```

**Đây là abstraction hợp lý duy nhất được thêm ở Phase 2** (interface `PlatformAdapter` với 5 implementation thật) — khác với nguyên tắc "không thêm abstraction" ở Phase 0–1, vì ở đây thực sự có ≥2 cách triển khai khác nhau cần switch qua lại theo platform.

---

## 3. Platform Adapter — interface & model

```dart
// features/metadata/domain/platform_adapter.dart
abstract class PlatformAdapter {
  /// Timeout riêng cho từng adapter — KHÔNG dùng chung 1 timeout toàn cục,
  /// vì Reddit/YouTube/X ổn định hơn nên có thể timeout ngắn hơn TikTok/Instagram.
  Duration get timeout;

  Future<MetadataResult> fetch(String canonicalUrl);
}
```

```dart
// features/metadata/domain/metadata_result.dart
class MetadataResult {
  final MetadataStatusEnum status;   // success | partial | failed
  final String? title;
  final String? description;
  final String? author;
  final String? authorUrl;
  final String? thumbnailUrl;
  final ContentTypeEnum? contentType;
  final String? failureReason;       // log nội bộ, KHÔNG hiển thị cho user

  const MetadataResult({
    required this.status,
    this.title,
    this.description,
    this.author,
    this.authorUrl,
    this.thumbnailUrl,
    this.contentType,
    this.failureReason,
  });

  /// status = 'partial' khi lấy được MỘT PHẦN (vd: có title nhưng không có thumbnail)
  /// status = 'failed' khi không lấy được gì — vẫn hợp lệ, KHÔNG phải exception
  factory MetadataResult.failed(String reason) => MetadataResult(
        status: MetadataStatusEnum.failed,
        failureReason: reason,
      );
}
```

**Nguyên tắc bắt buộc:** `fetch()` **không bao giờ throw exception ra ngoài**. Mọi lỗi (timeout, network error, parse error, HTTP 4xx/5xx) phải được catch bên trong adapter và trả về `MetadataResult.failed(reason)`. Orchestrator không cần try-catch quanh mỗi adapter call — adapter tự chịu trách nhiệm không crash.

### Ví dụ implementation — Reddit (ưu tiên cao nhất)

```dart
// features/metadata/adapters/reddit_adapter.dart
class RedditAdapter implements PlatformAdapter {
  final Dio _dio;
  RedditAdapter(this._dio);

  @override
  Duration get timeout => const Duration(seconds: 6);

  @override
  Future<MetadataResult> fetch(String canonicalUrl) async {
    try {
      final jsonUrl = _toJsonUrl(canonicalUrl);
      final response = await _dio.get(
        jsonUrl,
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
          headers: {'User-Agent': 'Reclip/1.0 (Android; personal use)'},
        ),
      );
      final data = response.data;
      final postData = data[0]['data']['children'][0]['data'];

      return MetadataResult(
        status: MetadataStatusEnum.success,
        title: postData['title'] as String?,
        author: postData['author'] as String?,
        thumbnailUrl: _extractThumbnail(postData),
        contentType: _detectContentType(postData),
      );
    } catch (e) {
      return MetadataResult.failed('reddit_fetch_error: $e');
    }
  }

  String _toJsonUrl(String url) {
    final clean = url.split('?').first;
    return '${clean.endsWith('/') ? clean.substring(0, clean.length - 1) : clean}.json';
  }

  String? _extractThumbnail(Map postData) {
    final thumb = postData['thumbnail'] as String?;
    if (thumb == null || thumb == 'self' || thumb == 'default') return null;
    return thumb;
  }

  ContentTypeEnum _detectContentType(Map postData) {
    if (postData['is_video'] == true) return ContentTypeEnum.video;
    if (postData['is_gallery'] == true) return ContentTypeEnum.gallery;
    if (postData['post_hint'] == 'image') return ContentTypeEnum.image;
    return ContentTypeEnum.text;
  }
}
```

**Các adapter còn lại (YouTube, X, TikTok, Instagram) viết theo cùng khuôn mẫu này** — agent tự triển khai dựa trên cơ chế oEmbed/embed hiện có của từng platform, luôn tuân thủ nguyên tắc không throw exception. Với TikTok và Instagram — nơi Phase 0 data nhiều khả năng cho thấy tỷ lệ thành công thấp — **không đầu tư quá nhiều công sức viết logic phức tạp để cố lấy bằng được**; ưu tiên fail nhanh (timeout ngắn hơn, 4-5s) và rơi về `generic_opengraph_adapter.dart` hoặc Quick Link fallback.

### Generic OpenGraph fallback (dùng chung cho mọi platform khi adapter riêng fail)

```dart
// features/metadata/adapters/generic_opengraph_adapter.dart
class GenericOpenGraphAdapter implements PlatformAdapter {
  final Dio _dio;
  GenericOpenGraphAdapter(this._dio);

  @override
  Duration get timeout => const Duration(seconds: 5);

  @override
  Future<MetadataResult> fetch(String canonicalUrl) async {
    try {
      final response = await _dio.get(
        canonicalUrl,
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
          headers: {'User-Agent': 'Mozilla/5.0 (compatible; Reclip/1.0)'},
        ),
      );
      final document = html_parser.parse(response.data);
      final title = _metaContent(document, 'og:title') ?? document.querySelector('title')?.text;
      final image = _metaContent(document, 'og:image');
      final description = _metaContent(document, 'og:description');

      if (title == null && image == null) {
        return MetadataResult.failed('no_og_tags_found');
      }
      return MetadataResult(
        status: (title != null && image != null)
            ? MetadataStatusEnum.success
            : MetadataStatusEnum.partial,
        title: title,
        thumbnailUrl: image,
        description: description,
      );
    } catch (e) {
      return MetadataResult.failed('opengraph_fetch_error: $e');
    }
  }

  String? _metaContent(Document doc, String property) {
    return doc.querySelector('meta[property="$property"]')?.attributes['content'];
  }
}
```

---

## 4. Enrichment Orchestrator — chạy khi nào, như thế nào

**Quyết định kiến trúc quan trọng:** Phase 2 **không dùng OS-level background job** (WorkManager/BGTaskScheduler). Lý do:
- Độ phức tạp cao (permission, battery optimization exemption trên Android, dễ bị hệ thống kill).
- Ở quy mô MVP, đủ dùng cơ chế đơn giản hơn: **xử lý hàng đợi mỗi khi app mở/resume**, chạy trong `Isolate` hoặc đơn giản là `Future` bất đồng bộ không chặn UI thread chính.

```dart
// features/metadata/application/enrichment_orchestrator.dart
class EnrichmentOrchestrator {
  final SavedItemsDao _dao;
  final MetadataAdapterFactory _adapterFactory;
  final ThumbnailDownloadService _thumbnailService;

  static const int _maxConcurrent = 3;   // giới hạn số request chạy song song
  static const int _maxRetries = 2;      // retry cho lỗi network tạm thời (KHÔNG retry cho 'partial')

  EnrichmentOrchestrator(this._dao, this._adapterFactory, this._thumbnailService);

  /// Gọi hàm này khi: (a) app khởi động, (b) app resume từ background,
  /// (c) ngay sau khi 1 item mới được Quick Save.
  Future<void> processPendingQueue() async {
    final pendingItems = await _dao.findByMetadataStatus(MetadataStatusEnum.pending);
    final pool = <Future>[];

    for (final item in pendingItems) {
      if (pool.length >= _maxConcurrent) {
        await Future.any(pool);
        pool.removeWhere((f) => f is _CompletedMarker);
      }
      pool.add(_enrichOne(item));
    }
    await Future.wait(pool);
  }

  Future<void> _enrichOne(SavedItem item, {int attempt = 0}) async {
    final adapter = _adapterFactory.forPlatform(item.platform);
    final result = await adapter.fetch(item.canonicalUrl);

    if (result.status == MetadataStatusEnum.failed && attempt < _maxRetries) {
      // Chỉ retry lỗi network/timeout, không retry nếu adapter xác nhận "không có dữ liệu"
      await Future.delayed(Duration(seconds: 2 * (attempt + 1))); // backoff đơn giản
      return _enrichOne(item, attempt: attempt + 1);
    }

    if (result.status == MetadataStatusEnum.failed) {
      // Thử fallback OpenGraph trước khi chấp nhận failed hẳn
      final fallback = await _adapterFactory.openGraphFallback().fetch(item.canonicalUrl);
      await _persistResult(item, fallback);
      return;
    }

    await _persistResult(item, result);
  }

  Future<void> _persistResult(SavedItem item, MetadataResult result) async {
    await _dao.updateMetadata(
      itemId: item.id,
      status: result.status,
      title: result.title,
      description: result.description,
      author: result.author,
      contentType: result.contentType,
    );
    if (result.thumbnailUrl != null) {
      await _thumbnailService.enqueueDownload(item.id, result.thumbnailUrl!);
    }
    // Log metric — xem mục 8
    MetricsLogger.logMetadataResult(item.platform, result.status);
  }
}
```

**Lưu ý bắt buộc:** `_maxConcurrent = 3` là để tránh spam request đồng thời tới cùng 1 platform (dễ bị rate-limit, đặc biệt Instagram/TikTok). Nếu Phase 0 data cho thấy 1 platform cụ thể rate-limit rất nhạy, cân nhắc thêm per-platform concurrency limit thay vì 1 con số chung — agent tự quyết định dựa trên số liệu thật, không cần hỏi lại.

---

## 5. Thumbnail Download & Cache

```dart
// features/metadata/application/thumbnail_download_service.dart
class ThumbnailDownloadService {
  final AppDatabase _db;
  static const int maxCacheSizeBytes = 200 * 1024 * 1024; // 200MB giới hạn cache

  Future<void> enqueueDownload(String itemId, String remoteUrl) async {
    final thumbId = const Uuid().v4();
    await _db.thumbnailsDao.insert(ThumbnailsCompanion.insert(
      id: thumbId,
      itemId: itemId,
      remoteUrl: Value(remoteUrl),
      downloadStatus: const Value(DownloadStatusEnum.pending),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
    unawaited(_download(thumbId, remoteUrl)); // chạy nền, không chặn
  }

  Future<void> _download(String thumbId, String remoteUrl) async {
    try {
      await _db.thumbnailsDao.updateStatus(thumbId, DownloadStatusEnum.downloading);
      final file = await DefaultCacheManager().getSingleFile(remoteUrl);
      final size = await file.length();
      await _db.thumbnailsDao.updateResult(
        thumbId,
        localPath: file.path,
        sizeBytes: size,
        status: DownloadStatusEnum.done,
      );
      await _enforceMaxCacheSize();
    } catch (e) {
      await _db.thumbnailsDao.updateStatus(thumbId, DownloadStatusEnum.failed);
    }
  }

  /// Xoá thumbnail cũ nhất (theo createdAt) khi vượt maxCacheSizeBytes.
  /// Chỉ xoá file local + set localPath = null, KHÔNG xoá saved_items —
  /// item vẫn tồn tại, chỉ mất ảnh cache, có thể tải lại nếu cần.
  Future<void> _enforceMaxCacheSize() async {
    final totalSize = await _db.thumbnailsDao.sumSizeBytes();
    if (totalSize <= maxCacheSizeBytes) return;

    final oldestDone = await _db.thumbnailsDao.findOldestDone(limit: 10);
    for (final thumb in oldestDone) {
      if (thumb.localPath != null) {
        final file = File(thumb.localPath!);
        if (await file.exists()) await file.delete();
      }
      await _db.thumbnailsDao.clearLocalPath(thumb.id);
      final newTotal = await _db.thumbnailsDao.sumSizeBytes();
      if (newTotal <= maxCacheSizeBytes) break;
    }
  }
}
```

**Quyết định:** giới hạn cache cứng 200MB cho Phase 2 (không cần setting cho user chỉnh — đó là việc của Phase 3+/Pro tier theo `plan1_final_v2.md` mục 9). Chính sách xoá: LRU đơn giản theo `createdAt`, không cần thuật toán phức tạp hơn ở giai đoạn này.

---

## 6. Quick Link Fallback Card — UI khi metadata thất bại

```dart
// features/library/presentation/widgets/quick_link_card.dart
```

Hiển thị khi `metadata_status IN ('failed', 'pending')`:

```
┌─────────────────────────────┐
│  🔗  [domain icon]            │
│                               │
│  instagram.com                │  ← hiện canonical_url domain nếu title = null
│  Saved 2 hours ago             │
│                               │
│  [Edit title]  [Open Original] │
└─────────────────────────────┘
```

String bổ sung vào `AppStrings`:
```dart
static const editTitleAction = 'Edit title';
static const quickLinkDomainPrefix = 'Saved from';
```

**Nguyên tắc bắt buộc:** Quick Link Card là **first-class UI**, dùng font/spacing/style nhất quán với card metadata đầy đủ — không phải "error state" trông xấu hơn. Bấm "Edit title" mở form đơn giản cho user tự nhập title/thêm ảnh thủ công (chỉ cần input text + image picker cơ bản, chưa cần OCR hay logic phức tạp — đó là Phase 4).

---

## 7. Offline UI

```dart
// core/network/connectivity_service.dart
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get onlineStatusStream =>
      _connectivity.onConnectivityChanged.map((results) =>
          !results.contains(ConnectivityResult.none));

  Future<bool> get isOnline async =>
      !(await _connectivity.checkConnectivity()).contains(ConnectivityResult.none);
}
```

- **Offline banner**: hiện ở đầu Library screen khi `isOnline == false`, dùng string đã có sẵn ở Phase 0-1 brief mục 6 (`badgeOnlineToView`), không cần thêm string mới.
- **Item card**: khi offline VÀ item chưa có thumbnail cache local → hiện placeholder icon thay vì cố load network image (tránh loading spinner vô hạn).
- **Video items**: badge `badgeVideoUnavailableOffline` luôn hiện bất kể online/offline — vì video luôn cần mở app gốc/browser (theo quyết định "không tải video" ở `plan1_final_v2.md` mục 1), không phải chỉ hiện khi offline.

---

## 8. Metrics — Metadata Success Rate theo platform

```dart
// Đơn giản, nối tiếp local event log đã có từ Phase 1 — KHÔNG dựng analytics SDK mới
class MetricsLogger {
  static Future<void> logMetadataResult(PlatformEnum platform, MetadataStatusEnum status) async {
    // Ghi vào 1 bảng đơn giản hoặc local log file:
    // event: metadata_result, platform, status, timestamp
    // Mục tiêu: sau khi chạy thử với ~50+ item thật, tính lại được
    // % success/partial/failed theo TỪNG platform riêng biệt.
  }
}
```

Sau khi Phase 2 chạy thử với dữ liệu thật (khuyến nghị ≥ 50 item đã save qua Quick Save thật, đa dạng platform), tổng hợp lại:

| Platform | Success | Partial | Failed | Ghi chú |
|---|---|---|---|---|
| Reddit | ?% | ?% | ?% | |
| YouTube | ?% | ?% | ?% | |
| X | ?% | ?% | ?% | |
| TikTok | ?% | ?% | ?% | |
| Instagram | ?% | ?% | ?% | |

Bảng này (điền số liệu thật) là input bắt buộc cho quyết định ở Phase 3: nếu Instagram/TikTok failed rate quá cao (>50%), cân nhắc có nên đầu tư proxy backend (đã thiết kế nguyên tắc bảo mật ở `plan1_final_v2.md` mục 4) hay chấp nhận Quick Link fallback là trải nghiệm mặc định lâu dài cho 2 platform này.

---

## 9. Faceted Filter

```dart
// features/library/application/facet_filter_controller.dart
class FacetFilterState {
  final Set<PlatformEnum> platforms;
  final Set<ContentTypeEnum> contentTypes;
  final DateTimeRange? savedDateRange;
  final bool? hasNote;          // null = không lọc, true/false = lọc theo có/không có note
  final String? whySaved;       // null = không lọc

  const FacetFilterState({
    this.platforms = const {},
    this.contentTypes = const {},
    this.savedDateRange,
    this.hasNote,
    this.whySaved,
  });
}
```

Query tương ứng trong DAO dùng Drift's `where()` kết hợp các điều kiện động — agent tự viết theo pattern chuẩn của Drift (`buildExpression` hoặc nối điều kiện qua `&`). Không cần dựng query builder phức tạp riêng.

UI: thanh filter ngang phía trên Library (chips: platform icon, content type icon, "Has note", dropdown why_saved, date range picker). Không cần animation phức tạp — chip filter chuẩn Material 3 là đủ.

---

## 10. Acceptance Criteria — Definition of Done cho Phase 2

- [ ] Đã đọc và dùng số liệu thật từ `metadata_test_results.csv` (Phase 0) để quyết định thứ tự ưu tiên và mức timeout cho từng adapter — không dùng số liệu giả định trong `plan1_final_v2.md`.
- [ ] Cả 5 adapter (Reddit, YouTube, X, TikTok, Instagram) implement xong, **không adapter nào throw exception ra ngoài** trong bất kỳ test case lỗi nào (network down, timeout, response rỗng, JSON parse lỗi).
- [ ] `GenericOpenGraphAdapter` hoạt động như fallback cuối, verify với ≥5 URL thật mà adapter riêng của platform đó fail.
- [ ] `EnrichmentOrchestrator.processPendingQueue()` chạy đúng khi: app khởi động, app resume, ngay sau Quick Save — verify bằng cách log timestamp mỗi lần gọi.
- [ ] Giới hạn `_maxConcurrent = 3` được tôn trọng — verify không có quá 3 network request đồng thời (log hoặc debug network calls).
- [ ] Retry logic: verify với mock 1 lỗi timeout tạm thời → item được retry đúng `_maxRetries` lần trước khi rơi về fallback.
- [ ] Thumbnail cache: verify khi tổng dung lượng vượt 200MB, thumbnail cũ nhất bị xoá đúng, `saved_items` liên quan **không bị xoá**, chỉ mất ảnh cache.
- [ ] Quick Link Card hiển thị đúng khi `metadata_status = failed`, có nút "Edit title" hoạt động, style nhất quán với card thường (không trông như error state).
- [ ] Offline banner hiện/ẩn đúng theo `ConnectivityService.onlineStatusStream`, test bằng cách bật/tắt Wi-Fi thật trên thiết bị.
- [ ] Badge "Video requires Internet" hiện đúng cho mọi item `content_type = video`, không phụ thuộc trạng thái online/offline.
- [ ] Faceted filter: test với ≥3 tiêu chí kết hợp cùng lúc (vd: platform=tiktok AND hasNote=true AND date range) trả về đúng kết quả.
- [ ] Metrics: sau khi test với ≥50 item thật đa dạng platform, có được bảng % success/partial/failed theo từng platform, lưu lại kết quả (file hoặc log) để dùng cho quyết định Phase 3.
- [ ] Toàn bộ unit test cho adapter (mock HTTP response cho từng case success/partial/failed/timeout) pass 100%.

---

## 11. Những gì brief này CỐ TÌNH không cover (thuộc Phase 3+)

- Proxy backend / serverless function — chỉ cân nhắc ở Phase 3 nếu bảng metrics ở mục 8 cho thấy thực sự cần thiết (failed rate quá cao vì bị chặn trực tiếp từ client).
- Deep link scheme cụ thể cho Open Original (`instagram://`, `tiktok://`...).
- Rediscovery Engine, Local Backup/Restore.
- Smart Collections, Moodboard.
- Screenshot-to-Clip/OCR.
- Cloud sync.
- Bất kỳ OS-level background job nào (WorkManager) — nếu sau này thấy cơ chế "chạy khi app mở/resume" không đủ (ví dụ user ít mở app, hàng đợi pending tồn đọng lâu), đó là quyết định cần bàn riêng ở Phase 3, không tự thêm ở Phase 2.

Nếu agent thấy cần làm điều gì thuộc danh sách trên để hoàn thiện Phase 2 "cho đẹp", dừng lại và xác nhận lại trước khi tiếp tục — đúng nguyên tắc đã áp dụng ở Phase 0–1.