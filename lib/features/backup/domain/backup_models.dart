class BackupPayload {
  final String exportVersion;
  final int exportedAt;
  final int itemCount;
  final List<Map<String, dynamic>> savedItems;
  final List<Map<String, dynamic>> collections;
  final List<Map<String, dynamic>> tags;
  final List<Map<String, dynamic>> itemCollections;
  final List<Map<String, dynamic>> itemTags;

  BackupPayload({
    required this.exportVersion,
    required this.exportedAt,
    required this.itemCount,
    required this.savedItems,
    required this.collections,
    required this.tags,
    required this.itemCollections,
    required this.itemTags,
  });

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

  factory BackupPayload.fromJson(Map<String, dynamic> json) {
    return BackupPayload(
      exportVersion: json['export_version'] as String,
      exportedAt: json['exported_at'] as int,
      itemCount: json['item_count'] as int,
      savedItems: (json['saved_items'] as List).cast<Map<String, dynamic>>(),
      collections: (json['collections'] as List).cast<Map<String, dynamic>>(),
      tags: (json['tags'] as List).cast<Map<String, dynamic>>(),
      itemCollections: (json['item_collections'] as List).cast<Map<String, dynamic>>(),
      itemTags: (json['item_tags'] as List).cast<Map<String, dynamic>>(),
    );
  }
}

class ImportResult {
  final bool success;
  final String? errorMessage;
  final int inserted;
  final int merged;
  final int skipped;

  ImportResult._({
    required this.success,
    this.errorMessage,
    required this.inserted,
    required this.merged,
    required this.skipped,
  });

  factory ImportResult.success({
    required int inserted,
    required int merged,
    required int skipped,
  }) {
    return ImportResult._(
      success: true,
      inserted: inserted,
      merged: merged,
      skipped: skipped,
    );
  }

  factory ImportResult.failed(String message) {
    return ImportResult._(
      success: false,
      errorMessage: message,
      inserted: 0,
      merged: 0,
      skipped: 0,
    );
  }
}
