# discover

## Purpose
Discover tab showing trending content from Hacker News. Allows browsing and saving trending stories to Library.

## Requirements

### REQ-1: Trending Service
Fetches top stories from Hacker News Firebase API.

**Scenario: Fetch trending**
- Given: Discover screen opens
- When: `TrendingService.fetchTopStories()` called
- Then: GET `hacker-news.firebaseio.com/v0/topstories.json` → take first 20 IDs → fetch each story in parallel
- Reference: `discover/application/trending_service.dart` — `fetchTopStories()` + `fetchStory()`

**Scenario: API error**
- Given: Network unavailable or API error
- When: Fetch attempted
- Then: Return empty list, show error state in UI
- Reference: `TrendingService` — try/catch returns empty list

### REQ-2: Discover Screen Layout
Full-screen list with pull-to-refresh.

**Scenario: Render**
- Given: Discover tab selected
- When: Render
- Then: Scaffold with AppBar "Discover" + refresh button, body = ListView of story cards
- Reference: `discover/presentation/discover_screen.dart`

**Scenario: Pull to refresh**
- Given: Discover screen showing stories
- When: User pulls down
- Then: RefreshIndicator triggers `TrendingService.fetchTopStories()` → rebuild list
- Reference: RefreshIndicator wrapper

**Scenario: Loading state**
- Given: Stories being fetched
- When: Render
- Then: Center CircularProgressIndicator
- Reference: Loading state in `_buildBody()`

**Scenario: Empty state**
- Given: No stories loaded
- When: Render
- Then: "No stories found" or "Failed to load" message
- Reference: Empty state in `_buildBody()`

### REQ-3: Story Card
Each story shows title, source domain, score, author, and action buttons.

**Scenario: Render story card**
- Given: Story with `title = "Show HN: New Tool"`, `score = 234`, `by = "pg"`, `url = "example.com/tool"`
- When: Render card
- Then: Container with [Hacker News] badge, title (bold), domain, score + author row, Open + Save buttons
- Reference: `_buildStoryCard()` method

### REQ-4: Open in Browser
"Open" button opens story URL in external browser.

**Scenario: Tap Open**
- Given: Story card with URL
- When: Tap "Open" button
- Then: `url_launcher` opens URL in external browser
- Reference: `_openStory()` method

### REQ-5: Save to Library
"Save to Library" button saves story as a new SavedItem.

**Scenario: Save new story**
- Given: Story not yet saved
- When: Tap "Save to Library"
- Then: Insert into `savedItems` table with `platform = other`, `contentType = link`, metadata from HN → show toast "Saved to Library ✓"
- Reference: `_saveToLibrary()` method

**Scenario: Duplicate check**
- Given: Story already saved (same URL)
- When: Tap "Save to Library"
- Then: Show "Already saved" toast, don't duplicate
- Reference: Duplicate URL check in `_saveToLibrary()`

### REQ-6: Navigation
Discover tab is the second tab in bottom navigation.

**Scenario: Switch to Discover**
- Given: User on Library tab
- When: Tap "Discover" in NavigationBar
- Then: IndexedStack switches to DiscoverScreen
- Reference: `app.dart` — NavigationBar destinations

## Cần làm rõ
- Hacker News API is public, no auth required, no rate limit
- Reddit API returns 403 on device IPs — replaced with HN
- YouTube tab removed (requires API key)
- Stories saved as `PlatformEnum.other` (Web) with `contentType = link`
