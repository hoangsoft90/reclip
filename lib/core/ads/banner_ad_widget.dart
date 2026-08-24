import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:reclip/core/ads/ad_manager.dart';
import 'package:reclip/core/config/app_config.dart';

/// Displays a banner ad with proper SafeArea handling.
///
/// The ad is placed above the Android navigation bar (3-button nav)
/// by using [SafeArea] with [bottom: true]. This prevents the ad
/// from being obscured by system navigation buttons.
///
/// Usage:
/// ```dart
/// BannerAdWidget(
///   adManager: adManager,
///   adSize: AdSize.banner,
/// )
/// ```
class BannerAdWidget extends StatefulWidget {
  final AdManager adManager;
  final AdSize? adSize;

  const BannerAdWidget({
    super.key,
    required this.adManager,
    this.adSize,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (AppConfig.enableAds) {
      _loadAd();
    } else {
      _isLoading = false;
    }
  }

  void _loadAd() {
    widget.adManager.loadBannerAd(
      onLoaded: (ad) {
        if (mounted) {
          setState(() {
            _ad = ad;
            _isLoading = false;
          });
        }
      },
      onFailed: (_) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
    );
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_ad == null) {
      return const SizedBox.shrink();
    }

    // SafeArea ensures the ad is NOT hidden behind Android's
    // 3-button navigation bar or gesture indicators.
    return SafeArea(
      top: false,
      child: SizedBox(
        width: _ad!.size.width.toDouble(),
        height: _ad!.size.height.toDouble(),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
