# Overview — Reclip

## Purpose
Reclip solves "save fast, find later" — user sees interesting content on social media → share to Reclip in 1 second → days later they can find it again.

**North Star Metric:** % of items reopened/found after 7 days (Retrieval Rate).

## Target Users
- Social media users (Reddit, Instagram, TikTok, YouTube, X)
- Want to save interesting content for later
- Don't want to fill forms every time they save
- Finding content again later is harder than saving it

## Tech Stack

| Component | Choice | Version |
|-----------|--------|---------|
| Framework | Flutter | 3.29.3 |
| Language | Dart | >=3.4.0 <4.0.0 |
| State Management | flutter_riverpod | ^2.5.1 |
| Local DB | drift (SQLite) + FTS5 | ^2.20.0 |
| HTTP Client | Dio | ^5.7.0 |
| Share Intent | receive_sharing_intent | ^1.8.0 |
| Image Cache | flutter_cache_manager | ^3.4.1 |
| Connectivity | connectivity_plus | ^6.0.5 |
| URL Launcher | url_launcher | ^6.3.0 |
| HTML Parser | html | ^0.15.4 |
| Ads | google_mobile_ads | ^5.3.0 |
| Preferences | shared_preferences | ^2.3.0 |
| Error Tracking | sentry_flutter | ^8.0.0 |
| Package Info | package_info_plus | ^8.0.0 |

## Platform Support

| Platform | Status | Min SDK |
|----------|--------|---------|
| Android | ✅ Supported | API 26 (Android 8.0) |
| iOS | ❌ Not in scope | - |
| Web | ❌ Not in scope | - |

## Version
- Current: `1.0.0+1`
- Package: `com.reclip.reclip`

## Phases

| Phase | Status | Scope |
|-------|--------|-------|
| Phase 0 — Technical Spike | ✅ Done | Share Intent, URL normalizer, Platform detector |
| Phase 1 — Core Habit (MVP) | ✅ Done | Quick Save, Library, Search, Open Original |
| Phase 2 — Enrichment | ✅ Done | Metadata adapters, thumbnails, faceted filter, offline UI |
| Phase 3 — Value Loop | ✅ Done | Notes, Collections, Tags, Settings, Discover, Ads, Backup |
| Phase 4 — Polish | 🔜 Pending | Deep links, Push notifications, iOS |

## App Screens

| Screen | Access | Purpose |
|--------|--------|---------|
| Library | Bottom nav (default) | All saved items, grid/list, filter, search |
| Discover | Bottom nav | Hacker News trending feed |
| Item Detail | Tap item in Library | Full details, edit, open original |
| Settings | Library ⋮ menu | General, Storage, Data, About |
| Backup & Restore | Settings → Data | Export/import JSON backup |
| Onboarding | First launch | Feature walkthrough |
