import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/features/backup/domain/backup_models.dart';

class BackupImportService {
  final AppDatabase _db;

  BackupImportService(this._db);

  /// Import backup from a JSON file with checksum verification.
  Future<ImportResult> importFromFile(File file) async {
    final content = await file.readAsString();
    final wrapped = jsonDecode(content) as Map<String, dynamic>;

    final expectedChecksum = wrapped['checksum'] as String;
    final dataJson = jsonEncode(wrapped['data']);
    final actualChecksum = sha256.convert(utf8.encode(dataJson)).toString();

    if (expectedChecksum != actualChecksum) {
      return ImportResult.failed(
        'This backup file looks corrupted or was edited outside Reclip.',
      );
    }

    final payload = wrapped['data'] as Map<String, dynamic>;
    final exportVersion = payload['export_version'] as String;
    if (exportVersion != '1.0') {
      return ImportResult.failed(
        'Incompatible backup version: $exportVersion',
      );
    }

    return _mergeImport(BackupPayload.fromJson(payload));
  }

  /// Merge import: insert new items, merge tags/collections for existing items.
  /// Safe to run multiple times (idempotent).
  Future<ImportResult> _mergeImport(BackupPayload payload) async {
    int inserted = 0, merged = 0, skipped = 0;

    // Import saved items
    for (final itemData in payload.savedItems) {
      final existing = await _db.findByCanonicalUrl(itemData['canonical_url']);
      if (existing != null) {
        // Item exists — merge note/whySaved only if current is empty
        merged++;
        if ((existing.note == null || existing.note!.isEmpty) &&
            itemData['note'] != null &&
            (itemData['note'] as String).isNotEmpty) {
          await _db.updateSavedItem(
            id: existing.id,
            note: itemData['note'],
          );
        }
        if (existing.whySaved == null && itemData['why_saved'] != null) {
          await _db.updateSavedItem(
            id: existing.id,
            whySaved: itemData['why_saved'],
          );
        }
      } else {
        // New item — insert
        await _db.importSavedItem(itemData);
        inserted++;
      }
    }

    // Import collections (insertOnConflictUpdate)
    for (final collectionData in payload.collections) {
      await _db.importCollection(collectionData);
    }

    // Import tags (insertOnConflictUpdate)
    for (final tagData in payload.tags) {
      await _db.importTag(tagData);
    }

    // Import item-collections (insertOnConflictUpdate)
    for (final icData in payload.itemCollections) {
      await _db.importItemCollection(icData);
    }

    // Import item-tags (insertOnConflictUpdate)
    for (final itData in payload.itemTags) {
      await _db.importItemTag(itData);
    }

    return ImportResult.success(
      inserted: inserted,
      merged: merged,
      skipped: skipped,
    );
  }
}
