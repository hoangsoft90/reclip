# Reclip — Bản kế hoạch tổng hợp cuối cùng (v2)

> Save what you discover. Find it again.

Bản v2 này thay thế `plan1_final.md`, tích hợp phản biện từ 5 vòng review độc lập. So với v1, thay đổi lớn nhất nằm ở **UX Save flow** (bỏ friction), **Data schema** (sửa lỗi thiết kế), và **loại bỏ over-engineering** — tránh xây quá nhiều trước khi chứng minh được vòng lặp hành vi cốt lõi.

**North Star hành vi cần chứng minh trước tiên:**
> Người dùng thấy content hay → Share vào Reclip trong 1 giây → vài ngày sau quay lại và **tìm được nó**.

Nếu vòng lặp này không hoạt động mượt, mọi tính năng khác (Moodboard, OCR, Smart Collections, semantic search...) đều vô nghĩa. Toàn bộ quyết định trong tài liệu này được lọc qua câu hỏi:

> **"Có giúp user save nhanh hơn, tổ chức tốt hơn, hoặc tìm lại thứ đã save dễ hơn không?"** Nếu không rõ hoặc chỉ "đẹp" → ra khỏi MVP.

---

## 1. Video download — giữ nguyên quyết định từ v1

| Platform | Độ khó | Rủi ro pháp lý | Kết luận |
|---|---|---|---|
| Reddit | 🟢 Dễ–TB (API công khai) | 🟢 Thấp | Không cam kết — chỉ "investigate separately", không thiết kế architecture dựa trên giả định sẽ thêm sau |
| YouTube | 🔴 Khó | 🔴 Cao | Không làm |
| TikTok | 🔴 Khó | 🔴 Cao | Không làm |
| Instagram | 🔴 Rất khó | 🔴 Rất cao | Không làm |
| X | 🔴 Khó | 🟡 TB–Cao | Không làm |

**Quyết định cuối:** Không tải video ở bất kỳ phase gần nào. Video luôn xem qua "Open Original" (mở app gốc hoặc trình duyệt). Reddit không được đối xử như "ngoại lệ mặc định sẽ làm" — nếu muốn, đó là một investigation riêng, tách biệt hoàn toàn khỏi roadmap chính.

**Sửa từ v1:** "Offline" không còn là core promise trong tagline/marketing (dễ khiến người dùng kỳ vọng nhầm video/ảnh offline đầy đủ). Offline là **property của app** (browse library, search, xem cache được), không phải lời hứa chính. Badge "Cần Internet để xem video" vẫn hiển thị rõ trong UI runtime.

---

## 2. UX Save Flow — thay đổi quan trọng nhất so với v1

### Vấn đề của v1
Bắt user chọn Collection + Tags + "Why saving?" + Note ngay trong Preview Screen mỗi lần Share — đây là friction chết người trên Android Share Sheet. User đang ở trạng thái "lướt", không muốn dừng lại điền form.

### Thiết kế mới — hai luồng song song

**Luồng 1 — Quick Save (mặc định, bắt buộc phải nhanh nhất có thể)**
```
Share → Reclip → Toast "Saved to Library ✓" (biến mất sau ~2s) → Kết thúc
```
- KPI: **Time-to-Save < 1 giây** trong ít nhất 90% trường hợp, không phụ thuộc network.
- Save phải luôn thành công ngay cả khi metadata thất bại — nguyên tắc bắt buộc:
  > **Metadata enrichment is optional. Saving the URL is mandatory và không bao giờ phụ thuộc metadata.**

**Luồng 2 — Smart Save (tuỳ chọn, chỉ khi user chủ động)**
- Nút "Add details" xuất hiện trên chính Toast đó (hoặc trong notification).
- Bấm vào mới mở BottomSheet: Collection, Tags, "Why saving?", Note.
- Có setting "Always open Smart Save" cho power user muốn mặc định enrich ngay.

### Timeline kỹ thuật của một lần Save

```
T0 (ngay lập tức)     → URL detected, tạo SavedItem tối thiểu (url, platform, savedAt)
T0 + vài ms            → Platform/content-type detect, hiện Toast "Saved ✓"
T0 + background        → Fetch metadata, thumbnail, caption (không chặn UI)
Nếu enrichment fail     → Item vẫn tồn tại hợp lệ, hiển thị Quick Link card, cho user tự sửa sau
```

