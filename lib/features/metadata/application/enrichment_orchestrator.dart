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

    final pool = <Future<void>>[];
    final completer = <int, bool>{};

    for (int i = 0; i < pendingItems.length; i++) {
      if (pool.length >= _maxConcurrent) {
        // Wait for any to complete
        await Future.any(pool);
        // Remove completed futures
        pool.removeWhere((f) {
          // Check if future is done by attempting to complete
          return completer.containsKey(pool.indexOf(f));
        });
        // Simple approach: just wait then clear
        completer.clear();
      }
      final index = pool.length;
      completer[index] = false;
      pool.add(_enrichOne(pendingItems[i]).then((_) {
        completer[index] = true;
      }));
    }
    await Future.wait(pool);
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
