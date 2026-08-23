// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SavedItemsTable extends SavedItems
    with TableInfo<$SavedItemsTable, SavedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originalUrlMeta =
      const VerificationMeta('originalUrl');
  @override
  late final GeneratedColumn<String> originalUrl = GeneratedColumn<String>(
      'original_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _canonicalUrlMeta =
      const VerificationMeta('canonicalUrl');
  @override
  late final GeneratedColumn<String> canonicalUrl = GeneratedColumn<String>(
      'canonical_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<PlatformEnum, String> platform =
      GeneratedColumn<String>('platform', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<PlatformEnum>($SavedItemsTable.$converterplatform);
  @override
  late final GeneratedColumnWithTypeConverter<ContentTypeEnum, String>
      contentType = GeneratedColumn<String>('content_type', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('unknown'))
          .withConverter<ContentTypeEnum>(
              $SavedItemsTable.$convertercontentType);
  @override
  late final GeneratedColumnWithTypeConverter<MetadataStatusEnum, String>
      metadataStatus = GeneratedColumn<String>(
              'metadata_status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('pending'))
          .withConverter<MetadataStatusEnum>(
              $SavedItemsTable.$convertermetadataStatus);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _authorUrlMeta =
      const VerificationMeta('authorUrl');
  @override
  late final GeneratedColumn<String> authorUrl = GeneratedColumn<String>(
      'author_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _savedAtMeta =
      const VerificationMeta('savedAt');
  @override
  late final GeneratedColumn<int> savedAt = GeneratedColumn<int>(
      'saved_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastAccessedAtMeta =
      const VerificationMeta('lastAccessedAt');
  @override
  late final GeneratedColumn<int> lastAccessedAt = GeneratedColumn<int>(
      'last_accessed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _whySavedMeta =
      const VerificationMeta('whySaved');
  @override
  late final GeneratedColumn<String> whySaved = GeneratedColumn<String>(
      'why_saved', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<LinkStatusEnum, String>
      linkStatus = GeneratedColumn<String>('link_status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('unknown'))
          .withConverter<LinkStatusEnum>($SavedItemsTable.$converterlinkStatus);
  static const VerificationMeta _lastCheckedAtMeta =
      const VerificationMeta('lastCheckedAt');
  @override
  late final GeneratedColumn<int> lastCheckedAt = GeneratedColumn<int>(
      'last_checked_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        originalUrl,
        canonicalUrl,
        platform,
        contentType,
        metadataStatus,
        title,
        description,
        author,
        authorUrl,
        savedAt,
        lastAccessedAt,
        isFavorite,
        isArchived,
        note,
        whySaved,
        linkStatus,
        lastCheckedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_items';
  @override
  VerificationContext validateIntegrity(Insertable<SavedItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('original_url')) {
      context.handle(
          _originalUrlMeta,
          originalUrl.isAcceptableOrUnknown(
              data['original_url']!, _originalUrlMeta));
    } else if (isInserting) {
      context.missing(_originalUrlMeta);
    }
    if (data.containsKey('canonical_url')) {
      context.handle(
          _canonicalUrlMeta,
          canonicalUrl.isAcceptableOrUnknown(
              data['canonical_url']!, _canonicalUrlMeta));
    } else if (isInserting) {
      context.missing(_canonicalUrlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('author_url')) {
      context.handle(_authorUrlMeta,
          authorUrl.isAcceptableOrUnknown(data['author_url']!, _authorUrlMeta));
    }
    if (data.containsKey('saved_at')) {
      context.handle(_savedAtMeta,
          savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta));
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
          _lastAccessedAtMeta,
          lastAccessedAt.isAcceptableOrUnknown(
              data['last_accessed_at']!, _lastAccessedAtMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('why_saved')) {
      context.handle(_whySavedMeta,
          whySaved.isAcceptableOrUnknown(data['why_saved']!, _whySavedMeta));
    }
    if (data.containsKey('last_checked_at')) {
      context.handle(
          _lastCheckedAtMeta,
          lastCheckedAt.isAcceptableOrUnknown(
              data['last_checked_at']!, _lastCheckedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      originalUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_url'])!,
      canonicalUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}canonical_url'])!,
      platform: $SavedItemsTable.$converterplatform.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform'])!),
      contentType: $SavedItemsTable.$convertercontentType.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}content_type'])!),
      metadataStatus: $SavedItemsTable.$convertermetadataStatus.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}metadata_status'])!),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      authorUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author_url']),
      savedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}saved_at'])!,
      lastAccessedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_accessed_at']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      whySaved: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}why_saved']),
      linkStatus: $SavedItemsTable.$converterlinkStatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}link_status'])!),
      lastCheckedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_checked_at']),
    );
  }

  @override
  $SavedItemsTable createAlias(String alias) {
    return $SavedItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PlatformEnum, String, String> $converterplatform =
      const EnumNameConverter<PlatformEnum>(PlatformEnum.values);
  static JsonTypeConverter2<ContentTypeEnum, String, String>
      $convertercontentType =
      const EnumNameConverter<ContentTypeEnum>(ContentTypeEnum.values);
  static JsonTypeConverter2<MetadataStatusEnum, String, String>
      $convertermetadataStatus =
      const EnumNameConverter<MetadataStatusEnum>(MetadataStatusEnum.values);
  static JsonTypeConverter2<LinkStatusEnum, String, String>
      $converterlinkStatus =
      const EnumNameConverter<LinkStatusEnum>(LinkStatusEnum.values);
}

class SavedItem extends DataClass implements Insertable<SavedItem> {
  final String id;
  final String originalUrl;
  final String canonicalUrl;
  final PlatformEnum platform;
  final ContentTypeEnum contentType;
  final MetadataStatusEnum metadataStatus;
  final String? title;
  final String? description;
  final String? author;
  final String? authorUrl;
  final int savedAt;
  final int? lastAccessedAt;
  final bool isFavorite;
  final bool isArchived;
  final String? note;
  final String? whySaved;
  final LinkStatusEnum linkStatus;
  final int? lastCheckedAt;
  const SavedItem(
      {required this.id,
      required this.originalUrl,
      required this.canonicalUrl,
      required this.platform,
      required this.contentType,
      required this.metadataStatus,
      this.title,
      this.description,
      this.author,
      this.authorUrl,
      required this.savedAt,
      this.lastAccessedAt,
      required this.isFavorite,
      required this.isArchived,
      this.note,
      this.whySaved,
      required this.linkStatus,
      this.lastCheckedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['original_url'] = Variable<String>(originalUrl);
    map['canonical_url'] = Variable<String>(canonicalUrl);
    {
      map['platform'] =
          Variable<String>($SavedItemsTable.$converterplatform.toSql(platform));
    }
    {
      map['content_type'] = Variable<String>(
          $SavedItemsTable.$convertercontentType.toSql(contentType));
    }
    {
      map['metadata_status'] = Variable<String>(
          $SavedItemsTable.$convertermetadataStatus.toSql(metadataStatus));
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || authorUrl != null) {
      map['author_url'] = Variable<String>(authorUrl);
    }
    map['saved_at'] = Variable<int>(savedAt);
    if (!nullToAbsent || lastAccessedAt != null) {
      map['last_accessed_at'] = Variable<int>(lastAccessedAt);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || whySaved != null) {
      map['why_saved'] = Variable<String>(whySaved);
    }
    {
      map['link_status'] = Variable<String>(
          $SavedItemsTable.$converterlinkStatus.toSql(linkStatus));
    }
    if (!nullToAbsent || lastCheckedAt != null) {
      map['last_checked_at'] = Variable<int>(lastCheckedAt);
    }
    return map;
  }

  SavedItemsCompanion toCompanion(bool nullToAbsent) {
    return SavedItemsCompanion(
      id: Value(id),
      originalUrl: Value(originalUrl),
      canonicalUrl: Value(canonicalUrl),
      platform: Value(platform),
      contentType: Value(contentType),
      metadataStatus: Value(metadataStatus),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      authorUrl: authorUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(authorUrl),
      savedAt: Value(savedAt),
      lastAccessedAt: lastAccessedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccessedAt),
      isFavorite: Value(isFavorite),
      isArchived: Value(isArchived),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      whySaved: whySaved == null && nullToAbsent
          ? const Value.absent()
          : Value(whySaved),
      linkStatus: Value(linkStatus),
      lastCheckedAt: lastCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedAt),
    );
  }

  factory SavedItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedItem(
      id: serializer.fromJson<String>(json['id']),
      originalUrl: serializer.fromJson<String>(json['originalUrl']),
      canonicalUrl: serializer.fromJson<String>(json['canonicalUrl']),
      platform: $SavedItemsTable.$converterplatform
          .fromJson(serializer.fromJson<String>(json['platform'])),
      contentType: $SavedItemsTable.$convertercontentType
          .fromJson(serializer.fromJson<String>(json['contentType'])),
      metadataStatus: $SavedItemsTable.$convertermetadataStatus
          .fromJson(serializer.fromJson<String>(json['metadataStatus'])),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      author: serializer.fromJson<String?>(json['author']),
      authorUrl: serializer.fromJson<String?>(json['authorUrl']),
      savedAt: serializer.fromJson<int>(json['savedAt']),
      lastAccessedAt: serializer.fromJson<int?>(json['lastAccessedAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      note: serializer.fromJson<String?>(json['note']),
      whySaved: serializer.fromJson<String?>(json['whySaved']),
      linkStatus: $SavedItemsTable.$converterlinkStatus
          .fromJson(serializer.fromJson<String>(json['linkStatus'])),
      lastCheckedAt: serializer.fromJson<int?>(json['lastCheckedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'originalUrl': serializer.toJson<String>(originalUrl),
      'canonicalUrl': serializer.toJson<String>(canonicalUrl),
      'platform': serializer
          .toJson<String>($SavedItemsTable.$converterplatform.toJson(platform)),
      'contentType': serializer.toJson<String>(
          $SavedItemsTable.$convertercontentType.toJson(contentType)),
      'metadataStatus': serializer.toJson<String>(
          $SavedItemsTable.$convertermetadataStatus.toJson(metadataStatus)),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'author': serializer.toJson<String?>(author),
      'authorUrl': serializer.toJson<String?>(authorUrl),
      'savedAt': serializer.toJson<int>(savedAt),
      'lastAccessedAt': serializer.toJson<int?>(lastAccessedAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isArchived': serializer.toJson<bool>(isArchived),
      'note': serializer.toJson<String?>(note),
      'whySaved': serializer.toJson<String?>(whySaved),
      'linkStatus': serializer.toJson<String>(
          $SavedItemsTable.$converterlinkStatus.toJson(linkStatus)),
      'lastCheckedAt': serializer.toJson<int?>(lastCheckedAt),
    };
  }

  SavedItem copyWith(
          {String? id,
          String? originalUrl,
          String? canonicalUrl,
          PlatformEnum? platform,
          ContentTypeEnum? contentType,
          MetadataStatusEnum? metadataStatus,
          Value<String?> title = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> author = const Value.absent(),
          Value<String?> authorUrl = const Value.absent(),
          int? savedAt,
          Value<int?> lastAccessedAt = const Value.absent(),
          bool? isFavorite,
          bool? isArchived,
          Value<String?> note = const Value.absent(),
          Value<String?> whySaved = const Value.absent(),
          LinkStatusEnum? linkStatus,
          Value<int?> lastCheckedAt = const Value.absent()}) =>
      SavedItem(
        id: id ?? this.id,
        originalUrl: originalUrl ?? this.originalUrl,
        canonicalUrl: canonicalUrl ?? this.canonicalUrl,
        platform: platform ?? this.platform,
        contentType: contentType ?? this.contentType,
        metadataStatus: metadataStatus ?? this.metadataStatus,
        title: title.present ? title.value : this.title,
        description: description.present ? description.value : this.description,
        author: author.present ? author.value : this.author,
        authorUrl: authorUrl.present ? authorUrl.value : this.authorUrl,
        savedAt: savedAt ?? this.savedAt,
        lastAccessedAt:
            lastAccessedAt.present ? lastAccessedAt.value : this.lastAccessedAt,
        isFavorite: isFavorite ?? this.isFavorite,
        isArchived: isArchived ?? this.isArchived,
        note: note.present ? note.value : this.note,
        whySaved: whySaved.present ? whySaved.value : this.whySaved,
        linkStatus: linkStatus ?? this.linkStatus,
        lastCheckedAt:
            lastCheckedAt.present ? lastCheckedAt.value : this.lastCheckedAt,
      );
  SavedItem copyWithCompanion(SavedItemsCompanion data) {
    return SavedItem(
      id: data.id.present ? data.id.value : this.id,
      originalUrl:
          data.originalUrl.present ? data.originalUrl.value : this.originalUrl,
      canonicalUrl: data.canonicalUrl.present
          ? data.canonicalUrl.value
          : this.canonicalUrl,
      platform: data.platform.present ? data.platform.value : this.platform,
      contentType:
          data.contentType.present ? data.contentType.value : this.contentType,
      metadataStatus: data.metadataStatus.present
          ? data.metadataStatus.value
          : this.metadataStatus,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      author: data.author.present ? data.author.value : this.author,
      authorUrl: data.authorUrl.present ? data.authorUrl.value : this.authorUrl,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      note: data.note.present ? data.note.value : this.note,
      whySaved: data.whySaved.present ? data.whySaved.value : this.whySaved,
      linkStatus:
          data.linkStatus.present ? data.linkStatus.value : this.linkStatus,
      lastCheckedAt: data.lastCheckedAt.present
          ? data.lastCheckedAt.value
          : this.lastCheckedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedItem(')
          ..write('id: $id, ')
          ..write('originalUrl: $originalUrl, ')
          ..write('canonicalUrl: $canonicalUrl, ')
          ..write('platform: $platform, ')
          ..write('contentType: $contentType, ')
          ..write('metadataStatus: $metadataStatus, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('author: $author, ')
          ..write('authorUrl: $authorUrl, ')
          ..write('savedAt: $savedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('note: $note, ')
          ..write('whySaved: $whySaved, ')
          ..write('linkStatus: $linkStatus, ')
          ..write('lastCheckedAt: $lastCheckedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      originalUrl,
      canonicalUrl,
      platform,
      contentType,
      metadataStatus,
      title,
      description,
      author,
      authorUrl,
      savedAt,
      lastAccessedAt,
      isFavorite,
      isArchived,
      note,
      whySaved,
      linkStatus,
      lastCheckedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedItem &&
          other.id == this.id &&
          other.originalUrl == this.originalUrl &&
          other.canonicalUrl == this.canonicalUrl &&
          other.platform == this.platform &&
          other.contentType == this.contentType &&
          other.metadataStatus == this.metadataStatus &&
          other.title == this.title &&
          other.description == this.description &&
          other.author == this.author &&
          other.authorUrl == this.authorUrl &&
          other.savedAt == this.savedAt &&
          other.lastAccessedAt == this.lastAccessedAt &&
          other.isFavorite == this.isFavorite &&
          other.isArchived == this.isArchived &&
          other.note == this.note &&
          other.whySaved == this.whySaved &&
          other.linkStatus == this.linkStatus &&
          other.lastCheckedAt == this.lastCheckedAt);
}

class SavedItemsCompanion extends UpdateCompanion<SavedItem> {
  final Value<String> id;
  final Value<String> originalUrl;
  final Value<String> canonicalUrl;
  final Value<PlatformEnum> platform;
  final Value<ContentTypeEnum> contentType;
  final Value<MetadataStatusEnum> metadataStatus;
  final Value<String?> title;
  final Value<String?> description;
  final Value<String?> author;
  final Value<String?> authorUrl;
  final Value<int> savedAt;
  final Value<int?> lastAccessedAt;
  final Value<bool> isFavorite;
  final Value<bool> isArchived;
  final Value<String?> note;
  final Value<String?> whySaved;
  final Value<LinkStatusEnum> linkStatus;
  final Value<int?> lastCheckedAt;
  final Value<int> rowid;
  const SavedItemsCompanion({
    this.id = const Value.absent(),
    this.originalUrl = const Value.absent(),
    this.canonicalUrl = const Value.absent(),
    this.platform = const Value.absent(),
    this.contentType = const Value.absent(),
    this.metadataStatus = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.author = const Value.absent(),
    this.authorUrl = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.note = const Value.absent(),
    this.whySaved = const Value.absent(),
    this.linkStatus = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedItemsCompanion.insert({
    required String id,
    required String originalUrl,
    required String canonicalUrl,
    required PlatformEnum platform,
    this.contentType = const Value.absent(),
    this.metadataStatus = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.author = const Value.absent(),
    this.authorUrl = const Value.absent(),
    required int savedAt,
    this.lastAccessedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.note = const Value.absent(),
    this.whySaved = const Value.absent(),
    this.linkStatus = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        originalUrl = Value(originalUrl),
        canonicalUrl = Value(canonicalUrl),
        platform = Value(platform),
        savedAt = Value(savedAt);
  static Insertable<SavedItem> custom({
    Expression<String>? id,
    Expression<String>? originalUrl,
    Expression<String>? canonicalUrl,
    Expression<String>? platform,
    Expression<String>? contentType,
    Expression<String>? metadataStatus,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? author,
    Expression<String>? authorUrl,
    Expression<int>? savedAt,
    Expression<int>? lastAccessedAt,
    Expression<bool>? isFavorite,
    Expression<bool>? isArchived,
    Expression<String>? note,
    Expression<String>? whySaved,
    Expression<String>? linkStatus,
    Expression<int>? lastCheckedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (originalUrl != null) 'original_url': originalUrl,
      if (canonicalUrl != null) 'canonical_url': canonicalUrl,
      if (platform != null) 'platform': platform,
      if (contentType != null) 'content_type': contentType,
      if (metadataStatus != null) 'metadata_status': metadataStatus,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (author != null) 'author': author,
      if (authorUrl != null) 'author_url': authorUrl,
      if (savedAt != null) 'saved_at': savedAt,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isArchived != null) 'is_archived': isArchived,
      if (note != null) 'note': note,
      if (whySaved != null) 'why_saved': whySaved,
      if (linkStatus != null) 'link_status': linkStatus,
      if (lastCheckedAt != null) 'last_checked_at': lastCheckedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? originalUrl,
      Value<String>? canonicalUrl,
      Value<PlatformEnum>? platform,
      Value<ContentTypeEnum>? contentType,
      Value<MetadataStatusEnum>? metadataStatus,
      Value<String?>? title,
      Value<String?>? description,
      Value<String?>? author,
      Value<String?>? authorUrl,
      Value<int>? savedAt,
      Value<int?>? lastAccessedAt,
      Value<bool>? isFavorite,
      Value<bool>? isArchived,
      Value<String?>? note,
      Value<String?>? whySaved,
      Value<LinkStatusEnum>? linkStatus,
      Value<int?>? lastCheckedAt,
      Value<int>? rowid}) {
    return SavedItemsCompanion(
      id: id ?? this.id,
      originalUrl: originalUrl ?? this.originalUrl,
      canonicalUrl: canonicalUrl ?? this.canonicalUrl,
      platform: platform ?? this.platform,
      contentType: contentType ?? this.contentType,
      metadataStatus: metadataStatus ?? this.metadataStatus,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      authorUrl: authorUrl ?? this.authorUrl,
      savedAt: savedAt ?? this.savedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      note: note ?? this.note,
      whySaved: whySaved ?? this.whySaved,
      linkStatus: linkStatus ?? this.linkStatus,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (originalUrl.present) {
      map['original_url'] = Variable<String>(originalUrl.value);
    }
    if (canonicalUrl.present) {
      map['canonical_url'] = Variable<String>(canonicalUrl.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(
          $SavedItemsTable.$converterplatform.toSql(platform.value));
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(
          $SavedItemsTable.$convertercontentType.toSql(contentType.value));
    }
    if (metadataStatus.present) {
      map['metadata_status'] = Variable<String>($SavedItemsTable
          .$convertermetadataStatus
          .toSql(metadataStatus.value));
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (authorUrl.present) {
      map['author_url'] = Variable<String>(authorUrl.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<int>(savedAt.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<int>(lastAccessedAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (whySaved.present) {
      map['why_saved'] = Variable<String>(whySaved.value);
    }
    if (linkStatus.present) {
      map['link_status'] = Variable<String>(
          $SavedItemsTable.$converterlinkStatus.toSql(linkStatus.value));
    }
    if (lastCheckedAt.present) {
      map['last_checked_at'] = Variable<int>(lastCheckedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedItemsCompanion(')
          ..write('id: $id, ')
          ..write('originalUrl: $originalUrl, ')
          ..write('canonicalUrl: $canonicalUrl, ')
          ..write('platform: $platform, ')
          ..write('contentType: $contentType, ')
          ..write('metadataStatus: $metadataStatus, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('author: $author, ')
          ..write('authorUrl: $authorUrl, ')
          ..write('savedAt: $savedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('note: $note, ')
          ..write('whySaved: $whySaved, ')
          ..write('linkStatus: $linkStatus, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSmartMeta =
      const VerificationMeta('isSmart');
  @override
  late final GeneratedColumn<bool> isSmart = GeneratedColumn<bool>(
      'is_smart', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_smart" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, icon, color, parentId, isSmart, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(Insertable<Collection> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('is_smart')) {
      context.handle(_isSmartMeta,
          isSmart.isAcceptableOrUnknown(data['is_smart']!, _isSmartMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      isSmart: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_smart'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final String? parentId;
  final bool isSmart;
  final int createdAt;
  const Collection(
      {required this.id,
      required this.name,
      this.icon,
      this.color,
      this.parentId,
      required this.isSmart,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['is_smart'] = Variable<bool>(isSmart);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      isSmart: Value(isSmart),
      createdAt: Value(createdAt),
    );
  }

  factory Collection.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      isSmart: serializer.fromJson<bool>(json['isSmart']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'parentId': serializer.toJson<String?>(parentId),
      'isSmart': serializer.toJson<bool>(isSmart),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Collection copyWith(
          {String? id,
          String? name,
          Value<String?> icon = const Value.absent(),
          Value<String?> color = const Value.absent(),
          Value<String?> parentId = const Value.absent(),
          bool? isSmart,
          int? createdAt}) =>
      Collection(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon.present ? icon.value : this.icon,
        color: color.present ? color.value : this.color,
        parentId: parentId.present ? parentId.value : this.parentId,
        isSmart: isSmart ?? this.isSmart,
        createdAt: createdAt ?? this.createdAt,
      );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      isSmart: data.isSmart.present ? data.isSmart.value : this.isSmart,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('isSmart: $isSmart, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, icon, color, parentId, isSmart, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.parentId == this.parentId &&
          other.isSmart == this.isSmart &&
          other.createdAt == this.createdAt);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<String?> parentId;
  final Value<bool> isSmart;
  final Value<int> createdAt;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isSmart = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String id,
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isSmart = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Collection> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<String>? parentId,
    Expression<bool>? isSmart,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (parentId != null) 'parent_id': parentId,
      if (isSmart != null) 'is_smart': isSmart,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? icon,
      Value<String?>? color,
      Value<String?>? parentId,
      Value<bool>? isSmart,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      isSmart: isSmart ?? this.isSmart,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (isSmart.present) {
      map['is_smart'] = Variable<bool>(isSmart.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('isSmart: $isSmart, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemCollectionsTable extends ItemCollections
    with TableInfo<$ItemCollectionsTable, ItemCollection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemCollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _collectionIdMeta =
      const VerificationMeta('collectionId');
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
      'collection_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [itemId, collectionId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_collections';
  @override
  VerificationContext validateIntegrity(Insertable<ItemCollection> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
          _collectionIdMeta,
          collectionId.isAcceptableOrUnknown(
              data['collection_id']!, _collectionIdMeta));
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId, collectionId};
  @override
  ItemCollection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemCollection(
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      collectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collection_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ItemCollectionsTable createAlias(String alias) {
    return $ItemCollectionsTable(attachedDatabase, alias);
  }
}

class ItemCollection extends DataClass implements Insertable<ItemCollection> {
  final String itemId;
  final String collectionId;
  final int createdAt;
  const ItemCollection(
      {required this.itemId,
      required this.collectionId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['collection_id'] = Variable<String>(collectionId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ItemCollectionsCompanion toCompanion(bool nullToAbsent) {
    return ItemCollectionsCompanion(
      itemId: Value(itemId),
      collectionId: Value(collectionId),
      createdAt: Value(createdAt),
    );
  }

  factory ItemCollection.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemCollection(
      itemId: serializer.fromJson<String>(json['itemId']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'collectionId': serializer.toJson<String>(collectionId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ItemCollection copyWith(
          {String? itemId, String? collectionId, int? createdAt}) =>
      ItemCollection(
        itemId: itemId ?? this.itemId,
        collectionId: collectionId ?? this.collectionId,
        createdAt: createdAt ?? this.createdAt,
      );
  ItemCollection copyWithCompanion(ItemCollectionsCompanion data) {
    return ItemCollection(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemCollection(')
          ..write('itemId: $itemId, ')
          ..write('collectionId: $collectionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, collectionId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemCollection &&
          other.itemId == this.itemId &&
          other.collectionId == this.collectionId &&
          other.createdAt == this.createdAt);
}

class ItemCollectionsCompanion extends UpdateCompanion<ItemCollection> {
  final Value<String> itemId;
  final Value<String> collectionId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ItemCollectionsCompanion({
    this.itemId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemCollectionsCompanion.insert({
    required String itemId,
    required String collectionId,
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : itemId = Value(itemId),
        collectionId = Value(collectionId),
        createdAt = Value(createdAt);
  static Insertable<ItemCollection> custom({
    Expression<String>? itemId,
    Expression<String>? collectionId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (collectionId != null) 'collection_id': collectionId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemCollectionsCompanion copyWith(
      {Value<String>? itemId,
      Value<String>? collectionId,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return ItemCollectionsCompanion(
      itemId: itemId ?? this.itemId,
      collectionId: collectionId ?? this.collectionId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemCollectionsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('collectionId: $collectionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  final int createdAt;
  const Tag({required this.id, required this.name, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Tag copyWith({String? id, String? name, int? createdAt}) => Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> createdAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemTagsTable extends ItemTags with TableInfo<$ItemTagsTable, ItemTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [itemId, tagId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_tags';
  @override
  VerificationContext validateIntegrity(Insertable<ItemTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId, tagId};
  @override
  ItemTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemTag(
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ItemTagsTable createAlias(String alias) {
    return $ItemTagsTable(attachedDatabase, alias);
  }
}

class ItemTag extends DataClass implements Insertable<ItemTag> {
  final String itemId;
  final String tagId;
  final int createdAt;
  const ItemTag(
      {required this.itemId, required this.tagId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['tag_id'] = Variable<String>(tagId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ItemTagsCompanion toCompanion(bool nullToAbsent) {
    return ItemTagsCompanion(
      itemId: Value(itemId),
      tagId: Value(tagId),
      createdAt: Value(createdAt),
    );
  }

  factory ItemTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemTag(
      itemId: serializer.fromJson<String>(json['itemId']),
      tagId: serializer.fromJson<String>(json['tagId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'tagId': serializer.toJson<String>(tagId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ItemTag copyWith({String? itemId, String? tagId, int? createdAt}) => ItemTag(
        itemId: itemId ?? this.itemId,
        tagId: tagId ?? this.tagId,
        createdAt: createdAt ?? this.createdAt,
      );
  ItemTag copyWithCompanion(ItemTagsCompanion data) {
    return ItemTag(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemTag(')
          ..write('itemId: $itemId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, tagId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemTag &&
          other.itemId == this.itemId &&
          other.tagId == this.tagId &&
          other.createdAt == this.createdAt);
}

class ItemTagsCompanion extends UpdateCompanion<ItemTag> {
  final Value<String> itemId;
  final Value<String> tagId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ItemTagsCompanion({
    this.itemId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemTagsCompanion.insert({
    required String itemId,
    required String tagId,
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : itemId = Value(itemId),
        tagId = Value(tagId),
        createdAt = Value(createdAt);
  static Insertable<ItemTag> custom({
    Expression<String>? itemId,
    Expression<String>? tagId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (tagId != null) 'tag_id': tagId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemTagsCompanion copyWith(
      {Value<String>? itemId,
      Value<String>? tagId,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return ItemTagsCompanion(
      itemId: itemId ?? this.itemId,
      tagId: tagId ?? this.tagId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemTagsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThumbnailsTable extends Thumbnails
    with TableInfo<$ThumbnailsTable, Thumbnail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThumbnailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteUrlMeta =
      const VerificationMeta('remoteUrl');
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
      'remote_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DownloadStatusEnum, String>
      downloadStatus = GeneratedColumn<String>(
              'download_status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('pending'))
          .withConverter<DownloadStatusEnum>(
              $ThumbnailsTable.$converterdownloadStatus);
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, itemId, remoteUrl, localPath, downloadStatus, sizeBytes, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'thumbnails';
  @override
  VerificationContext validateIntegrity(Insertable<Thumbnail> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('remote_url')) {
      context.handle(_remoteUrlMeta,
          remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta));
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Thumbnail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Thumbnail(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      remoteUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_url']),
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path']),
      downloadStatus: $ThumbnailsTable.$converterdownloadStatus.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}download_status'])!),
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ThumbnailsTable createAlias(String alias) {
    return $ThumbnailsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DownloadStatusEnum, String, String>
      $converterdownloadStatus =
      const EnumNameConverter<DownloadStatusEnum>(DownloadStatusEnum.values);
}

class Thumbnail extends DataClass implements Insertable<Thumbnail> {
  final String id;
  final String itemId;
  final String? remoteUrl;
  final String? localPath;
  final DownloadStatusEnum downloadStatus;
  final int? sizeBytes;
  final int createdAt;
  const Thumbnail(
      {required this.id,
      required this.itemId,
      this.remoteUrl,
      this.localPath,
      required this.downloadStatus,
      this.sizeBytes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    {
      map['download_status'] = Variable<String>(
          $ThumbnailsTable.$converterdownloadStatus.toSql(downloadStatus));
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ThumbnailsCompanion toCompanion(bool nullToAbsent) {
    return ThumbnailsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      remoteUrl: remoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUrl),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      downloadStatus: Value(downloadStatus),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      createdAt: Value(createdAt),
    );
  }

  factory Thumbnail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Thumbnail(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      downloadStatus: $ThumbnailsTable.$converterdownloadStatus
          .fromJson(serializer.fromJson<String>(json['downloadStatus'])),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'localPath': serializer.toJson<String?>(localPath),
      'downloadStatus': serializer.toJson<String>(
          $ThumbnailsTable.$converterdownloadStatus.toJson(downloadStatus)),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Thumbnail copyWith(
          {String? id,
          String? itemId,
          Value<String?> remoteUrl = const Value.absent(),
          Value<String?> localPath = const Value.absent(),
          DownloadStatusEnum? downloadStatus,
          Value<int?> sizeBytes = const Value.absent(),
          int? createdAt}) =>
      Thumbnail(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
        localPath: localPath.present ? localPath.value : this.localPath,
        downloadStatus: downloadStatus ?? this.downloadStatus,
        sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
        createdAt: createdAt ?? this.createdAt,
      );
  Thumbnail copyWithCompanion(ThumbnailsCompanion data) {
    return Thumbnail(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      downloadStatus: data.downloadStatus.present
          ? data.downloadStatus.value
          : this.downloadStatus,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Thumbnail(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('localPath: $localPath, ')
          ..write('downloadStatus: $downloadStatus, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, itemId, remoteUrl, localPath, downloadStatus, sizeBytes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Thumbnail &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.remoteUrl == this.remoteUrl &&
          other.localPath == this.localPath &&
          other.downloadStatus == this.downloadStatus &&
          other.sizeBytes == this.sizeBytes &&
          other.createdAt == this.createdAt);
}

class ThumbnailsCompanion extends UpdateCompanion<Thumbnail> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> remoteUrl;
  final Value<String?> localPath;
  final Value<DownloadStatusEnum> downloadStatus;
  final Value<int?> sizeBytes;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ThumbnailsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.localPath = const Value.absent(),
    this.downloadStatus = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThumbnailsCompanion.insert({
    required String id,
    required String itemId,
    this.remoteUrl = const Value.absent(),
    this.localPath = const Value.absent(),
    this.downloadStatus = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        createdAt = Value(createdAt);
  static Insertable<Thumbnail> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? remoteUrl,
    Expression<String>? localPath,
    Expression<String>? downloadStatus,
    Expression<int>? sizeBytes,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (localPath != null) 'local_path': localPath,
      if (downloadStatus != null) 'download_status': downloadStatus,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThumbnailsCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String?>? remoteUrl,
      Value<String?>? localPath,
      Value<DownloadStatusEnum>? downloadStatus,
      Value<int?>? sizeBytes,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return ThumbnailsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      localPath: localPath ?? this.localPath,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (downloadStatus.present) {
      map['download_status'] = Variable<String>($ThumbnailsTable
          .$converterdownloadStatus
          .toSql(downloadStatus.value));
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThumbnailsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('localPath: $localPath, ')
          ..write('downloadStatus: $downloadStatus, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SavedItemsTable savedItems = $SavedItemsTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $ItemCollectionsTable itemCollections =
      $ItemCollectionsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $ItemTagsTable itemTags = $ItemTagsTable(this);
  late final $ThumbnailsTable thumbnails = $ThumbnailsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [savedItems, collections, itemCollections, tags, itemTags, thumbnails];
}

typedef $$SavedItemsTableCreateCompanionBuilder = SavedItemsCompanion Function({
  required String id,
  required String originalUrl,
  required String canonicalUrl,
  required PlatformEnum platform,
  Value<ContentTypeEnum> contentType,
  Value<MetadataStatusEnum> metadataStatus,
  Value<String?> title,
  Value<String?> description,
  Value<String?> author,
  Value<String?> authorUrl,
  required int savedAt,
  Value<int?> lastAccessedAt,
  Value<bool> isFavorite,
  Value<bool> isArchived,
  Value<String?> note,
  Value<String?> whySaved,
  Value<LinkStatusEnum> linkStatus,
  Value<int?> lastCheckedAt,
  Value<int> rowid,
});
typedef $$SavedItemsTableUpdateCompanionBuilder = SavedItemsCompanion Function({
  Value<String> id,
  Value<String> originalUrl,
  Value<String> canonicalUrl,
  Value<PlatformEnum> platform,
  Value<ContentTypeEnum> contentType,
  Value<MetadataStatusEnum> metadataStatus,
  Value<String?> title,
  Value<String?> description,
  Value<String?> author,
  Value<String?> authorUrl,
  Value<int> savedAt,
  Value<int?> lastAccessedAt,
  Value<bool> isFavorite,
  Value<bool> isArchived,
  Value<String?> note,
  Value<String?> whySaved,
  Value<LinkStatusEnum> linkStatus,
  Value<int?> lastCheckedAt,
  Value<int> rowid,
});

class $$SavedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedItemsTable> {
  $$SavedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalUrl => $composableBuilder(
      column: $table.originalUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get canonicalUrl => $composableBuilder(
      column: $table.canonicalUrl, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PlatformEnum, PlatformEnum, String>
      get platform => $composableBuilder(
          column: $table.platform,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<ContentTypeEnum, ContentTypeEnum, String>
      get contentType => $composableBuilder(
          column: $table.contentType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<MetadataStatusEnum, MetadataStatusEnum, String>
      get metadataStatus => $composableBuilder(
          column: $table.metadataStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorUrl => $composableBuilder(
      column: $table.authorUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get savedAt => $composableBuilder(
      column: $table.savedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get whySaved => $composableBuilder(
      column: $table.whySaved, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<LinkStatusEnum, LinkStatusEnum, String>
      get linkStatus => $composableBuilder(
          column: $table.linkStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get lastCheckedAt => $composableBuilder(
      column: $table.lastCheckedAt, builder: (column) => ColumnFilters(column));
}

class $$SavedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedItemsTable> {
  $$SavedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalUrl => $composableBuilder(
      column: $table.originalUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get canonicalUrl => $composableBuilder(
      column: $table.canonicalUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentType => $composableBuilder(
      column: $table.contentType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataStatus => $composableBuilder(
      column: $table.metadataStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorUrl => $composableBuilder(
      column: $table.authorUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get savedAt => $composableBuilder(
      column: $table.savedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get whySaved => $composableBuilder(
      column: $table.whySaved, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkStatus => $composableBuilder(
      column: $table.linkStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastCheckedAt => $composableBuilder(
      column: $table.lastCheckedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SavedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedItemsTable> {
  $$SavedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalUrl => $composableBuilder(
      column: $table.originalUrl, builder: (column) => column);

  GeneratedColumn<String> get canonicalUrl => $composableBuilder(
      column: $table.canonicalUrl, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PlatformEnum, String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ContentTypeEnum, String> get contentType =>
      $composableBuilder(
          column: $table.contentType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MetadataStatusEnum, String>
      get metadataStatus => $composableBuilder(
          column: $table.metadataStatus, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get authorUrl =>
      $composableBuilder(column: $table.authorUrl, builder: (column) => column);

  GeneratedColumn<int> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<int> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get whySaved =>
      $composableBuilder(column: $table.whySaved, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LinkStatusEnum, String> get linkStatus =>
      $composableBuilder(
          column: $table.linkStatus, builder: (column) => column);

  GeneratedColumn<int> get lastCheckedAt => $composableBuilder(
      column: $table.lastCheckedAt, builder: (column) => column);
}

class $$SavedItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SavedItemsTable,
    SavedItem,
    $$SavedItemsTableFilterComposer,
    $$SavedItemsTableOrderingComposer,
    $$SavedItemsTableAnnotationComposer,
    $$SavedItemsTableCreateCompanionBuilder,
    $$SavedItemsTableUpdateCompanionBuilder,
    (SavedItem, BaseReferences<_$AppDatabase, $SavedItemsTable, SavedItem>),
    SavedItem,
    PrefetchHooks Function()> {
  $$SavedItemsTableTableManager(_$AppDatabase db, $SavedItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> originalUrl = const Value.absent(),
            Value<String> canonicalUrl = const Value.absent(),
            Value<PlatformEnum> platform = const Value.absent(),
            Value<ContentTypeEnum> contentType = const Value.absent(),
            Value<MetadataStatusEnum> metadataStatus = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> authorUrl = const Value.absent(),
            Value<int> savedAt = const Value.absent(),
            Value<int?> lastAccessedAt = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> whySaved = const Value.absent(),
            Value<LinkStatusEnum> linkStatus = const Value.absent(),
            Value<int?> lastCheckedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SavedItemsCompanion(
            id: id,
            originalUrl: originalUrl,
            canonicalUrl: canonicalUrl,
            platform: platform,
            contentType: contentType,
            metadataStatus: metadataStatus,
            title: title,
            description: description,
            author: author,
            authorUrl: authorUrl,
            savedAt: savedAt,
            lastAccessedAt: lastAccessedAt,
            isFavorite: isFavorite,
            isArchived: isArchived,
            note: note,
            whySaved: whySaved,
            linkStatus: linkStatus,
            lastCheckedAt: lastCheckedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String originalUrl,
            required String canonicalUrl,
            required PlatformEnum platform,
            Value<ContentTypeEnum> contentType = const Value.absent(),
            Value<MetadataStatusEnum> metadataStatus = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> authorUrl = const Value.absent(),
            required int savedAt,
            Value<int?> lastAccessedAt = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> whySaved = const Value.absent(),
            Value<LinkStatusEnum> linkStatus = const Value.absent(),
            Value<int?> lastCheckedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SavedItemsCompanion.insert(
            id: id,
            originalUrl: originalUrl,
            canonicalUrl: canonicalUrl,
            platform: platform,
            contentType: contentType,
            metadataStatus: metadataStatus,
            title: title,
            description: description,
            author: author,
            authorUrl: authorUrl,
            savedAt: savedAt,
            lastAccessedAt: lastAccessedAt,
            isFavorite: isFavorite,
            isArchived: isArchived,
            note: note,
            whySaved: whySaved,
            linkStatus: linkStatus,
            lastCheckedAt: lastCheckedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SavedItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SavedItemsTable,
    SavedItem,
    $$SavedItemsTableFilterComposer,
    $$SavedItemsTableOrderingComposer,
    $$SavedItemsTableAnnotationComposer,
    $$SavedItemsTableCreateCompanionBuilder,
    $$SavedItemsTableUpdateCompanionBuilder,
    (SavedItem, BaseReferences<_$AppDatabase, $SavedItemsTable, SavedItem>),
    SavedItem,
    PrefetchHooks Function()>;
typedef $$CollectionsTableCreateCompanionBuilder = CollectionsCompanion
    Function({
  required String id,
  required String name,
  Value<String?> icon,
  Value<String?> color,
  Value<String?> parentId,
  Value<bool> isSmart,
  required int createdAt,
  Value<int> rowid,
});
typedef $$CollectionsTableUpdateCompanionBuilder = CollectionsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> icon,
  Value<String?> color,
  Value<String?> parentId,
  Value<bool> isSmart,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSmart => $composableBuilder(
      column: $table.isSmart, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSmart => $composableBuilder(
      column: $table.isSmart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<bool> get isSmart =>
      $composableBuilder(column: $table.isSmart, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CollectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CollectionsTable,
    Collection,
    $$CollectionsTableFilterComposer,
    $$CollectionsTableOrderingComposer,
    $$CollectionsTableAnnotationComposer,
    $$CollectionsTableCreateCompanionBuilder,
    $$CollectionsTableUpdateCompanionBuilder,
    (Collection, BaseReferences<_$AppDatabase, $CollectionsTable, Collection>),
    Collection,
    PrefetchHooks Function()> {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<bool> isSmart = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CollectionsCompanion(
            id: id,
            name: name,
            icon: icon,
            color: color,
            parentId: parentId,
            isSmart: isSmart,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> icon = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<bool> isSmart = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CollectionsCompanion.insert(
            id: id,
            name: name,
            icon: icon,
            color: color,
            parentId: parentId,
            isSmart: isSmart,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CollectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CollectionsTable,
    Collection,
    $$CollectionsTableFilterComposer,
    $$CollectionsTableOrderingComposer,
    $$CollectionsTableAnnotationComposer,
    $$CollectionsTableCreateCompanionBuilder,
    $$CollectionsTableUpdateCompanionBuilder,
    (Collection, BaseReferences<_$AppDatabase, $CollectionsTable, Collection>),
    Collection,
    PrefetchHooks Function()>;
typedef $$ItemCollectionsTableCreateCompanionBuilder = ItemCollectionsCompanion
    Function({
  required String itemId,
  required String collectionId,
  required int createdAt,
  Value<int> rowid,
});
typedef $$ItemCollectionsTableUpdateCompanionBuilder = ItemCollectionsCompanion
    Function({
  Value<String> itemId,
  Value<String> collectionId,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$ItemCollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $ItemCollectionsTable> {
  $$ItemCollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectionId => $composableBuilder(
      column: $table.collectionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ItemCollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemCollectionsTable> {
  $$ItemCollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectionId => $composableBuilder(
      column: $table.collectionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ItemCollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemCollectionsTable> {
  $$ItemCollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
      column: $table.collectionId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ItemCollectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemCollectionsTable,
    ItemCollection,
    $$ItemCollectionsTableFilterComposer,
    $$ItemCollectionsTableOrderingComposer,
    $$ItemCollectionsTableAnnotationComposer,
    $$ItemCollectionsTableCreateCompanionBuilder,
    $$ItemCollectionsTableUpdateCompanionBuilder,
    (
      ItemCollection,
      BaseReferences<_$AppDatabase, $ItemCollectionsTable, ItemCollection>
    ),
    ItemCollection,
    PrefetchHooks Function()> {
  $$ItemCollectionsTableTableManager(
      _$AppDatabase db, $ItemCollectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemCollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemCollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemCollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<String> collectionId = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemCollectionsCompanion(
            itemId: itemId,
            collectionId: collectionId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemId,
            required String collectionId,
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemCollectionsCompanion.insert(
            itemId: itemId,
            collectionId: collectionId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemCollectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemCollectionsTable,
    ItemCollection,
    $$ItemCollectionsTableFilterComposer,
    $$ItemCollectionsTableOrderingComposer,
    $$ItemCollectionsTableAnnotationComposer,
    $$ItemCollectionsTableCreateCompanionBuilder,
    $$ItemCollectionsTableUpdateCompanionBuilder,
    (
      ItemCollection,
      BaseReferences<_$AppDatabase, $ItemCollectionsTable, ItemCollection>
    ),
    ItemCollection,
    PrefetchHooks Function()>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  required int createdAt,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
    Tag,
    PrefetchHooks Function()> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
    Tag,
    PrefetchHooks Function()>;
typedef $$ItemTagsTableCreateCompanionBuilder = ItemTagsCompanion Function({
  required String itemId,
  required String tagId,
  required int createdAt,
  Value<int> rowid,
});
typedef $$ItemTagsTableUpdateCompanionBuilder = ItemTagsCompanion Function({
  Value<String> itemId,
  Value<String> tagId,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$ItemTagsTableFilterComposer
    extends Composer<_$AppDatabase, $ItemTagsTable> {
  $$ItemTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ItemTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemTagsTable> {
  $$ItemTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ItemTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemTagsTable> {
  $$ItemTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ItemTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemTagsTable,
    ItemTag,
    $$ItemTagsTableFilterComposer,
    $$ItemTagsTableOrderingComposer,
    $$ItemTagsTableAnnotationComposer,
    $$ItemTagsTableCreateCompanionBuilder,
    $$ItemTagsTableUpdateCompanionBuilder,
    (ItemTag, BaseReferences<_$AppDatabase, $ItemTagsTable, ItemTag>),
    ItemTag,
    PrefetchHooks Function()> {
  $$ItemTagsTableTableManager(_$AppDatabase db, $ItemTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemTagsCompanion(
            itemId: itemId,
            tagId: tagId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemId,
            required String tagId,
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemTagsCompanion.insert(
            itemId: itemId,
            tagId: tagId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemTagsTable,
    ItemTag,
    $$ItemTagsTableFilterComposer,
    $$ItemTagsTableOrderingComposer,
    $$ItemTagsTableAnnotationComposer,
    $$ItemTagsTableCreateCompanionBuilder,
    $$ItemTagsTableUpdateCompanionBuilder,
    (ItemTag, BaseReferences<_$AppDatabase, $ItemTagsTable, ItemTag>),
    ItemTag,
    PrefetchHooks Function()>;
typedef $$ThumbnailsTableCreateCompanionBuilder = ThumbnailsCompanion Function({
  required String id,
  required String itemId,
  Value<String?> remoteUrl,
  Value<String?> localPath,
  Value<DownloadStatusEnum> downloadStatus,
  Value<int?> sizeBytes,
  required int createdAt,
  Value<int> rowid,
});
typedef $$ThumbnailsTableUpdateCompanionBuilder = ThumbnailsCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String?> remoteUrl,
  Value<String?> localPath,
  Value<DownloadStatusEnum> downloadStatus,
  Value<int?> sizeBytes,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$ThumbnailsTableFilterComposer
    extends Composer<_$AppDatabase, $ThumbnailsTable> {
  $$ThumbnailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteUrl => $composableBuilder(
      column: $table.remoteUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DownloadStatusEnum, DownloadStatusEnum, String>
      get downloadStatus => $composableBuilder(
          column: $table.downloadStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ThumbnailsTableOrderingComposer
    extends Composer<_$AppDatabase, $ThumbnailsTable> {
  $$ThumbnailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
      column: $table.remoteUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get downloadStatus => $composableBuilder(
      column: $table.downloadStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ThumbnailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThumbnailsTable> {
  $$ThumbnailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DownloadStatusEnum, String>
      get downloadStatus => $composableBuilder(
          column: $table.downloadStatus, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ThumbnailsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ThumbnailsTable,
    Thumbnail,
    $$ThumbnailsTableFilterComposer,
    $$ThumbnailsTableOrderingComposer,
    $$ThumbnailsTableAnnotationComposer,
    $$ThumbnailsTableCreateCompanionBuilder,
    $$ThumbnailsTableUpdateCompanionBuilder,
    (Thumbnail, BaseReferences<_$AppDatabase, $ThumbnailsTable, Thumbnail>),
    Thumbnail,
    PrefetchHooks Function()> {
  $$ThumbnailsTableTableManager(_$AppDatabase db, $ThumbnailsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThumbnailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThumbnailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThumbnailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String?> remoteUrl = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<DownloadStatusEnum> downloadStatus = const Value.absent(),
            Value<int?> sizeBytes = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ThumbnailsCompanion(
            id: id,
            itemId: itemId,
            remoteUrl: remoteUrl,
            localPath: localPath,
            downloadStatus: downloadStatus,
            sizeBytes: sizeBytes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            Value<String?> remoteUrl = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<DownloadStatusEnum> downloadStatus = const Value.absent(),
            Value<int?> sizeBytes = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ThumbnailsCompanion.insert(
            id: id,
            itemId: itemId,
            remoteUrl: remoteUrl,
            localPath: localPath,
            downloadStatus: downloadStatus,
            sizeBytes: sizeBytes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ThumbnailsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ThumbnailsTable,
    Thumbnail,
    $$ThumbnailsTableFilterComposer,
    $$ThumbnailsTableOrderingComposer,
    $$ThumbnailsTableAnnotationComposer,
    $$ThumbnailsTableCreateCompanionBuilder,
    $$ThumbnailsTableUpdateCompanionBuilder,
    (Thumbnail, BaseReferences<_$AppDatabase, $ThumbnailsTable, Thumbnail>),
    Thumbnail,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SavedItemsTableTableManager get savedItems =>
      $$SavedItemsTableTableManager(_db, _db.savedItems);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$ItemCollectionsTableTableManager get itemCollections =>
      $$ItemCollectionsTableTableManager(_db, _db.itemCollections);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$ItemTagsTableTableManager get itemTags =>
      $$ItemTagsTableTableManager(_db, _db.itemTags);
  $$ThumbnailsTableTableManager get thumbnails =>
      $$ThumbnailsTableTableManager(_db, _db.thumbnails);
}
