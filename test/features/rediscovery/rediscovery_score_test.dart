import 'package:flutter_test/flutter_test.dart';
import 'package:reclip/features/rediscovery/domain/rediscovery_score.dart';

void main() {
  group('RediscoveryScore.calculate', () {
    test('returns -1 for items saved less than 24h ago', () {
      final now = DateTime(2026, 8, 24, 12);
      final savedAt = now.subtract(const Duration(hours: 12)); // 12h ago

      final score = RediscoveryScore.calculate(
        savedAt: savedAt,
        lastAccessedAt: null,
        isFavorite: false,
        whySaved: null,
        now: now,
      );

      expect(score, -1);
    });

    test('returns positive score for items saved > 24h ago', () {
      final now = DateTime(2026, 8, 24, 12);
      final savedAt = now.subtract(const Duration(days: 3));

      final score = RediscoveryScore.calculate(
        savedAt: savedAt,
        lastAccessedAt: null,
        isFavorite: false,
        whySaved: null,
        now: now,
      );

      expect(score, greaterThan(0));
    });

    test('favorite items get 1.5x multiplier', () {
      final now = DateTime(2026, 8, 24, 12);
      final savedAt = now.subtract(const Duration(days: 5));

      final normalScore = RediscoveryScore.calculate(
        savedAt: savedAt,
        lastAccessedAt: null,
        isFavorite: false,
        whySaved: null,
        now: now,
      );

      final favoriteScore = RediscoveryScore.calculate(
        savedAt: savedAt,
        lastAccessedAt: null,
        isFavorite: true,
        whySaved: null,
        now: now,
      );

      expect(favoriteScore, closeTo(normalScore * 1.5, 0.01));
    });

    test('learn_this why_saved gets highest multiplier (1.4)', () {
      final now = DateTime(2026, 8, 24, 12);
      final savedAt = now.subtract(const Duration(days: 10));

      final baseScore = RediscoveryScore.calculate(
        savedAt: savedAt,
        lastAccessedAt: null,
        isFavorite: false,
        whySaved: null,
        now: now,
      );

      final learnScore = RediscoveryScore.calculate(
        savedAt: savedAt,
        lastAccessedAt: null,
        isFavorite: false,
        whySaved: 'learn_this',
        now: now,
      );

      expect(learnScore, closeTo(baseScore * 1.4, 0.01));
    });

    test('try_this why_saved gets 1.3x multiplier', () {
      final now = DateTime(2026, 8, 24, 12);
      final savedAt = now.subtract(const Duration(days: 10));

      final baseScore = RediscoveryScore.calculate(
        savedAt: savedAt,
        lastAccessedAt: null,
        isFavorite: false,
        whySaved: null,
        now: now,
      );

      final tryScore = RediscoveryScore.calculate(
        savedAt: savedAt,
        lastAccessedAt: null,
        isFavorite: false,
        whySaved: 'try_this',
        now: now,
      );

      expect(tryScore, closeTo(baseScore * 1.3, 0.01));
    });

    test('read_later why_saved gets 1.2x multiplier', () {
      final now = DateTime(2026, 8, 24, 12);
      final savedAt = now.subtract(const Duration(days: 10));

      final baseScore = RediscoveryScore.calculate(
        savedAt: savedAt,
        lastAccessedAt: null,
        isFavorite: false,
        whySaved: null,
        now: now,
      );

      final readScore = RediscoveryScore.calculate(
        savedAt: savedAt,
        lastAccessedAt: null,
        isFavorite: false,
        whySaved: 'read_later',
        now: now,
      );

      expect(readScore, closeTo(baseScore * 1.2, 0.01));
    });

    test('just_interesting why_saved gets 0.8x multiplier', () {
      final now = DateTime(2026, 8, 24, 12);
      final savedAt = now.subtract(const Duration(days: 10));

      final baseScore = RediscoveryScore.calculate(
        savedAt: savedAt,
        lastAccessedAt: null,
        isFavorite: false,
        whySaved: null,
        now: now,
      );

      final interestingScore = RediscoveryScore.calculate(
        savedAt: savedAt,
        lastAccessedAt: null,
        isFavorite: false,
        whySaved: 'just_interesting',
        now: now,
      );

      expect(interestingScore, closeTo(baseScore * 0.8, 0.01));
    });

    test('uses lastAccessedAt instead of savedAt when available', () {
      final now = DateTime(2026, 8, 24, 12);
      final savedAt = now.subtract(const Duration(days: 30));
      final lastAccessedAt = now.subtract(const Duration(days: 2));

      final scoreWithoutAccess = RediscoveryScore.calculate(
        savedAt: savedAt,
        lastAccessedAt: null,
        isFavorite: false,
        whySaved: null,
        now: now,
      );

      final scoreWithAccess = RediscoveryScore.calculate(
        savedAt: savedAt,
        lastAccessedAt: lastAccessedAt,
        isFavorite: false,
        whySaved: null,
        now: now,
      );

      // Score with recent access should be LOWER (less urgent to resurface)
      expect(scoreWithAccess, lessThan(scoreWithoutAccess));
    });

    test('score increases with days since last seen (log-capped)', () {
      final now = DateTime(2026, 8, 24, 12);

      final score3days = RediscoveryScore.calculate(
        savedAt: now.subtract(const Duration(days: 3)),
        lastAccessedAt: null,
        isFavorite: false,
        whySaved: null,
        now: now,
      );

      final score10days = RediscoveryScore.calculate(
        savedAt: now.subtract(const Duration(days: 10)),
        lastAccessedAt: null,
        isFavorite: false,
        whySaved: null,
        now: now,
      );

      final score30days = RediscoveryScore.calculate(
        savedAt: now.subtract(const Duration(days: 30)),
        lastAccessedAt: null,
        isFavorite: false,
        whySaved: null,
        now: now,
      );

      expect(score10days, greaterThan(score3days));
      expect(score30days, greaterThan(score10days));
    });
  });
}
