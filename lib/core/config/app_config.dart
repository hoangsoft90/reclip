/// App-wide configuration flags.
///
/// [enableAds] — master switch for all ad functionality.
/// [testAds] — when true, uses Google's official test ad unit IDs.
///
/// Typical setup:
/// - Development: enableAds=true, testAds=true (test ads, no revenue)
/// - Production: enableAds=true, testAds=false (real ads, real revenue)
/// - Disabled: enableAds=false (no ads at all)
class AppConfig {
  // === Feature Flags ===

  /// Master switch for ads. When false, no ads are loaded or shown.
  static const bool enableAds = true;

  /// When true, AdMob shows test ads (Google's official test unit IDs).
  /// When false, real ads are shown.
  /// Only effective when [enableAds] is true.
  static const bool testAds = false;

  // === AdMob App IDs (required for initialization) ===

  static const String androidAppId = 'ca-app-pub-6917313063209470~3883004257';
  static const String iosAppId = 'ca-app-pub-6917313063209470~3883004257'; // Same for now

  // === Android Ad Unit IDs ===

  static const String _androidBannerTestId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _androidInterstitialTestId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _androidRewardedTestId = 'ca-app-pub-3940256099942544/5224354917';

  static const String _androidBannerId = 'ca-app-pub-6917313063209470/8121632162';
  static const String _androidInterstitialId = 'ca-app-pub-6917313063209470/3499860875';
  static const String _androidRewardedId = 'ca-app-pub-6917313063209470/9873697532';

  // === iOS Ad Unit IDs (same as Android for now — update when iOS ad units created) ===

  static const String _iosBannerTestId = 'ca-app-pub-3940256099942544/2934735716';
  static const String _iosInterstitialTestId = 'ca-app-pub-3940256099942544/4411468910';
  static const String _iosRewardedTestId = 'ca-app-pub-3940256099942544/1712485313';

  static const String _iosBannerId = 'ca-app-pub-6917313063209470/8121632162';
  static const String _iosInterstitialId = 'ca-app-pub-6917313063209470/3499860875';
  static const String _iosRewardedId = 'ca-app-pub-6917313063209470/9873697532';

  // === Public Getters ===

  static String get bannerAdUnitId {
    if (!enableAds) return '';
    if (testAds) return _androidBannerTestId;
    return _androidBannerId;
  }

  static String get bannerAdUnitIdIos {
    if (!enableAds) return '';
    if (testAds) return _iosBannerTestId;
    return _iosBannerId;
  }

  static String get interstitialAdUnitId {
    if (!enableAds) return '';
    if (testAds) return _androidInterstitialTestId;
    return _androidInterstitialId;
  }

  static String get interstitialAdUnitIdIos {
    if (!enableAds) return '';
    if (testAds) return _iosInterstitialTestId;
    return _iosInterstitialId;
  }

  static String get rewardedAdUnitId {
    if (!enableAds) return '';
    if (testAds) return _androidRewardedTestId;
    return _androidRewardedId;
  }

  static String get rewardedAdUnitIdIos {
    if (!enableAds) return '';
    if (testAds) return _iosRewardedTestId;
    return _iosRewardedId;
  }
}