### Open Original — nâng thành core feature (không phải hành vi phụ)

```
┌─────────────────────────┐
│       THUMBNAIL         │
│  How to build X         │
│  @creator · TikTok      │
│  ✓ Saved                │
│  ⚠ Online to view       │
│ [Open Original]  [···]  │
└─────────────────────────┘
```
Fallback bắt buộc:
```
Open Original → Try deep link → Platform app installed?
                                   Yes → Open app
                                   No  → Open browser
```
Không được assume deep link luôn hoạt động — cần test thực tế trên Android.

---

## 3. Data Schema (v2 — đã sửa 3 lỗi thiết kế nghiêm trọng)

### Lỗi đã sửa so với v1
1. `collection_id TEXT` (1-to-many) → **many-to-many** qua bảng trung gian `item_collections`.
2. `tags TEXT` (JSON array) → **normalized** `tags` + `item_tags`.
3. `source_url UNIQUE` → tách `original_url` / `canonical_url`, **không** UNIQUE constraint cứng ở DB; xử lý trùng lặp ở tầng logic ứng dụng (hỏi user: "Bạn đã lưu link này rồi, muốn cập nhật note hay tạo bản ghi mới?").

### Nguyên tắc: SavedItem hợp lệ chỉ cần URL + platform + savedAt

```sql
-- saved_items
id TEXT PRIMARY KEY
original_url TEXT              -- URL nguyên bản user share, giữ nguyên tracking params
canonical_url TEXT              -- URL đã clean tracking params, dùng để phát hiện trùng
platform TEXT CHECK(platform IN ('reddit','instagram','tiktok','youtube','x','other'))
content_type TEXT CHECK(content_type IN ('video','image','gallery','text','link','mixed','unknown'))
metadata_status TEXT CHECK(metadata_status IN ('pending','success','partial','failed')) DEFAULT 'pending'
title TEXT
description TEXT
author TEXT
author_url TEXT
saved_at INTEGER NOT NULL
last_accessed_at INTEGER
is_favorite BOOLEAN DEFAULT 0
is_archived BOOLEAN DEFAULT 0
note TEXT
why_saved TEXT               -- read_later / try_this / learn_this / inspiration / just_interesting / null
link_status TEXT CHECK(link_status IN ('alive','broken','unknown')) DEFAULT 'unknown'
last_checked_at INTEGER      -- chỉ cập nhật khi check on-demand, KHÔNG có background scan định kỳ

-- item_collections (many-to-many)
item_id TEXT REFERENCES saved_items(id) ON DELETE CASCADE
collection_id TEXT REFERENCES collections(id) ON DELETE CASCADE
created_at INTEGER
PRIMARY KEY (item_id, collection_id)

-- collections
id TEXT PRIMARY KEY
name TEXT
icon TEXT
color TEXT
parent_id TEXT REFERENCES collections(id)     -- nested, chỉ dùng khi thực sự cần (Phase 4+)
is_smart BOOLEAN DEFAULT 0                     -- Phase 4+, không phải MVP
smart_rule TEXT
created_at INTEGER

-- tags
id TEXT PRIMARY KEY
name TEXT UNIQUE
created_at INTEGER

-- item_tags (many-to-many)
item_id TEXT REFERENCES saved_items(id) ON DELETE CASCADE
tag_id TEXT REFERENCES tags(id) ON DELETE CASCADE
created_at INTEGER
PRIMARY KEY (item_id, tag_id)

-- thumbnails (đơn giản cho MVP — KHÔNG generic hoá content_assets ngay)
id TEXT PRIMARY KEY
item_id TEXT REFERENCES saved_items(id) ON DELETE CASCADE
remote_url TEXT
local_path TEXT
download_status TEXT CHECK(download_status IN ('pending','downloading','done','failed'))
size_bytes INTEGER
created_at INTEGER
```

### Về việc tổng quát hoá `content_assets`

Một số review đề xuất generic hoá bảng thumbnail thành `content_assets` (hỗ trợ sẵn screenshot, OCR source, user attachment) ngay từ đầu. **Quyết định: hoãn lại đến Phase 4** (khi Screenshot-to-Clip thực sự được lên lịch). Ở MVP, bảng `thumbnails` đơn giản là đủ — tránh xây trước cho tính năng chưa chắc sẽ làm, đúng tinh thần "không over-engineer trước khi validate".

