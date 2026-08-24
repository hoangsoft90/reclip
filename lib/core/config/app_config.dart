/// App-wide configuration flags.
///
/// Switch [testAds] to `false` before production release.
/// Test ads use Google's official test ad unit IDs — no real ads shown,
/// no revenue, no risk of AdMob policy violation during development.
class AppConfig {
  // === Feature Flags ===

  /// When true, AdMob shows test ads (Google's official test unit IDs).
  /// When false, real ads are shown (requires valid ad unit IDs from AdMob console).
  static const bool testAds = true;

  // === AdMob Ad Unit IDs ===

  // --- Android ---
  static const String _androidBannerTestId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _androidInterstitialTestId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _androidRewardedTestId = 'ca-app-pub-3940256099942544/5224354917';

  static const String _androidBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB'; // TODO: Replace
  static const String _androidInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/IIIIIIIIII'; // TODO: Replace
  static const String _androidRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/RRRRRRRRRR'; // TODO: Replace

  // --- iOS ---
  static const String _iosBannerTestId = 'ca-app-pub-3940256099942544/2934735716';
  static const String _iosInterstitialTestId = 'ca-app-pub-3940256099942544/4411468910';
  static const String _iosRewardedTestId = 'ca-app-pub-3940256099942544/1712485313';

  static const String _iosBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB'; // TODO: Replace
  static const String _iosInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/IIIIIIIIII'; // TODO: Replace
  static const String _iosRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/RRRRRRRRRR'; // TODO: Replace

  // === Public Getters ===

  static String get bannerAdUnitId {
    if (testAds) return _androidBannerTestId; // Platform resolved at runtime
    return _androidBannerId;
  }

  static String get bannerAdUnitIdIos {
    if (testAds) return _iosBannerTestId;
    return _iosBannerId;
  }

  static String get interstitialAdUnitId {
    if (testAds) return _androidInterstitialTestId;
    return _androidInterstitialId;
  }

  static String get interstitialAdUnitIdIos {
    if (testAds) return _iosInterstitialTestId;
    return _iosInterstitialId;
  }

  static String get rewardedAdUnitId {
    if (testAds) return _androidRewardedTestId;
    return _androidRewardedId;
  }

  static String get rewardedAdUnitIdIos {
    if (testAds) return _iosRewardedTestId;
    return _iosRewardedId;
  }

  // === AdMob App IDs (required for initialization) ===

  static const String androidAppId = 'ca-app-pub-3940256099942544~3347511713'; // Test
  static const String iosAppId = 'ca-app-pub-3940256099942544~1458002511'; // Test
}
