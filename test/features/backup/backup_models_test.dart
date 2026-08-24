import 'package:flutter_test/flutter_test.dart';
import 'package:reclip/features/backup/domain/backup_models.dart';

void main() {
  group('BackupPayload', () {
    test('toJson produces correct structure', () {
      final payload = BackupPayload(
        exportVersion: '1.0',
        exportedAt: 1234567890,
        itemCount: 2,
        savedItems: [
          {'id': '1', 'original_url': 'https://example.com/1'},
          {'id': '2', 'original_url': 'https://example.com/2'},
        ],
        collections: [],
        tags: [],
        itemCollections: [],
        itemTags: [],
      );

      final json = payload.toJson();

      expect(json['export_version'], '1.0');
      expect(json['exported_at'], 1234567890);
      expect(json['item_count'], 2);
      expect(json['saved_items'], hasLength(2));
      expect(json['collections'], isEmpty);
    });

    test('fromJson roundtrip preserves data', () {
      final original = BackupPayload(
        exportVersion: '1.0',
        exportedAt: 1234567890,
        itemCount: 1,
        savedItems: [
          {
            'id': '1',
            'original_url': 'https://example.com',
            'canonical_url': 'https://example.com',
            'platform': 'reddit',
            'content_type': 'text',
            'metadata_status': 'success',
            'title': 'Test',
            'description': null,
            'author': null,
            'author_url': null,
            'saved_at': 1234567890,
            'last_accessed_at': null,
            'is_favorite': false,
            'is_archived': false,
            'note': 'my note',
            'why_saved': 'learn_this',
            'link_status': 'unknown',
            'last_checked_at': null,
          },
        ],
        collections: [
          {'id': 'c1', 'name': 'Test Collection', 'icon': null, 'color': null, 'parent_id': null, 'is_smart': false, 'created_at': 1234567890},
        ],
        tags: [
          {'id': 't1', 'name': 'flutter', 'created_at': 1234567890},
        ],
        itemCollections: [],
        itemTags: [],
      );

      final json = original.toJson();
      final restored = BackupPayload.fromJson(json);

      expect(restored.exportVersion, '1.0');
      expect(restored.itemCount, 1);
      expect(restored.savedItems.first['title'], 'Test');
      expect(restored.savedItems.first['note'], 'my note');
      expect(restored.savedItems.first['why_saved'], 'learn_this');
      expect(restored.collections.first['name'], 'Test Collection');
      expect(restored.tags.first['name'], 'flutter');
    });
  });

  group('ImportResult', () {
    test('success factory creates correct result', () {
      final result = ImportResult.success(inserted: 5, merged: 3, skipped: 1);

      expect(result.success, true);
      expect(result.inserted, 5);
      expect(result.merged, 3);
      expect(result.skipped, 1);
      expect(result.errorMessage, isNull);
    });

    test('failed factory creates correct result', () {
      final result = ImportResult.failed('Corrupted file');

      expect(result.success, false);
      expect(result.errorMessage, 'Corrupted file');
      expect(result.inserted, 0);
      expect(result.merged, 0);
      expect(result.skipped, 0);
    });
  });
}
