/// Pure function for scoring which saved items should resurface.
///
/// This is NOT spaced repetition — it's bookmark rediscovery.
/// Score is relative (used for sorting), not absolute.
class RediscoveryScore {
  /// Returns a score where higher = more worth resurfacing.
  /// Negative score means item should be excluded from candidate pool.
  static double calculate({
    required DateTime savedAt,
    required DateTime? lastAccessedAt,
    required bool isFavorite,
    required String? whySaved,
    required DateTime now,
  }) {
    final daysSinceLastSeen = lastAccessedAt == null
        ? _daysBetween(savedAt, now)
        : _daysBetween(lastAccessedAt, now);

    // Item saved less than 24h ago: exclude from pool
    // (not "rediscovered", just confirmed save)
    if (_daysBetween(savedAt, now) < 1) return -1;

    // Base score: older = higher, but log-capped to prevent
    // very old items always dominating
    double score = _logCap(daysSinceLastSeen, cap: 30);

    if (isFavorite) score *= 1.5;

    score *= _whySavedMultiplier(whySaved);

    return score;
  }

  static double _logCap(int days, {required int cap}) {
    final capped = days.clamp(0, cap * 3);
    return (1 + capped).clamp(1, cap * 3).toDouble().clamp(0, cap.toDouble() * 1.5);
  }

  static double _whySavedMultiplier(String? whySaved) {
    switch (whySaved) {
      case 'learn_this':
        return 1.4;   // highest priority — user marked as "want to learn"
      case 'try_this':
        return 1.3;
      case 'read_later':
        return 1.2;
      case 'inspiration':
        return 1.0;
      case 'just_interesting':
        return 0.8;
      default: // null — user didn't set why_saved
        return 1.0;
    }
  }

  static int _daysBetween(DateTime a, DateTime b) => b.difference(a).inDays;
}
