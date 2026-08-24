# faceted-filter

## Purpose
Filter items in Library by multiple combined criteria: text search, platform, content type, why-saved, collection, tag, favorites, archived. Runs entirely local on the item list from DB.

## Requirements

### REQ-1: Search Field
Text search bar at top filters by title, description, note, and URL.

**Scenario: Type search query**
- Given: Library with items containing various titles/notes
- When: User types "flutter" in search bar
- Then: Only items with "flutter" in title, description, note, or URL are shown
- Reference: `FacetFilterState.searchQuery` — `_matchesSearch()` checks all text fields case-insensitively

**Scenario: Clear search**
- Given: Search query is "flutter"
- When: Tap ✕ button in search field
- Then: `searchQuery` cleared, all items shown (subject to other filters)
- Reference: Search field clear button

### REQ-2: Filter Toggle Button
Compact toggle button shows/hides filter panel with active filter count badge.

**Scenario: No active filters**
- Given: No filters applied
- When: Render filter bar
- Then: 🔢 toggle button with no badge
- Reference: `FacetFilterBar` — filter toggle button

**Scenario: Has active filters**
- Given: Platform = Reddit, Favorites = true
- When: Render filter bar
- Then: 🔢 button with badge showing "2"
- Reference: `FacetFilterState.activeCount` computed property

**Scenario: Tap toggle**
- Given: Filter panel collapsed
- When: Tap 🔢 button
- Then: Filter panel expands showing all dropdowns and toggles
- Reference: `_isExpanded` state in `FacetFilterBar`

### REQ-3: Platform Dropdown
Dropdown select for platform filtering (all platforms including Web/Other).

**Scenario: Select platform**
- Given: Filter expanded
- When: Select "Reddit" from Platform dropdown
- Then: `setPlatform(PlatformEnum.reddit)` → only Reddit items shown
- Reference: `setPlatform()` in `FacetFilterController`

**Scenario: Clear platform**
- Given: Platform filter active
- When: Select "All" from Platform dropdown
- Then: `setPlatform(null)` → all platforms shown
- Reference: `setPlatform(null)`

### REQ-4: Content Type Dropdown
Dropdown select for content type (video, image, text, link, mixed, unknown).

**Scenario: Select type**
- Given: Filter expanded
- When: Select "video" from Type dropdown
- Then: `setContentType(ContentTypeEnum.video)` → only video items shown
- Reference: `setContentType()` in `FacetFilterController`

### REQ-5: Why Saved Dropdown
Dropdown select for why-saved reason.

**Scenario: Select reason**
- Given: Filter expanded
- When: Select "Read later" from Why saved dropdown
- Then: `setWhySaved('read_later')` → only items with that reason shown
- Reference: `setWhySaved()` in `FacetFilterController`

### REQ-6: Collection Dropdown
Dropdown populated from DB, filters items by collection membership.

**Scenario: Select collection**
- Given: Filter expanded, user has collections ["Recipes", "Travel"]
- When: Select "Recipes" from Collection dropdown
- Then: `setCollection(collectionId)` → only items in that collection shown
- Reference: `setCollection()` — loads item IDs from `item_collections` table

**Scenario: Dynamic refresh**
- Given: User creates a new collection while filter is open
- When: Filter panel rebuilds (`didUpdateWidget`)
- Then: Collection dropdown refreshes to include new collection
- Reference: `_loadCollectionsAndTags()` called in `didUpdateWidget`

### REQ-7: Tag Dropdown
Dropdown populated from DB, filters items by tag membership.

**Scenario: Select tag**
- Given: Filter expanded, user has tags ["tutorial", "flutter"]
- When: Select "tutorial" from Tag dropdown
- Then: `setTag(tagId)` → only items with that tag shown
- Reference: `setTag()` — loads item IDs from `item_tags` table

### REQ-8: Toggle Buttons (Favorites, Archived, Has Note)
Compact toggle buttons for boolean filters.

**Scenario: Toggle Favorites**
- Given: Filter expanded
- When: Tap ⭐ Favorites button
- Then: `toggleFavorite()` → only favorite items shown
- Reference: `toggleFavorite()` in `FacetFilterController`

**Scenario: Toggle Archived**
- Given: Filter expanded
- When: Tap 📦 Archived button
- Then: `toggleArchived()` → only archived items shown
- Reference: `toggleArchived()` in `FacetFilterController`

**Scenario: Toggle Has Note**
- Given: Filter expanded
- When: Tap 📝 Has note button
- Then: `hasNote = true` → only items with notes shown
- Reference: `hasNote` toggle in `FacetFilterController`

### REQ-9: Active Filter Chips
When panel is collapsed and filters are active, show compact chips.

**Scenario: Show active chips**
- Given: Platform = Reddit, Favorites = true
- When: Filter panel collapsed
- Then: Shows chips [📱 Reddit] [⭐ Fav] [✕ Clear all]
- Reference: Active chips row in `FacetFilterBar`

**Scenario: Clear individual chip**
- Given: Active chip "Reddit" visible
- When: Tap ✕ on chip
- Then: That filter cleared, other filters remain
- Reference: Chip delete callback

### REQ-10: Clear All Filters
"Clear all" button removes all active filters at once.

**Scenario: Clear all**
- Given: Multiple filters active
- When: Tap "Clear all" button or chip
- Then: All filters reset to null/false, all items shown
- Reference: `clearAll()` in `FacetFilterController`

### REQ-11: AND/OR Filter Logic
Multiple filter groups use AND logic between groups, OR within same group.

**Scenario: Platform + Favorites**
- Given: Platform = Reddit, Favorites = true
- When: Filter applied
- Then: Only items that are Reddit AND Favorites
- Reference: Filter logic — each group is AND'd together

**Scenario: Multiple platforms**
- Given: Platform = Reddit OR YouTube
- When: Filter applied
- Then: Items from either platform (OR within platform group)
- Reference: `_state.platforms.contains(item.platform)` — set contains = OR

### REQ-12: No Match State
When filter returns 0 results, show "No items match filter".

**Scenario: Empty result**
- Given: Library has items but none match filter
- When: Filter applied
- Then: "No items match filter" text shown
- Reference: Library screen empty filter state

### REQ-13: Filter Bar Layout
Compact design: search field + toggle button on one row, expandable panel below.

**Scenario: Collapsed view**
- Given: Library screen
- When: Render
- Then: Row with search TextField + 🔢 toggle button
- Reference: `FacetFilterBar` — collapsed layout

**Scenario: Expanded view**
- Given: Filter panel expanded
- When: Render
- Then: Search field + Platform/Type/Why saved/Collection/Tag dropdowns + Favorites/Archived/Has note toggles + Clear button
- Reference: `FacetFilterBar` — expanded layout

## Cần làm rõ
- Filter runs client-side on items from `StreamBuilder` — all items loaded into memory before filtering
- Collection/tag item IDs are cached in controller when filter is selected (to keep `applyFilter()` sync for StreamBuilder)
- `didUpdateWidget()` refreshes collection/tag lists from DB when parent rebuilds
