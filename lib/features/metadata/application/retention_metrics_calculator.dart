import 'package:reclip/core/database/database.dart';

class RetentionMetricsCalculator {
  final AppDatabase _db;

  RetentionMetricsCalculator(this._db);

  /// Retrieval Rate (7 days) = % of items saved >= 8 days ago
  /// that have at least 1 valid 'item_opened' event within 7 days after save.
  Future<double> retrievalRate7Days() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 8));
    final eligibleItems = await _db.findSavedBefore(cutoff);
    if (eligibleItems.isEmpty) return 0;

    int retrievedCount = 0;
    for (final item in eligibleItems) {
      final hasRetrieval = await _db.hasOpenEventWithinDays(
        itemId: item.id,
        afterSavedAt: item.savedAt,
        withinDays: 7,
      );
      if (hasRetrieval) retrievedCount++;
    }
    return retrievedCount / eligibleItems.length;
  }

  /// Week-1 Retention = % of days in the first 7 days after install
  /// that have at least 1 'app_opened' event.
  Future<double> week1Retention(DateTime installDate) async {
    final daysWithActivity = await _db.countDistinctDaysWithEvent(
      eventType: 'app_opened',
      from: installDate,
      to: installDate.add(const Duration(days: 7)),
    );
    return daysWithActivity / 7;
  }
}
