import 'package:reclip/core/database/database.dart';
import 'package:reclip/features/rediscovery/domain/rediscovery_score.dart';

class RediscoveryService {
  final AppDatabase _db;

  static const int _dailyCount = 5;
  static const int _excludeRecentlyShownDays = 3;

  RediscoveryService(this._db);

  /// Get today's resurface items — up to 5 items worth rediscovering.
  /// Excludes items shown in the last 3 days and items saved < 24h ago.
  Future<List<SavedItem>> getTodaysResurfaceItems() async {
    final now = DateTime.now();
    final candidates = await _db.findActiveItems();
    final recentlyShownIds = await _db.findResurfaceShownItemIds(
      since: now.subtract(const Duration(days: _excludeRecentlyShownDays)),
    );

    final scored = candidates
        .where((item) => !recentlyShownIds.contains(item.id))
        .map((item) => (
              item: item,
              score: RediscoveryScore.calculate(
                savedAt: DateTime.fromMillisecondsSinceEpoch(item.savedAt),
                lastAccessedAt: item.lastAccessedAt != null
                    ? DateTime.fromMillisecondsSinceEpoch(item.lastAccessedAt!)
                    : null,
                isFavorite: item.isFavorite,
                whySaved: item.whySaved,
                now: now,
              ),
            ))
        .where((entry) => entry.score >= 0)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    // Take top 15 pool, shuffle for variety, pick top 5
    final topPool = scored.take(15).map((e) => e.item).toList()..shuffle();
    final selected = topPool.take(_dailyCount).toList();

    // Record that these items were shown
    for (final item in selected) {
      await _db.recordResurfaceShown(item.id);
    }
    return selected;
  }

  /// Check if there are enough candidates to show resurface section.
  /// Need at least 5 eligible items (saved > 24h, not shown in last 3 days).
  Future<bool> hasEnoughCandidates() async {
    final now = DateTime.now();
    final candidates = await _db.findActiveItems();
    final recentlyShownIds = await _db.findResurfaceShownItemIds(
      since: now.subtract(const Duration(days: _excludeRecentlyShownDays)),
    );

    int eligibleCount = 0;
    for (final item in candidates) {
      if (recentlyShownIds.contains(item.id)) continue;
      final score = RediscoveryScore.calculate(
        savedAt: DateTime.fromMillisecondsSinceEpoch(item.savedAt),
        lastAccessedAt: item.lastAccessedAt != null
            ? DateTime.fromMillisecondsSinceEpoch(item.lastAccessedAt!)
            : null,
        isFavorite: item.isFavorite,
        whySaved: item.whySaved,
        now: now,
      );
      if (score >= 0) eligibleCount++;
      if (eligibleCount >= _dailyCount) return true;
    }
    return false;
  }
}
