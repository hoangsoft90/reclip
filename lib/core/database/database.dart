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
  TextColumn get contentType => textEnum<ContentTypeEnum>()
      .withDefault(const Constant('unknown'))();
  TextColumn get metadataStatus => textEnum<MetadataStatusEnum>()
      .withDefault(const Constant('pending'))();
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
  TextColumn get linkStatus => textEnum<LinkStatusEnum>()
      .withDefault(const Constant('unknown'))();
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
  TextColumn get downloadStatus => textEnum<DownloadStatusEnum>()
      .withDefault(const Constant('pending'))();
  IntColumn get sizeBytes => integer().nullable()();
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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        // FTS5 virtual table
        await customStatement('''
          CREATE VIRTUAL TABLE IF NOT EXISTS saved_items_fts USING fts5(
            item_id UNINDEXED,
            title,
            description,
            note,
            content='',
            tokenize='unicode61'
          );
        ''');
        // Triggers for FTS5 sync
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS saved_items_ai AFTER INSERT ON saved_items BEGIN
            INSERT INTO saved_items_fts(item_id, title, description, note)
            VALUES (new.id, new.title, new.description, new.note);
          END;
        ''');
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS saved_items_au AFTER UPDATE ON saved_items BEGIN
            UPDATE saved_items_fts SET title = new.title, description = new.description, note = new.note
            WHERE item_id = new.id;
          END;
        ''');
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS saved_items_ad AFTER DELETE ON saved_items BEGIN
            DELETE FROM saved_items_fts WHERE item_id = old.id;
          END;
        ''');
      },
      onUpgrade: (m, from, to) async {
        // Reserved for future migrations
      },
    );
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
    MetadataStatusEnum? metadataStatus,
    String? note,
    String? whySaved,
    bool? isFavorite,
    bool? isArchived,
  }) async {
    await (update(savedItems)..where((t) => t.id.equals(id))).write(
      SavedItemsCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        description:
            description != null ? Value(description) : const Value.absent(),
        author: author != null ? Value(author) : const Value.absent(),
        authorUrl: authorUrl != null ? Value(authorUrl) : const Value.absent(),
        metadataStatus: metadataStatus != null
            ? Value(metadataStatus)
            : const Value.absent(),
        note: note != null ? Value(note) : const Value.absent(),
        whySaved: whySaved != null ? Value(whySaved) : const Value.absent(),
        isFavorite:
            isFavorite != null ? Value(isFavorite) : const Value.absent(),
        isArchived:
            isArchived != null ? Value(isArchived) : const Value.absent(),
      ),
    );
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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'reclip.db'));
    return NativeDatabase(file);
  });
}
