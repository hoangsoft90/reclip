import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// === Enums ===
enum PlatformEnum { reddit, instagram, tiktok, youtube, x, other }
enum ContentTypeEnum { video, image, gallery, text, link, mixed, unknown }
enum MetadataStatusEnum { pending, success, partial, failed }
enum LinkStatusEnum { alive, broken, unknown }
enum DownloadStatusEnum { pending, downloading, done, failed }

// === Tables ===

class SavedItems extends Table {
  TextColumn get id => text()();
  TextColumn get originalUrl => text()();
  TextColumn get canonicalUrl => text()();
  TextColumn get platform => textEnum<PlatformEnum>()();
  TextColumn get contentType => textEnum<ContentTypeEnum>()();
  TextColumn get metadataStatus => textEnum<MetadataStatusEnum>()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get authorUrl => text().nullable()();
  IntColumn get savedAt => integer()();
  IntColumn get lastAccessedAt => integer().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  TextColumn get whySaved => text().nullable()();
  TextColumn get linkStatus => textEnum<LinkStatusEnum>()();
  IntColumn get lastCheckedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get parentId => text().nullable()();
  BoolColumn get isSmart => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class ItemCollections extends Table {
  TextColumn get itemId => text()();
  TextColumn get collectionId => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {itemId, collectionId};
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class ItemTags extends Table {
  TextColumn get itemId => text()();
  TextColumn get tagId => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {itemId, tagId};
}

class Thumbnails extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get remoteUrl => text().nullable()();
  TextColumn get localPath => text().nullable()();
  TextColumn get downloadStatus => textEnum<DownloadStatusEnum>()();
  IntColumn get sizeBytes => integer().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// Phase 3 tables

class ResurfaceHistory extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  IntColumn get shownAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppEvents extends Table {
  TextColumn get id => text()();
  TextColumn get eventType => text()();
  TextColumn get itemId => text().nullable()();
  TextColumn get platform => text().nullable()();
  TextColumn get metadataStatus => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// === Database ===

@DriftDatabase(tables: [
  SavedItems,
  Collections,
  ItemCollections,
  Tags,
  ItemTags,
  Thumbnails,
  ResurfaceHistory,
  AppEvents,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _createFts5(m);
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(resurfaceHistory);
          await m.createTable(appEvents);
        }
      },
    );
  }

