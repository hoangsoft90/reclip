import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:reclip/core/config/app_config.dart';

/// Manages AdMob lifecycle: initialization, ad loading, and disposal.
///
/// Usage:
/// ```dart
/// final adManager = AdManager();
/// await adManager.initialize();
///
/// // In widget:
/// adManager.loadBannerAd(
///   onLoaded: (ad) => setState(() => _bannerAd = ad),
/// );
/// ```
class AdManager {
  bool _initialized = false;

  /// Whether AdMob SDK has been initialized.
  bool get isInitialized => _initialized;

  /// Initialize the Mobile Ads SDK. Call once at app startup.
  Future<void> initialize() async {
    if (_initialized) return;
    if (!AppConfig.enableAds) {
      debugPrint('[AdManager] Ads disabled by config');
      return;
    }

    final status = await MobileAds.instance.initialize();
    _initialized = true;

    debugPrint('[AdManager] Initialized: ${status.adapterStatuses}');
  }

  /// Get the correct banner ad unit ID for the current platform.
  String get bannerAdUnitId =>
      Platform.isIOS ? AppConfig.bannerAdUnitIdIos : AppConfig.bannerAdUnitId;

  /// Get the correct interstitial ad unit ID for the current platform.
  String get interstitialAdUnitId =>
      Platform.isIOS ? AppConfig.interstitialAdUnitIdIos : AppConfig.interstitialAdUnitId;

  /// Get the correct rewarded ad unit ID for the current platform.
  String get rewardedAdUnitId =>
      Platform.isIOS ? AppConfig.rewardedAdUnitIdIos : AppConfig.rewardedAdUnitId;

  /// Load a banner ad.
  ///
  /// Returns the [BannerAd] via [onLoaded] callback.
  /// Caller is responsible for disposing the ad.
  void loadBannerAd({
    required void Function(BannerAd ad) onLoaded,
    void Function(AdError error)? onFailed,
  }) {
    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('[AdManager] Banner loaded');
          onLoaded(ad);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[AdManager] Banner failed: ${error.message}');
          ad.dispose();
          onFailed?.call(error);
        },
      ),
    );

    ad.load();
  }

  InterstitialAd? _interstitialAd;

  /// Load an interstitial ad for showing later.
  void loadInterstitialAd({
    void Function()? onLoaded,
    void Function(AdError error)? onFailed,
  }) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdManager] Interstitial loaded');
          _interstitialAd = ad;
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdManager] Interstitial failed: ${error.message}');
          onFailed?.call(error);
        },
      ),
    );
  }

  /// Show the loaded interstitial ad.
  ///
  /// Returns true if shown, false if not loaded.
  bool showInterstitialAd({void Function()? onDismissed}) {
    final ad = _interstitialAd;
    if (ad == null) return false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdManager] Interstitial dismissed');
        ad.dispose();
        _interstitialAd = null;
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdManager] Interstitial show failed: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
      },
    );

    ad.show();
    return true;
  }

  RewardedAd? _rewardedAd;

  /// Load a rewarded ad.
  void loadRewardedAd({
    void Function()? onLoaded,
    void Function(AdError error)? onFailed,
  }) {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      adLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdManager] Rewarded loaded');
          _rewardedAd = ad;
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdManager] Rewarded failed: ${error.message}');
          onFailed?.call(error);
        },
      ),
    );
  }

  /// Show the loaded rewarded ad.
  ///
  /// [onRewarded] is called when the user earns the reward.
  void showRewardedAd({
    void Function()? onRewarded,
    void Function()? onDismissed,
  }) {
    final ad = _rewardedAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('[AdManager] User earned reward: ${reward.amount} ${reward.type}');
        onRewarded?.call();
      },
    );
  }

  /// Dispose all loaded ads.
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
  }
}
