# context.md — Project Context

## What is Reclip?
Reclip là app Android giúp user lưu nội dung mạng xã hội (Reddit, Instagram, TikTok, YouTube, X) bằng cách share từ app gốc. User share link → Reclip lưu trong <1 giây → vài ngày sau quay lại tìm được.

## Tech Stack
- **Framework:** Flutter 3.24 (Dart >=3.4.0)
- **State Management:** flutter_riverpod ^2.5.1
- **Local DB:** drift ^2.20.0 (SQLite) + FTS5 full-text search
- **HTTP:** Dio ^5.7.0
- **Share Intent:** receive_sharing_intent ^1.8.0
- **Image Cache:** flutter_cache_manager ^3.4.1
- **Connectivity:** connectivity_plus ^6.0.5
- **Platform:** Android API 26+ (iOS not in scope)

## Project Structure
```
lib/
├── main.dart + app.dart          # Entry + providers + navigation
├── core/                         # Shared: DB, URL, network, constants
└── features/                     # Feature modules (feature-first)
    ├── share_intent/             # Receive share + quick save
    ├── library/                  # Grid/List view + filter
    ├── search/                   # FTS5 search
    ├── item_detail/              # Detail + Open Original
    ├── smart_save/               # BottomSheet add details
    ├── metadata/                 # Enrichment (5 adapters + orchestrator)
    └── quick_save_toast/         # Toast overlay
```

## Current State (August 2026)
- **Phase 0-2: DONE** — Quick Save, Library, Search, Metadata Enrichment, Thumbnails, Faceted Filter
- **Phase 3: PENDING** — Notes, Rediscovery, Local Backup
- **35 source files, 25 tests, 20 OpenSpec specs**
- **GitHub Actions build: working** (23 iterations to fix Gradle/Kotlin issues)

## Key Decisions
1. **Local-first** — no backend, no Firebase, no auth
2. **Riverpod over BLoC** — simpler for MVP, easier testing
3. **Drift over Hive** — relational data + FTS5 search
4. **No video download** — always "Open Original" in browser
5. **Adapter pattern for metadata** — each platform gets its own adapter, fails gracefully
6. **Quick Save is mandatory <1s** — metadata enrichment is optional background work
7. **No OS-level background jobs** — enrichment runs on app start/resume only

## User Flow
```
User on Reddit → Share → Choose "Reclip" → Toast "Saved ✓" (1s)
    → Background: fetch title, thumbnail, author
    → Library: item appears with thumbnail + metadata
    → Search: find by title/URL/note
    → Open Original: opens in browser
```
