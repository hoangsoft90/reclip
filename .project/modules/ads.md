# Module: Ads (AdMob)

## Purpose
Monetization via AdMob: banner ads on Library, interstitial ads every 5 saves.

## Files
| File | Purpose |
|------|---------|
| `lib/core/ads/ad_manager.dart` | Singleton AdManager — init, load, show (banner + interstitial) |
| `lib/core/ads/banner_ad_widget.dart` | Banner ad widget for Library screen |
| `lib/core/config/app_config.dart` | enableAds, testAds flags + ad unit IDs |
| `lib/app.dart` | Save counter + interstitial trigger logic |

## Ad Unit IDs (Production)
| Type | ID |
|------|-----|
| Banner | `ca-app-pub-6917313063209470/8121632162` |
| Interstitial | `ca-app-pub-6917313063209470/3499860875` |
| Rewarded | `ca-app-pub-6917313063209470/9873697532` |

## Config Flags
```dart
static const bool enableAds = true;   // Master switch
static const bool testAds = false;    // false = real ads
```

## Interstitial Flow
```
Share save #1 → count=1 → no ad
Share save #2 → count=2 → no ad
...
Share save #5 → count=5 → load + show interstitial → reset count=0
Share save #6 → count=1 → no ad
```

## Key Behaviors
- Counter persisted in SharedPreferences (`ad_save_counter`)
- Only counts NEW saves from share intent (not re-saves)
- Banner: `AdSize.banner` (320x50) at bottom of Library
- Rewarded IDs configured but not yet used