---

## 4. Metadata & Platform Adapter Strategy

| Platform | Cách lấy | Kỳ vọng thực tế | Fallback |
|---|---|---|---|
| Reddit | Public JSON API (`/.json`) | Khá ổn định | `<title>` tag |
| YouTube | oEmbed chính thức | Ổn định | `<title>` tag |
| X | oEmbed chính thức | Khá ổn | `<title>` tag |
| TikTok | Cơ chế public/embed hiện có | Không ổn định, hay đổi | User nhập tay + tự đính screenshot |
| Instagram | Embed page (hay thay đổi cấu trúc) | Kém nhất | User nhập tay + tự đính screenshot |

**Nguyên tắc bắt buộc:** Không hard-code giả định lạc quan cho bất kỳ platform nào. Mỗi adapter phải viết theo tinh thần:
> "Adapter hỗ trợ các cơ chế public/embed hiện có; **thất bại là kỳ vọng bình thường** và phải degrade gracefully (rơi về Quick Link card + og:title/og:image nếu có)."

**Trước khi code UI fallback (Phase 0, bắt buộc):** Test tay 50–100 URL thật cho mỗi platform, đo tỷ lệ thành công thực tế theo từng platform riêng biệt (không đo gộp chung một con số). Không thiết kế UI dựa trên ước tính chưa kiểm chứng.

### Về Proxy backend (nếu cần)

Việc gọi trực tiếp các endpoint này từ app di động có thể bị chặn theo User-Agent/IP. Nếu dùng serverless proxy (Cloudflare Worker/Vercel) để fetch hộ metadata, đây **bắt buộc** phải có các biện pháp bảo mật ngay từ thiết kế đầu tiên — nếu không sẽ trở thành Open Proxy có thể bị lợi dụng cho tấn công SSRF:

- **URL Allowlist**: chỉ cho phép domain tiktok.com, instagram.com, reddit.com, youtube.com, x.com/twitter.com.
- **SSRF filtering**: chặn localhost, 127.x.x.x, 10.x.x.x, 169.254.x.x và các dải IP nội bộ khác.
- **Rate limiting** theo user/app token.
- **Request timeout** (~5s) và **giới hạn kích thước response** (~2MB).
- Không cache nội dung nhạy cảm ở tầng proxy.

Không nên quảng cáo app là "100% zero server cost" — phần dữ liệu cá nhân (note, tag, ảnh cache) local-first, nhưng bước lấy metadata cần một lớp proxy tối giản có chi phí vận hành nhỏ.

---

## 5. Tính năng theo mức ưu tiên

### Giữ nguyên & ưu tiên cao (MVP)
- Quick Save (1-tap) + Smart Save (optional)
- Local-first: hiện UI ngay từ local DB, enrich chạy nền phía sau
- Visual library (Grid/List)
- FTS5 full-text search (title, caption, note, tag)
- Faceted filter: platform, content type, thời gian, có note hay không, why_saved — thường hữu ích hơn semantic search ở giai đoạn đầu, chạy hoàn toàn local
- "Why I saved this" (optional, không bắt buộc)
- Open Original + fallback deep-link/browser
- Resurface đơn giản: random + "chưa xem lại lâu" + favorite
- Local Backup/Restore (`.reclipzip` hoặc `.json`) — trước Cloud Sync, đảm bảo privacy + chi phí hạ tầng gần $0

### Hạ xuống backlog rõ ràng (không phải MVP)
- Moodboard / Context Canvas
- Smart Collections rule-based
- Import hàng loạt từ Instagram/Reddit export — **lý do:** file export của Meta có thể mất vài giờ–vài ngày mới nhận được qua email, không phải trải nghiệm onboarding tức thì; nhóm user biết cách export dữ liệu cũng rất nhỏ. Chỉ nên coi là tính năng power-user (Phase 5+), không phải chiến lược cold-start chính. Onboarding tốt nhất vẫn là hướng dẫn user Share thử 1 link ngay lần mở app đầu tiên.
- Semantic search / on-device embeddings — chỉ đầu tư khi có bằng chứng thực tế FTS5 không đủ (nhiều query mô tả mơ hồ bị miss ở library đủ lớn), không phải làm song song từ đầu.
- Broken-link periodic background scan — **loại bỏ hoàn toàn**, tốn pin/dễ bị Android Doze kill task, dễ false positive (nhiều platform trả HTTP 200 kèm màn hình login thay vì 404). Thay bằng **on-demand check**: chỉ kiểm tra khi user bấm "Open Original" hoặc mở chi tiết item.
- SM-2 / spaced repetition — thiết kế cho flashcard học tập, không hợp bookmark social. Thay bằng **Rediscovery Score** đơn giản: hàm của age, last_seen, favorite, why_saved.
- Cloud Sync — chỉ làm sau khi Local Backup/Restore đã ổn và có tín hiệu retention thực sự.

