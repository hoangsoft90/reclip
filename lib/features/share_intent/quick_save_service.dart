import 'dart:async';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/core/url/url_normalizer.dart';
import 'package:reclip/core/url/platform_detector.dart';
import 'package:reclip/core/utils/id_generator.dart';

/// Result of a quick save operation
class SaveResult {
  final SaveResultType type;
  final SavedItem? item;

  const SaveResult._({required this.type, this.item});

  factory SaveResult.savedNew(SavedItem item) =>
      SaveResult._(type: SaveResultType.savedNew, item: item);

  factory SaveResult.alreadyExists(SavedItem item) =>
      SaveResult._(type: SaveResultType.alreadyExists, item: item);

  bool get isNew => type == SaveResultType.savedNew;
  bool get isDuplicate => type == SaveResultType.alreadyExists;
}

enum SaveResultType { savedNew, alreadyExists }

class QuickSaveService {
  final AppDatabase _db;

  QuickSaveService(this._db);

  /// Quick Save flow: normalize → dedup check → insert → return result
  /// MUST complete in < 300ms (no network, no metadata fetch)
  Future<SaveResult> quickSave(String rawUrl) async {
    final stopwatch = Stopwatch()..start();

    final canonical = UrlNormalizer.canonicalize(rawUrl);
    final existing = await _db.findByCanonicalUrl(canonical);

    if (existing == null) {
      // Case A: new URL → create minimal record immediately
      final id = IdGenerator.generate();
      final platform = PlatformDetector.detect(rawUrl);
      final item = await _db.insertSavedItem(
        id: id,
        originalUrl: rawUrl,
        canonicalUrl: canonical,
        platform: platform,
      );

      stopwatch.stop();
      // ignore: avoid_print
      print('[QuickSave] New item saved in ${stopwatch.elapsedMilliseconds}ms');

      return SaveResult.savedNew(item);
    } else {
      // Case B: already exists → update lastAccessedAt, don't create duplicate
      await _db.touchLastAccessed(existing.id);

      stopwatch.stop();
      // ignore: avoid_print
      print(
          '[QuickSave] Already exists, touched in ${stopwatch.elapsedMilliseconds}ms');

      // Re-fetch to get updated lastAccessedAt
      final updated = await (_db.select(_db.savedItems)
            ..where((t) => t.id.equals(existing.id)))
          .getSingle();
      return SaveResult.alreadyExists(updated);
    }
  }
}
