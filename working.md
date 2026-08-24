# Working — Reclip Project

## Current State
- **Last Updated:** 2026-08-24
- **Phase:** Phase 2 Enrichment — DONE
- **Next:** Phase 3 (TBD — dựa trên metrics từ Phase 2)

## Current Path
```
/home/kythuat_hoangweb/htdocs_apps/reclip
```

## Phase 2 Done
- 26 files changed, 1529 insertions
- 0 errors, 25/25 tests pass
- GitHub Actions build #33+

## Known Issues to Fix
1. ✅ Smart Save button — NOW updates DB (fixed after openspec)
2. ✅ Thumbnail display — NOW connected to DB (Library + ItemDetail)
3. Faceted filter date picker — no UI yet (client-side filter only)
4. TikTok/Instagram metadata — hay fail (expected, Quick Link fallback works)
5. In-memory MetricsLogger — data lost on restart

## Phase 3 Decision Pending
- Chạy app thật ~50 items đa dạng platform
- Xem MetricsLogger output (success rate per platform)
- Quyết định: proxy backend vs accept Quick Link fallback

## Recent Commits
- `ff266b2` — Update AGENTS.md with latest project state
- `3b9219d` — Connect thumbnail display to DB
- `7fa445a` — Fix Smart Save button update DB
- `4716996` — OpenSpec baseline (20 specs)
- `20048ee` — Phase 2 Enrichment (26 files)
- `450b30f` — url_launcher <queries> fix
- `158f318` — Search FTS5 fix (add original_url)
