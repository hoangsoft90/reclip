# OpenSpec — Tiến độ, Bug, Todo

## Trạng thái hiện tại

### ✅ Đã hoàn thành
| Capability | Spec | Code | Tests |
|-----------|------|------|-------|
| url-normalization | ✅ | ✅ | ✅ 8 tests |
| platform-detection | ✅ | ✅ | ✅ 13 tests |
| local-database | ✅ | ✅ | ✅ (thru quick-save) |
| share-intent | ✅ | ✅ | - |
| quick-save | ✅ | ✅ | ✅ 2 tests |
| library | ✅ | ✅ | - |
| faceted-filter | ✅ | ✅ | - |
| offline-banner | ✅ | ✅ | - |
| search | ✅ | ✅ | - |
| item-detail | ✅ | ✅ | - |
| open-original | ✅ | ✅ | - |
| smart-save | ✅ | ✅ (fixed) | - |
| quick-save-toast | ✅ | ✅ | - |
| metadata-adapters | ✅ | ✅ | - |
| enrichment-orchestrator | ✅ | ✅ | - |
| thumbnail-download | ✅ | ✅ | - |
| metrics-logger | ✅ | ✅ | - |
| app-shell | ✅ | ✅ | - |
| ui-constants | ✅ | ✅ | - |
| http-client | ✅ | ✅ | - |

### ⏳ Đang làm / Chưa làm (Phase 3)
- [ ] Notes management (full CRUD)
- [ ] Rediscovery Engine (age × last_seen × favorite)
- [ ] Local Backup/Restore (`.reclipzip`)
- [ ] Favorite toggle
- [ ] Collection CRUD (hiện là placeholder)
- [ ] Tag management (hiện là placeholder)
- [ ] Deep link schemes (`instagram://`, `tiktok://`)

### 🔜 Backlog (Phase 4+)
- [ ] Screenshot-to-Clip + OCR
- [ ] Smart Collections (rule-based)
- [ ] Import hàng loạt
- [ ] Cloud backup/sync
- [ ] Export Collection
- [ ] Moodboard
- [ ] Semantic search
- [ ] i18n (tiếng Việt)

## Known Bugs

| # | Bug | Severity | Status |
|---|-----|----------|--------|
| 1 | Smart Save Collection/Tags là placeholder, chưa lưu DB | Medium | Known |
| 2 | FTS5 input chưa sanitize (special chars gây lỗi) | Low | Known |
| 3 | Search không debounce (performance với library lớn) | Low | Known |
| 4 | `PlatformEnum.x` dùng `Icons.close` thay vì logo X | Low | Known |
| 5 | 2 badges (Online + Video) cùng hiện cho video items | Low | Known |
| 6 | Tag ID dùng timestamp (có thể trùng millisecond) | Low | Known |
| 7 | Thumbnail download stuck ở downloading nếu app kill | Low | Known |
| 8 | `_matchesAny` match subdomain quá rộng (`evil.reddit.com.attacker.com`) | Low | Known |

## Build History

| Run | Status | Notes |
|-----|--------|-------|
| #1-#22 | ❌ Fail | Gradle/Kotlin/AGP version issues |
| #23 | ✅ Success | First successful build |
| #24-#32 | ✅ Success | Stable |
| #33+ | ✅ Success | Phase 2 code |

## Commit History (gần nhất)

| Commit | Message |
|--------|---------|
| `3b9219d` | docs: update library + item-detail specs for thumbnail fix |
| `6fd9395` | fix: connect thumbnail display with DB |
| `e39379b` | docs: update smart-save spec |
| `4844543` | fix: Smart Save button now saves note + whySaved to DB |
| `4716996` | docs: add OpenSpec baseline — 20 capability specs |
| `2f8b4ea` | feat: Phase 2 Enrichment |
| `158f318` | fix: FTS5 search with original_url |
| `450b30f` | fix: url_launcher queries for Android 11+ |