### Bổ sung đáng cân nhắc (sau khi có validation, Phase 4+)
- Screenshot-to-Clip: share screenshot vào app → OCR local (Google ML Kit) trích xuất caption/username/hashtag → lưu thành visual card. Hữu ích cho Instagram Story/private account không có link share.
- Duplicate detection: dựa trên canonical_url + content fingerprint.
- Content decay / snapshot: khi link gốc chết, giữ lại thumbnail + caption + note đã cache, thông báo trung thực "Nội dung gốc không còn" — **không overclaim** là "bản lưu cuối cùng đầy đủ" nếu chỉ có metadata, không có video.

---

## 6. Tech stack (giữ nguyên từ v1)

| Thành phần | Lựa chọn | Lý do |
|---|---|---|
| Framework | Flutter | Kiểm soát tốt native/media/file storage |
| State management | `flutter_riverpod` | Dễ test, hợp async |
| Local DB | `drift` (SQLite) + FTS5 | Relational + full-text search |
| Share Intent | `receive_sharing_intent` | Bắt Share từ social apps |
| Image caching | `cached_network_image` | Cache thumbnail offline |
| OCR (Phase 4+) | `google_mlkit_text_recognition` | Local, cho Screenshot-to-Clip |
| Backend (nhẹ, khi cần) | Serverless function | Proxy fetch metadata, có security design từ đầu |

---

## 7. Roadmap (v2 — chia nhỏ hơn v1, mỗi milestone testable ngay)

### Phase 0 — Technical Spike (2–3 ngày)
- Share Intent handler + URL normalizer + Platform detector
- Open Original: deep-link + browser fallback (test thực tế trên Android với TikTok, Instagram, Reddit, YouTube, X)
- Test tay 50–100 URL thật/platform → đo metadata success rate thực tế theo từng platform
- **Không cần metadata đẹp ở bước này.** Mục tiêu: xác nhận Share Intent ổn định từ các app nguồn.

### Phase 1 — Core Habit (MVP thật sự)
- Schema đã sửa (many-to-many, normalized tags, canonical_url)
- Quick Save 1-tap + Toast
- Basic Library (Grid/List)
- Local SQLite + FTS5 cơ bản
- Measure: Time-to-Save, Save Success Rate

### Phase 2 — Enrichment
- Platform Adapters (mỗi platform 1 adapter riêng, degrade gracefully khi fail)
- Background metadata + thumbnail fetch
- Fallback Quick Link card đẹp (first-class, không phải màn hình lỗi)
- Offline UI rõ ràng (badge trạng thái)
- Faceted filter
- Measure: Metadata Success Rate theo từng platform

### Phase 3 — Value Loop
- Notes + "Why saved" (optional)
- Rediscovery Engine đơn giản (age × last_seen × favorite)
- Local Backup/Restore
- Measure: Retrieval Rate, Week-1 Retention

### Phase 4+ (chỉ khi đã có tín hiệu retention thật)
- Screenshot-to-Clip + OCR
- Smart Collections
- Import hàng loạt (power-user)
- Cloud backup/sync
- Export Collection
- Moodboard (chỉ nếu creator thật sự đòi hỏi)
- Reddit media investigation (tách biệt, không cam kết)

---

## 8. Product Metrics (thiếu hoàn toàn ở v1 — bổ sung ở v2)

