import 'dart:async';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/core/utils/id_generator.dart';

class ThumbnailDownloadService {
  final AppDatabase _db;
  static const int maxCacheSizeBytes = 200 * 1024 * 1024; // 200MB

  ThumbnailDownloadService(this._db);

  Future<void> enqueueDownload(String itemId, String remoteUrl) async {
    // Check if thumbnail already exists for this item
    final existing = await _db.findThumbnailByItemId(itemId);
    if (existing != null) return;

    final thumbId = IdGenerator.generate();
    await _db.insertThumbnail(
      id: thumbId,
      itemId: itemId,
      remoteUrl: remoteUrl,
    );
    unawaited(_download(thumbId, remoteUrl));
  }

  Future<void> _download(String thumbId, String remoteUrl) async {
    try {
      await _db.updateThumbnailStatus(thumbId, DownloadStatusEnum.downloading);
      final file = await DefaultCacheManager().getSingleFile(remoteUrl);
      final size = await file.length();
      await _db.updateThumbnailResult(
        thumbId,
        localPath: file.path,
        sizeBytes: size,
        status: DownloadStatusEnum.done,
      );
      await _enforceMaxCacheSize();
    } catch (e) {
      await _db.updateThumbnailStatus(thumbId, DownloadStatusEnum.failed);
    }
  }

  Future<void> _enforceMaxCacheSize() async {
    final totalSize = await _db.sumThumbnailSizeBytes();
    if (totalSize <= maxCacheSizeBytes) return;

    final oldestDone = await _db.findOldestDoneThumbnails(limit: 10);
    for (final thumb in oldestDone) {
      if (thumb.localPath != null) {
        final file = File(thumb.localPath!);
        if (await file.exists()) await file.delete();
      }
      await _db.clearThumbnailLocalPath(thumb.id);
      final newTotal = await _db.sumThumbnailSizeBytes();
      if (newTotal <= maxCacheSizeBytes) break;
    }
  }
}
