import 'package:flutter/material.dart';
import 'package:reclip/core/database/database.dart';

class FacetFilterState {
  final Set<PlatformEnum> platforms;
  final Set<ContentTypeEnum> contentTypes;
  final DateTimeRange? savedDateRange;
  final bool? hasNote;
  final String? whySaved;
  final bool? isFavorite;
  final bool? isArchived;
  final String searchQuery;
  final String? collectionId;
  final String? tagId;

  const FacetFilterState({
    this.platforms = const {},
    this.contentTypes = const {},
    this.savedDateRange,
    this.hasNote,
    this.whySaved,
    this.isFavorite,
    this.isArchived,
    this.searchQuery = '',
    this.collectionId,
    this.tagId,
  });

  bool get isEmpty =>
      platforms.isEmpty &&
      contentTypes.isEmpty &&
      savedDateRange == null &&
      hasNote == null &&
      whySaved == null &&
      isFavorite == null &&
      isArchived == null &&
      searchQuery.isEmpty &&
      collectionId == null &&
      tagId == null;

  int get activeCount {
    int count = 0;
    if (platforms.isNotEmpty) count++;
    if (contentTypes.isNotEmpty) count++;
    if (savedDateRange != null) count++;
    if (hasNote != null) count++;
    if (whySaved != null) count++;
    if (isFavorite != null) count++;
    if (isArchived != null) count++;
    if (searchQuery.isNotEmpty) count++;
    if (collectionId != null) count++;
    if (tagId != null) count++;
    return count;
  }

  FacetFilterState copyWith({
    Set<PlatformEnum>? platforms,
    Set<ContentTypeEnum>? contentTypes,
    DateTimeRange? savedDateRange,
    bool? hasNote,
    String? whySaved,
    bool? isFavorite,
    bool? isArchived,
    String? searchQuery,
    String? collectionId,
    String? tagId,
  }) {
    return FacetFilterState(
      platforms: platforms ?? this.platforms,
      contentTypes: contentTypes ?? this.contentTypes,
      savedDateRange: savedDateRange ?? this.savedDateRange,
      hasNote: hasNote ?? this.hasNote,
      whySaved: whySaved ?? this.whySaved,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      searchQuery: searchQuery ?? this.searchQuery,
      collectionId: collectionId ?? this.collectionId,
      tagId: tagId ?? this.tagId,
    );
  }
}

class FacetFilterController extends ChangeNotifier {
  final AppDatabase _db;
  FacetFilterState _state = const FacetFilterState();
  FacetFilterState get state => _state;

  // Cached item IDs for collection/tag filters
  Set<String> _collectionItemIds = {};
  Set<String> _tagItemIds = {};

  FacetFilterController(this._db);

  void setSearchQuery(String value) {
    _state = _state.copyWith(searchQuery: value);
    notifyListeners();
  }

  void setPlatform(PlatformEnum? platform) {
    _state = _state.copyWith(platforms: platform == null ? {} : {platform});
    notifyListeners();
  }

  void setContentType(ContentTypeEnum? type) {
    _state = _state.copyWith(contentTypes: type == null ? {} : {type});
    notifyListeners();
  }

  void setHasNote(bool? value) {
    _state = _state.copyWith(hasNote: value);
    notifyListeners();
  }

  void setWhySaved(String? value) {
    _state = _state.copyWith(whySaved: value);
    notifyListeners();
  }

  void toggleFavorite() {
    _state = _state.copyWith(isFavorite: _state.isFavorite == true ? null : true);
    notifyListeners();
  }

  void toggleArchived() {
    _state = _state.copyWith(isArchived: _state.isArchived == true ? null : true);
    notifyListeners();
  }

  Future<void> setCollection(String? collectionId) async {
    _state = _state.copyWith(collectionId: collectionId);
    if (collectionId != null) {
      await _loadCollectionItemIds(collectionId);
    }
    notifyListeners();
  }

  Future<void> setTag(String? tagId) async {
    _state = _state.copyWith(tagId: tagId);
    if (tagId != null) {
      await _loadTagItemIds(tagId);
    }
    notifyListeners();
  }

  void clearAll() {
    _state = const FacetFilterState();
    _collectionItemIds = {};
    _tagItemIds = {};
    notifyListeners();
  }

  Future<void> _loadCollectionItemIds(String collectionId) async {
    final query = _db.select(_db.itemCollections)
      ..where((t) => t.collectionId.equals(collectionId));
    final results = await query.get();
    _collectionItemIds = results.map((r) => r.itemId).toSet();
  }

  Future<void> _loadTagItemIds(String tagId) async {
    final query = _db.select(_db.itemTags)
      ..where((t) => t.tagId.equals(tagId));
    final results = await query.get();
    _tagItemIds = results.map((r) => r.itemId).toSet();
  }

  /// Filter items — synchronous, uses cached collection/tag IDs.
  List<SavedItem> applyFilter(List<SavedItem> items) {
    return items.where((item) {
      // Text search
      if (_state.searchQuery.isNotEmpty) {
        final query = _state.searchQuery.toLowerCase();
        final title = (item.title ?? '').toLowerCase();
        final desc = (item.description ?? '').toLowerCase();
        final note = (item.note ?? '').toLowerCase();
        final url = item.originalUrl.toLowerCase();
        if (!title.contains(query) &&
            !desc.contains(query) &&
            !note.contains(query) &&
            !url.contains(query)) {
          return false;
        }
      }

      if (_state.platforms.isNotEmpty && !_state.platforms.contains(item.platform)) return false;
      if (_state.contentTypes.isNotEmpty && !_state.contentTypes.contains(item.contentType)) return false;
      if (_state.savedDateRange != null) {
        final savedDate = DateTime.fromMillisecondsSinceEpoch(item.savedAt);
        if (savedDate.isBefore(_state.savedDateRange!.start) ||
            savedDate.isAfter(_state.savedDateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      if (_state.hasNote == true && (item.note == null || item.note!.isEmpty)) return false;
      if (_state.hasNote == false && item.note != null && item.note!.isNotEmpty) return false;
      if (_state.whySaved != null && item.whySaved != _state.whySaved) return false;
      if (_state.isFavorite == true && !item.isFavorite) return false;
      if (_state.isArchived == true && !item.isArchived) return false;
      if (_state.collectionId != null && !_collectionItemIds.contains(item.id)) return false;
      if (_state.tagId != null && !_tagItemIds.contains(item.id)) return false;

      return true;
    }).toList();
  }
}