| Metric | Mục tiêu | Ghi chú |
|---|---|---|
| Time-to-Save | < 1–2 giây | Từ Share đến Save thành công, không phụ thuộc network |
| Save Success Rate | > 95% | Share → Reclip → lưu thành công |
| Metadata Success Rate | Đo riêng theo từng platform | Không đo gộp một con số chung |
| **Retrieval Rate (7 ngày)** | — | **North Star Metric**: % item được mở lại/tìm thấy sau 7 ngày |
| Week-1 Retention | theo dõi | User quay lại app trong 7 ngày |
| Rediscovery Rate | theo dõi | % user mở lại item cũ (>7 ngày) |

Nếu Save Rate cao nhưng Retrieval Rate gần 0 → Reclip đang là "nghĩa địa thông tin". Nếu cả hai cao → sản phẩm đang giải quyết đúng vấn đề.

**Lưu ý triển khai đo lường:** ở giai đoạn MVP-0/1 với số lượng người dùng thử rất nhỏ, không cần dựng hệ thống analytics/dashboard đầy đủ. Một local event log đơn giản (ghi lại `save_success`, `item_opened_after_N_days`) là đủ để quan sát định tính; đầu tư analytics chuẩn hoá nên đến sau khi có người dùng thật ở quy mô đủ lớn để số liệu có ý nghĩa.

---

## 9. Monetization

- **Free:** không paywall hành vi cốt lõi "save" — unlimited local save + collections + tags + search + offline cache cơ bản (có thể giới hạn dung lượng cache nếu cần, không giới hạn số item).
- **Pro:** cloud backup/sync, advanced export, AI features (semantic search khi có), automation, larger cache.
- Nguyên tắc: **paywall convenience/safety/power, không paywall core habit.** Giới hạn cứng số lượng item ở free-tier (ví dụ 200–300) có nguy cơ chặn đứng thói quen trước khi user kịp thấy giá trị retrieval — nên tránh.
- Cần chốt trước khi định giá: thị trường mục tiêu ban đầu (Việt Nam hay global) — ảnh hưởng mức giá và hình thức thanh toán.

---

## 10. Rủi ro cần theo dõi

1. **Pháp lý:** cache thumbnail/caption vẫn là nội dung có bản quyền của người đăng — luôn hiển thị nguồn + "Open Original", tránh public chia sẻ nội dung cache ra ngoài app ở quy mô lớn.
2. **Kỹ thuật:** endpoint metadata của TikTok/Instagram có thể đổi bất kỳ lúc nào — kiến trúc Adapter per-platform giúp sửa cục bộ mà không ảnh hưởng toàn app.
3. **Bảo mật:** nếu dùng proxy, không triển khai security (SSRF/allowlist/rate-limit) từ đầu = rủi ro bị lợi dụng làm bàn đạp tấn công.
4. **Giả định chưa kiểm chứng:** % thành công metadata, số item free-tier hợp lý — cần dữ liệu thật từ Phase 0, không dựa vào ước tính của các bản review.
5. **Over-engineering:** nguy cơ lớn nhất hiện tại không còn là "thiếu tính năng" mà là **xây quá nhiều kiến trúc "chuẩn" (generic assets, nested/smart collections, metrics dashboard đầy đủ) trước khi chứng minh vòng lặp Save → Retrieval hoạt động.** Mọi tính năng/thiết kế kỹ thuật thêm vào cần tự hỏi: có phục vụ trực tiếp vòng lặp cốt lõi không, hay chỉ "chuẩn bị sẵn cho tương lai chưa chắc xảy ra"?

---

## Kết luận

So với v1, bản v2 giữ nguyên quyết định bỏ tải video, nhưng sửa 3 nhóm vấn đề quan trọng: **(1) UX Save flow** — từ "bắt điền form" sang "1-tap mặc định, chi tiết là tuỳ chọn"; **(2) Data schema** — sửa lỗi 1-to-many/JSON-array/UNIQUE-constraint thành thiết kế many-to-many chuẩn; **(3) Phạm vi MVP** — cắt bỏ các tính năng "nghe hay nhưng chưa chứng minh giá trị" (Moodboard, SM-2, import hàng loạt, broken-link định kỳ, semantic search sớm) về backlog, tập trung toàn lực vào việc chứng minh một hành vi duy nhất: **Save trong 1 giây → tìm lại trong vài giây, sau vài ngày hay vài tuần.**

Nếu vòng lặp đó hoạt động tốt, Reclip có lý do tồn tại vững chắc — kể cả khi không tải được video nào, không có Moodboard, không có AI search.