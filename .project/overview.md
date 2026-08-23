# Tổng quan ứng dụng

## Mục tiêu
Reclip giải quyết vấn đề "lưu nhanh, tìm lại dễ" — user thấy nội dung hay trên mạng xã hội → share vào Reclip trong 1 giây → vài ngày sau quay lại và tìm được nó.

**North Star Metric:** % item được mở lại/tìm thấy sau 7 ngày (Retrieval Rate).

## Đối tượng người dùng
- Người dùng mạng xã hội (Reddit, Instagram, TikTok, YouTube, X)
- Muốn lưu nội dung hay để xem lại sau
- Không muốn dừng lại điền form mỗi lần save
- Finding content again later is harder than saving it

## Tech Stack

| Thành phần | Lựa chọn | Version |
|------------|----------|---------|
| Framework | Flutter | 3.24.0 |
| Language | Dart | >=3.4.0 <4.0.0 |
| State Management | flutter_riverpod | ^2.5.1 |
| Local DB | drift (SQLite) + FTS5 | ^2.20.0 |
| HTTP Client | Dio | ^5.7.0 |
| Share Intent | receive_sharing_intent | ^1.8.0 |
| Image Cache | flutter_cache_manager | ^3.4.1 |
| Connectivity | connectivity_plus | ^6.0.5 |
| URL Launcher | url_launcher | ^6.3.0 |
| HTML Parser | html | ^0.15.4 |
| Testing | flutter_test + mocktail | - |

## Platform Support

| Platform | Status | Min SDK |
|----------|--------|---------|
| Android | ✅ Supported | API 26 (Android 8.0) |
| iOS | ❌ Not in scope | - |
| Web | ❌ Not in scope | - |

## Version
- Current: `1.0.0+1`
- Package name: `com.reclip.reclip`

## Phases

| Phase | Status | Scope |
|-------|--------|-------|
| Phase 0 — Technical Spike | ✅ Done | Share Intent, URL normalizer, Platform detector |
| Phase 1 — Core Habit (MVP) | ✅ Done | Quick Save, Library, Search, Open Original |
| Phase 2 — Enrichment | ✅ Done | Metadata adapters, thumbnails, faceted filter, offline UI |
| Phase 3 — Value Loop | ⏳ Pending | Notes, Rediscovery, Local Backup/Restore |
| Phase 4+ | 🔜 Backlog | Screenshot-to-Clip, Smart Collections, Cloud Sync |
