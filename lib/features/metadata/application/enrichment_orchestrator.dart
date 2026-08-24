import 'package:reclip/core/database/database.dart';
import '../metadata_adapter_factory.dart';
import '../domain/metadata_result.dart';
import 'thumbnail_download_service.dart';
import 'metrics_logger.dart';

class EnrichmentOrchestrator {
  final AppDatabase _dao;
  final MetadataAdapterFactory _adapterFactory;
  final ThumbnailDownloadService _thumbnailService;

  static const int _maxConcurrent = 3;
  static const int _maxRetries = 2;

  EnrichmentOrchestrator(this._dao, this._adapterFactory, this._thumbnailService);

  /// Process all pending items. Call when: (a) app starts, (b) app resumes,
  /// (c) immediately after a new Quick Save.
  Future<void> processPendingQueue() async {
    MetricsLogger.logEvent('enrichment_queue_started');
    final pendingItems = await _dao.findByMetadataStatus(MetadataStatusEnum.pending);
    if (pendingItems.isEmpty) return;

    // Process in batches of _maxConcurrent
    for (var i = 0; i < pendingItems.length; i += _maxConcurrent) {
      final batch = pendingItems.sublist(
        i,
        (i + _maxConcurrent).clamp(0, pendingItems.length),
      );
      await Future.wait(
        batch.map((item) => _enrichOne(item)),
        eagerError: true,
      );
    }
    MetricsLogger.logEvent('enrichment_queue_completed');
  }

  Future<void> _enrichOne(SavedItem item, {int attempt = 0}) async {
    final adapter = _adapterFactory.forPlatform(item.platform);
    final result = await adapter.fetch(item.canonicalUrl);

    if (result.status == MetadataStatusEnum.failed && attempt < _maxRetries) {
      // Retry only network/timeout errors
      await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
      return _enrichOne(item, attempt: attempt + 1);
    }

    if (result.status == MetadataStatusEnum.failed) {
      // Try OpenGraph fallback before accepting failure
      final fallback = await _adapterFactory.openGraphFallback.fetch(item.canonicalUrl);
      await _persistResult(item, fallback);
      return;
    }

    await _persistResult(item, result);
  }

  Future<void> _persistResult(SavedItem item, MetadataResult result) async {
    await _dao.updateSavedItem(
      id: item.id,
      status: result.status,
      title: result.title,
      description: result.description,
      author: result.author,
    );

    if (result.thumbnailUrl != null) {
      await _thumbnailService.enqueueDownload(item.id, result.thumbnailUrl!);
    }

    MetricsLogger.logMetadataResult(item.platform, result.status);
  }
}
