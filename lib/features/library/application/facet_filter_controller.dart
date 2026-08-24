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

  const FacetFilterState({
    this.platforms = const {},
    this.contentTypes = const {},
    this.savedDateRange,
    this.hasNote,
    this.whySaved,
    this.isFavorite,
    this.isArchived,
  });

  bool get isEmpty =>
      platforms.isEmpty &&
      contentTypes.isEmpty &&
      savedDateRange == null &&
      hasNote == null &&
      whySaved == null &&
      isFavorite == null &&
      isArchived == null;

  FacetFilterState copyWith({
    Set<PlatformEnum>? platforms,
    Set<ContentTypeEnum>? contentTypes,
    DateTimeRange? savedDateRange,
    bool? hasNote,
    String? whySaved,
    bool? isFavorite,
    bool? isArchived,
  }) {
    return FacetFilterState(
      platforms: platforms ?? this.platforms,
      contentTypes: contentTypes ?? this.contentTypes,
      savedDateRange: savedDateRange ?? this.savedDateRange,
      hasNote: hasNote ?? this.hasNote,
      whySaved: whySaved ?? this.whySaved,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

class FacetFilterController extends ChangeNotifier {
  FacetFilterState _state = const FacetFilterState();
  FacetFilterState get state => _state;

  void togglePlatform(PlatformEnum platform) {
    final platforms = Set<PlatformEnum>.from(_state.platforms);
    if (platforms.contains(platform)) {
      platforms.remove(platform);
    } else {
      platforms.add(platform);
    }
    _state = _state.copyWith(platforms: platforms);
    notifyListeners();
  }

  void toggleContentType(ContentTypeEnum type) {
    final types = Set<ContentTypeEnum>.from(_state.contentTypes);
    if (types.contains(type)) {
      types.remove(type);
    } else {
      types.add(type);
    }
    _state = _state.copyWith(contentTypes: types);
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    _state = _state.copyWith(savedDateRange: range);
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
    _state = _state.copyWith(
      isFavorite: _state.isFavorite == true ? null : true,
    );
    notifyListeners();
  }

  void toggleArchived() {
    _state = _state.copyWith(
      isArchived: _state.isArchived == true ? null : true,
    );
    notifyListeners();
  }

  void clearAll() {
    _state = const FacetFilterState();
    notifyListeners();
  }

  /// Filter a list of saved items against the current filter state.
  List<SavedItem> applyFilter(List<SavedItem> items) {
    return items.where((item) {
      if (_state.platforms.isNotEmpty && !_state.platforms.contains(item.platform)) {
        return false;
      }
      if (_state.contentTypes.isNotEmpty && !_state.contentTypes.contains(item.contentType)) {
        return false;
      }
      if (_state.savedDateRange != null) {
        final savedDate = DateTime.fromMillisecondsSinceEpoch(item.savedAt);
        if (savedDate.isBefore(_state.savedDateRange!.start) ||
            savedDate.isAfter(_state.savedDateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      if (_state.hasNote == true && (item.note == null || item.note!.isEmpty)) {
        return false;
      }
      if (_state.hasNote == false && item.note != null && item.note!.isNotEmpty) {
        return false;
      }
      if (_state.whySaved != null && item.whySaved != _state.whySaved) {
        return false;
      }
      if (_state.isFavorite == true && !item.isFavorite) {
        return false;
      }
      if (_state.isArchived == true && !item.isArchived) {
        return false;
      }
      return true;
    }).toList();
  }
}
