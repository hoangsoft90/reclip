# Module: Discover

## Purpose
Discover tab showing trending content from Hacker News. Browse and save trending stories.

## Files
| File | Purpose |
|------|---------|
| `lib/features/discover/application/trending_service.dart` | Fetch HN top stories via Firebase API |
| `lib/features/discover/presentation/discover_screen.dart` | UI with story cards, pull-to-refresh |

## Key Behaviors
- **API:** `hacker-news.firebaseio.com/v0/topstories.json` — no auth, no rate limit
- **Fetch:** Top 20 stories, parallel fetch for each story detail
- **Save:** Saves as `PlatformEnum.other` (Web) + `contentType = link`
- **Duplicate check:** Same URL → "Already saved" toast
- **Open:** Opens story URL in external browser via url_launcher

## Access
Bottom navigation → Discover tab

## Notes
- Reddit API returns 403 on device IPs → replaced with Hacker News
- YouTube tab removed (requires API key)
- Single list view (no platform tabs)