  Future<void> _createFts5(Migrator m) async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS saved_items_fts USING fts5(
        item_id UNINDEXED,
        original_url,
        title,
        description,
        note,
        content='',
        tokenize='unicode61'
      );
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS saved_items_ai AFTER INSERT ON saved_items BEGIN
        INSERT INTO saved_items_fts(item_id, original_url, title, description, note)
        VALUES (new.id, new.original_url, new.title, new.description, new.note);
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS saved_items_au AFTER UPDATE ON saved_items BEGIN
        UPDATE saved_items_fts SET original_url = new.original_url, title = new.title, description = new.description, note = new.note
        WHERE item_id = new.id;
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS saved_items_ad AFTER DELETE ON saved_items BEGIN
        DELETE FROM saved_items_fts WHERE item_id = old.id;
      END;
    ''');
  }

  // === SavedItems DAO methods ===

  Future<SavedItem> insertSavedItem({
    required String id,
    required String originalUrl,
    required String canonicalUrl,
    required PlatformEnum platform,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(savedItems).insert(
      SavedItemsCompanion.insert(
        id: id,
        originalUrl: originalUrl,
        canonicalUrl: canonicalUrl,
        platform: platform,
        contentType: ContentTypeEnum.unknown,
        metadataStatus: MetadataStatusEnum.pending,
        linkStatus: LinkStatusEnum.unknown,
        savedAt: now,
      ),
    );
    return (select(savedItems)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<SavedItem?> findByCanonicalUrl(String canonicalUrl) async {
    return (select(savedItems)
          ..where((t) => t.canonicalUrl.equals(canonicalUrl))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> touchLastAccessed(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(savedItems)..where((t) => t.id.equals(id)))
        .write(SavedItemsCompanion(lastAccessedAt: Value(now)));
  }

  Future<List<SavedItem>> getAllSavedItems() async {
    return (select(savedItems)
          ..orderBy([(t) => OrderingTerm.desc(t.savedAt)]))
        .get();
  }

  Future<List<SavedItem>> searchSavedItems(String query) async {
    final results = await customSelect(
      'SELECT item_id FROM saved_items_fts WHERE saved_items_fts MATCH ?',
      variables: [Variable.withString(query)],
    ).get();
    if (results.isEmpty) return [];
    final ids = results.map((r) => r.read<String>('item_id')).toList();
    return (select(savedItems)..where((t) => t.id.isIn(ids))).get();
  }

  Future<void> updateSavedItem({
    required String id,
    String? title,
    String? description,
    String? author,
    String? authorUrl,
    MetadataStatusEnum? status,
    ContentTypeEnum? contentType,
    String? note,
    String? whySaved,
    bool? isFavorite,
    bool? isArchived,
  }) async {
    await (update(savedItems)..where((t) => t.id.equals(id))).write(
      SavedItemsCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        description: description != null ? Value(description) : const Value.absent(),
        author: author != null ? Value(author) : const Value.absent(),
        authorUrl: authorUrl != null ? Value(authorUrl) : const Value.absent(),
        metadataStatus: status != null ? Value(status) : const Value.absent(),
        contentType: contentType != null ? Value(contentType) : const Value.absent(),
        note: note != null ? Value(note) : const Value.absent(),
        whySaved: whySaved != null ? Value(whySaved) : const Value.absent(),
        isFavorite: isFavorite != null ? Value(isFavorite) : const Value.absent(),
        isArchived: isArchived != null ? Value(isArchived) : const Value.absent(),
      ),
    );
  }

  Future<List<SavedItem>> findByMetadataStatus(MetadataStatusEnum status) async {
    return (select(savedItems)
          ..where((t) => t.metadataStatus.equals(status.name))
          ..orderBy([(t) => OrderingTerm.asc(t.savedAt)]))
        .get();
  }

  Future<List<SavedItem>> findActiveItems() async {
    return (select(savedItems)
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.savedAt)]))
        .get();
  }

  Future<List<SavedItem>> findSavedBefore(DateTime cutoff) async {
    return (select(savedItems)
          ..where((t) => t.savedAt.isSmallerOrEqualValue(cutoff.millisecondsSinceEpoch)))
        .get();
  }

  // === Collections DAO methods ===

  Future<Collection> insertCollection({
    required String id,
    required String name,
    String? icon,
    String? color,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(collections).insert(
      CollectionsCompanion.insert(
        id: id,
        name: name,
        icon: Value(icon),
        color: Value(color),
        createdAt: now,
      ),
    );
    return (select(collections)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> addToCollection(String itemId, String collectionId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(itemCollections).insert(
      ItemCollectionsCompanion.insert(
        itemId: itemId,
        collectionId: collectionId,
        createdAt: now,
      ),
    );
  }

  Future<List<Collection>> getCollectionsForItem(String itemId) async {
    final query = select(collections).join([
      innerJoin(
        itemCollections,
        itemCollections.collectionId.equalsExp(collections.id),
      ),
    ])
      ..where(itemCollections.itemId.equals(itemId));
    final results = await query.get();
    return results.map((r) => r.readTable(collections)).toList();
  }

  Future<List<Collection>> getAllCollections() async {
    return select(collections).get();
  }

  Future<void> removeCollectionFromItem(String itemId, String collectionId) async {
    await (delete(itemCollections)
          ..where((t) => t.itemId.equals(itemId) & t.collectionId.equals(collectionId)))
        .go();
  }

  // === Tags DAO methods ===

  Future<Tag> insertTag({
    required String id,
    required String name,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(tags).insert(
      TagsCompanion.insert(
        id: id,
        name: name,
        createdAt: now,
      ),
    );
    return (select(tags)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<Tag> getOrCreateTag(String name) async {
    final existing =
        await (select(tags)..where((t) => t.name.equals(name))).getSingleOrNull();
    if (existing != null) return existing;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return insertTag(id: id, name: name);
  }

  Future<void> addTagToItem(String itemId, String tagId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(itemTags).insert(
      ItemTagsCompanion.insert(
        itemId: itemId,
        tagId: tagId,
        createdAt: now,
      ),
    );
  }

  Future<List<Tag>> getTagsForItem(String itemId) async {
    final query = select(tags).join([
      innerJoin(
        itemTags,
        itemTags.tagId.equalsExp(tags.id),
      ),
    ])
      ..where(itemTags.itemId.equals(itemId));
    final results = await query.get();
    return results.map((r) => r.readTable(tags)).toList();
  }

  Future<List<Tag>> getAllTags() async {
    return select(tags).get();
  }

  Future<void> removeTagFromItem(String itemId, String tagId) async {
    await (delete(itemTags)
          ..where((t) => t.itemId.equals(itemId) & t.tagId.equals(tagId)))
        .go();
  }

  // === Thumbnails DAO methods ===

  Future<void> insertThumbnail({
    required String id,
    required String itemId,
    required String remoteUrl,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(thumbnails).insert(
      ThumbnailsCompanion.insert(
        id: id,
        itemId: itemId,
        remoteUrl: Value(remoteUrl),
        downloadStatus: DownloadStatusEnum.pending,
        createdAt: now,
      ),
    );
  }

  Future<Thumbnail?> findThumbnailByItemId(String itemId) async {
    return (select(thumbnails)
          ..where((t) => t.itemId.equals(itemId))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Map<String, String>> getThumbnailPathsForItems(List<String> itemIds) async {
    if (itemIds.isEmpty) return {};
    final results = await (select(thumbnails)
          ..where((t) => t.itemId.isIn(itemIds) & t.downloadStatus.equals('done') & t.localPath.isNotNull()))
        .get();
    final map = <String, String>{};
    for (final row in results) {
      map.putIfAbsent(row.itemId, () => row.localPath!);
    }
    return map;
  }

  Future<void> updateThumbnailStatus(String id, DownloadStatusEnum status) async {
    await (update(thumbnails)..where((t) => t.id.equals(id)))
        .write(ThumbnailsCompanion(downloadStatus: Value(status)));
  }

  Future<void> updateThumbnailResult(
    String id, {
    required String localPath,
    required int sizeBytes,
    required DownloadStatusEnum status,
  }) async {
    await (update(thumbnails)..where((t) => t.id.equals(id))).write(
      ThumbnailsCompanion(
        localPath: Value(localPath),
        sizeBytes: Value(sizeBytes),
        downloadStatus: Value(status),
      ),
    );
  }

  Future<void> clearThumbnailLocalPath(String id) async {
    await (update(thumbnails)..where((t) => t.id.equals(id)))
        .write(const ThumbnailsCompanion(localPath: Value(null)));
  }

  Future<int> sumThumbnailSizeBytes() async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(size_bytes), 0) as total FROM thumbnails WHERE download_status = ?',
      variables: [Variable.withString('done')],
    ).getSingle();
    return result.read<int>('total');
  }

  Future<void> deleteItem(String id) async {
    // Delete FTS entry
    await customStatement(
      "DELETE FROM saved_items_fts WHERE item_id = ?",
      [id],
    );
    // Delete related records
    await (delete(itemTags)..where((t) => t.itemId.equals(id))).go();
    await (delete(itemCollections)..where((t) => t.itemId.equals(id))).go();
    await (delete(thumbnails)..where((t) => t.itemId.equals(id))).go();
    await (delete(resurfaceHistory)..where((t) => t.itemId.equals(id))).go();
    await (delete(appEvents)..where((t) => t.itemId.equals(id))).go();
    // Delete the item itself
    await (delete(savedItems)..where((t) => t.id.equals(id))).go();
  }

  Future<SavedItem?> getSavedItemById(String id) async {
    return (select(savedItems)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Thumbnail>> getAllThumbnails() async {
    return select(thumbnails).get();
  }

  Future<List<Thumbnail>> findOldestDoneThumbnails({int limit = 10}) async {
    return (select(thumbnails)
          ..where((t) => t.downloadStatus.equals('done'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  // === ResurfaceHistory DAO methods (Phase 3) ===

  Future<void> recordResurfaceShown(String itemId) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await into(resurfaceHistory).insert(
      ResurfaceHistoryCompanion.insert(
        id: id,
        itemId: itemId,
        shownAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<List<String>> findResurfaceShownItemIds({required DateTime since}) async {
    final results = await (select(resurfaceHistory)
          ..where((t) => t.shownAt.isBiggerOrEqualValue(since.millisecondsSinceEpoch)))
        .get();
    return results.map((r) => r.itemId).toList();
  }

  Future<int> countResurfaceShownSince(DateTime since) async {
    final result = await customSelect(
      'SELECT COUNT(*) as cnt FROM resurface_history WHERE shown_at >= ?',
      variables: [Variable.withInt(since.millisecondsSinceEpoch)],
    ).getSingle();
    return result.read<int>('cnt');
  }

  // === AppEvents DAO methods (Phase 3) ===

  Future<void> logAppEvent({
    required String eventType,
    String? itemId,
    String? platform,
    String? metadataStatus,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString() +
        '_' + eventType.hashCode.toRadixString(16);
    await into(appEvents).insert(
      AppEventsCompanion.insert(
        id: id,
        eventType: eventType,
        itemId: Value(itemId),
        platform: Value(platform),
        metadataStatus: Value(metadataStatus),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<bool> hasOpenEventWithinDays({
    required String itemId,
    required int afterSavedAt,
    required int withinDays,
  }) async {
    final afterMs = afterSavedAt;
    final beforeMs = afterSavedAt + (withinDays * 24 * 60 * 60 * 1000);
    final result = await customSelect(
      '''SELECT COUNT(*) as cnt FROM app_events
         WHERE event_type = 'item_opened' AND item_id = ?
         AND created_at > ? AND created_at < ?''',
      variables: [
        Variable.withString(itemId),
        Variable.withInt(afterMs),
        Variable.withInt(beforeMs),
      ],
    ).getSingle();
    return result.read<int>('cnt') > 0;
  }

  Future<int> countDistinctDaysWithEvent({
    required String eventType,
    required DateTime from,
    required DateTime to,
  }) async {
    final fromMs = from.millisecondsSinceEpoch;
    final toMs = to.millisecondsSinceEpoch;
    final result = await customSelect(
      '''SELECT COUNT(DISTINCT (created_at / 86400000)) as days
         FROM app_events
         WHERE event_type = ? AND created_at >= ? AND created_at < ?''',
      variables: [
        Variable.withString(eventType),
        Variable.withInt(fromMs),
        Variable.withInt(toMs),
      ],
    ).getSingle();
    return result.read<int>('days');
  }

  // === Backup helper methods (Phase 3) ===

  Future<List<Map<String, dynamic>>> exportSavedItems() async {
    final items = await select(savedItems).get();
    return items.map((item) => {
      'id': item.id,
      'original_url': item.originalUrl,
      'canonical_url': item.canonicalUrl,
      'platform': item.platform.name,
      'content_type': item.contentType.name,
      'metadata_status': item.metadataStatus.name,
      'title': item.title,
      'description': item.description,
      'author': item.author,
      'author_url': item.authorUrl,
      'saved_at': item.savedAt,
      'last_accessed_at': item.lastAccessedAt,
      'is_favorite': item.isFavorite,
      'is_archived': item.isArchived,
      'note': item.note,
      'why_saved': item.whySaved,
      'link_status': item.linkStatus.name,
      'last_checked_at': item.lastCheckedAt,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> exportCollections() async {
    final items = await select(collections).get();
    return items.map((item) => {
      'id': item.id,
      'name': item.name,
      'icon': item.icon,
      'color': item.color,
      'parent_id': item.parentId,
      'is_smart': item.isSmart,
      'created_at': item.createdAt,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> exportTags() async {
    final items = await select(tags).get();
    return items.map((item) => {
      'id': item.id,
      'name': item.name,
      'created_at': item.createdAt,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> exportItemCollections() async {
    final items = await select(itemCollections).get();
    return items.map((item) => {
      'item_id': item.itemId,
      'collection_id': item.collectionId,
      'created_at': item.createdAt,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> exportItemTags() async {
    final items = await select(itemTags).get();
    return items.map((item) => {
      'item_id': item.itemId,
      'tag_id': item.tagId,
      'created_at': item.createdAt,
    }).toList();
  }

  Future<int> importSavedItem(Map<String, dynamic> data) async {
    final platform = PlatformEnum.values.firstWhere(
      (e) => e.name == data['platform'],
      orElse: () => PlatformEnum.other,
    );
    final contentType = ContentTypeEnum.values.firstWhere(
      (e) => e.name == data['content_type'],
      orElse: () => ContentTypeEnum.unknown,
    );
    final metadataStatus = MetadataStatusEnum.values.firstWhere(
      (e) => e.name == data['metadata_status'],
      orElse: () => MetadataStatusEnum.pending,
    );
    final linkStatus = LinkStatusEnum.values.firstWhere(
      (e) => e.name == data['link_status'],
      orElse: () => LinkStatusEnum.unknown,
    );
    return into(savedItems).insertOnConflictUpdate(
      SavedItemsCompanion.insert(
        id: data['id'],
        originalUrl: data['original_url'],
        canonicalUrl: data['canonical_url'],
        platform: platform,
        contentType: contentType,
        metadataStatus: metadataStatus,
        title: Value(data['title']),
        description: Value(data['description']),
        author: Value(data['author']),
        authorUrl: Value(data['author_url']),
        savedAt: data['saved_at'],
        lastAccessedAt: Value(data['last_accessed_at']),
        isFavorite: Value(data['is_favorite'] ?? false),
        isArchived: Value(data['is_archived'] ?? false),
        note: Value(data['note']),
        whySaved: Value(data['why_saved']),
        linkStatus: linkStatus,
        lastCheckedAt: Value(data['last_checked_at']),
      ),
    );
  }

  Future<void> importCollection(Map<String, dynamic> data) async {
    await into(collections).insertOnConflictUpdate(
      CollectionsCompanion.insert(
        id: data['id'],
        name: data['name'],
        icon: Value(data['icon']),
        color: Value(data['color']),
        createdAt: data['created_at'],
      ),
    );
  }

  Future<void> importTag(Map<String, dynamic> data) async {
    await into(tags).insertOnConflictUpdate(
      TagsCompanion.insert(
        id: data['id'],
        name: data['name'],
        createdAt: data['created_at'],
      ),
    );
  }

  Future<void> importItemCollection(Map<String, dynamic> data) async {
    await into(itemCollections).insertOnConflictUpdate(
      ItemCollectionsCompanion.insert(
        itemId: data['item_id'],
        collectionId: data['collection_id'],
        createdAt: data['created_at'],
      ),
    );
  }

  Future<void> importItemTag(Map<String, dynamic> data) async {
    await into(itemTags).insertOnConflictUpdate(
      ItemTagsCompanion.insert(
        itemId: data['item_id'],
        tagId: data['tag_id'],
        createdAt: data['created_at'],
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'reclip.db'));
    return NativeDatabase(file);
  });
}
