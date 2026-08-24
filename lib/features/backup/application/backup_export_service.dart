import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/features/backup/domain/backup_models.dart';

class BackupExportService {
  final AppDatabase _db;

  BackupExportService(this._db);

  /// Export all data as a JSON backup file.
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

  /// Share the backup file via system share sheet.
  Future<void> shareBackupFile(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'Reclip backup');
  }

  Future<BackupPayload> _buildPayload() async {
    final savedItems = await _db.exportSavedItems();
    final collections = await _db.exportCollections();
    final tags = await _db.exportTags();
    final itemCollections = await _db.exportItemCollections();
    final itemTags = await _db.exportItemTags();

    return BackupPayload(
      exportVersion: '1.0',
      exportedAt: DateTime.now().millisecondsSinceEpoch,
      itemCount: savedItems.length,
      savedItems: savedItems,
      collections: collections,
      tags: tags,
      itemCollections: itemCollections,
      itemTags: itemTags,
    );
  }
}
