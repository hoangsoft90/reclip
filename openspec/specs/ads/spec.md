# ads

## Purpose
AdMob integration for monetization: banner ads on Library screen, interstitial ads every 5 saves from share intent.

## Requirements

### REQ-1: Ad Configuration
AppConfig controls ad master switch, test/production mode, and ad unit IDs.

**Scenario: Ads enabled**
- Given: `AppConfig.enableAds = true`
- When: App starts
- Then: AdManager initializes, banner ads load
- Reference: `core/config/app_config.dart` — `enableAds`, `testAds` flags

**Scenario: Ads disabled**
- Given: `AppConfig.enableAds = false`
- When: App starts
- Then: AdManager skips initialization, no ads shown
- Reference: `core/ads/ad_manager.dart` — early return when disabled

**Scenario: Test vs Production**
- Given: `AppConfig.testAds = true`
- When: Ad requested
- Then: Uses Google's test ad unit IDs (`ca-app-pub-3940256099942544/...`)
- Given: `AppConfig.testAds = false`
- When: Ad requested
- Then: Uses production ad unit IDs (`ca-app-pub-6917313063209470/...`)
- Reference: `AppConfig.bannerAdUnitId`, `interstitialAdUnitId` getters

### REQ-2: AdManager Initialization
Singleton AdManager handles lifecycle of all ad types.

**Scenario: Initialize**
- Given: `enableAds = true`
- When: `adManager.initialize()` called from `main.dart`
- Then: `MobileAds.instance.initialize()` → log adapter status
- Reference: `core/ads/ad_manager.dart` — `initialize()` method

### REQ-3: Banner Ad
Persistent banner ad at bottom of Library screen.

**Scenario: Show banner**
- Given: Library screen, ads enabled
- When: Render
- Then: `BannerAdWidget` renders `AdWidget` with banner ad at bottom of screen
- Reference: `core/ads/banner_ad_widget.dart` — `BannerAdWidget` stateful

**Scenario: Banner load failed**
- Given: Banner ad fails to load
- When: Ad load callback fires
- Then: Widget returns empty `SizedBox()` — no crash, no visual glitch
- Reference: `BannerAdWidget` — `_isLoaded` check

**Scenario: Banner size**
- Given: Banner loaded
- When: Render
- Then: `AdSize.banner` (320x50) displayed in Container with `alignment: Alignment.bottomCenter`
- Reference: `BannerAdWidget` — `AdSize.banner`

### REQ-4: Interstitial Ad
Full-screen interstitial shown every N saves from share intent.

**Scenario: Count saves**
- Given: User saves via share intent
- When: `_onShareSaved()` called with `isNew = true`
- Then: `_incrementAndMaybeShowInterstitial()` → increment `ad_save_counter` in SharedPreferences
- Reference: `app.dart` — `_incrementAndMaybeShowInterstitial()`

**Scenario: Show interstitial at threshold**
- Given: `_saveCount >= 5` (interstitial interval)
- When: Save count reaches threshold
- Then: Reset counter to 0, load interstitial → `onLoaded` → `showInterstitialAd()` → full-screen ad
- Reference: `app.dart` — `_showInterstitialAd()` + `adManager.loadInterstitialAd()`

**Scenario: Counter persistence**
- Given: App killed and restarted
- When: App loads
- Then: `_loadSaveCount()` reads counter from SharedPreferences → continues from where left off
- Reference: `app.dart` — `_loadSaveCount()`

**Scenario: Interstitial dismissed**
- Given: Interstitial ad shown
- When: User closes ad
- Then: `onDismissed` callback fires, no action needed
- Reference: `AdManager.showInterstitialAd()` — dismiss callback

### REQ-5: Ad Unit IDs
Production ad unit IDs for Android.

**Scenario: Banner**
- When: `testAds = false`
- Then: `ca-app-pub-6917313063209470/8121632162`
- Reference: `AppConfig._androidBannerId`

**Scenario: Interstitial**
- When: `testAds = false`
- Then: `ca-app-pub-6917313063209470/3499860875`
- Reference: `AppConfig._androidInterstitialId`

**Scenario: Rewarded**
- When: `testAds = false`
- Then: `ca-app-pub-6917313063209470/9873697532`
- Reference: `AppConfig._androidRewardedId`

### REQ-6: Ad Visibility in Settings
Developer section shows DB stats when `testAds = true`.

**Scenario: testAds enabled**
- Given: `AppConfig.testAds = true`
- When: Settings screen renders
- Then: "🛠️ Developer" section visible with "DB stats" button
- Reference: Settings screen — conditional Developer section

## Cần làm rõ
- Interstitial only fires on NEW saves from share intent (not on re-saves or manual edits)
- Banner ad uses `AdSize.banner` (320x50) — standard mobile banner
- Rewarded ad IDs configured but not yet used in any flow
- `AdManager` is a Riverpod provider (`adManagerProvider`) — singleton per app lifecycle
- Android `android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"` handles ad rotation
