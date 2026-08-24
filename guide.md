# Reclip — Hướng dẫn sử dụng

> Save what you discover. Find it again.

Reclip là app "personal social library" giúp bạn lưu, tổ chức và tìm lại nội dung đã share từ Reddit, Instagram, TikTok, YouTube, X.

---

## Cài đặt

1. Tải APK từ GitHub Actions: https://github.com/hoangsoft90/reclip/actions
2. Chọn artifact `reclip-debug-apk` → Download
3. Mở file APK trên điện thoại Android → Cài đặt

**Yêu cầu:** Android 8.0 (API 26) trở lên

---

## Cách sử dụng

### 1. Quick Save (Lưu nhanh)

Đây là tính năng chính — lưu nội dung trong 1 giây:

1. Mở app xã hội (Reddit, Instagram, TikTok, YouTube, X)
2. Tìm nội dung bạn muốn lưu
3. Nhấn nút **Share** (Chia sẻ)
4. Chọn **Reclip** trong danh sách share
5. Xu hiện Toast **"Saved to Library ✓"** → Xong!

**Lưu ý:**
- Save luôn thành công, không phụ thuộc mạng
- Nếu link đã lưu trước đó → Toast hiện **"Already saved"**
- Time-to-Save < 1 giây

### 2. Smart Save (Lưu chi tiết)

Thêm thông tin cho item đã lưu:

1. Sau khi Quick Save, nhấn **"Add details"** trên Toast
2. Hoặc vào Library → chọn item → nhấn nút **Edit** (✏️) ở góc Note/Why
3. Điền thông tin:
   - **Collection:** Gán vào bộ sưu tập
   - **Tags:** Thêm nhãn
   - **Why saving?** Lý do lưu (Read later, Try this, Learn this, Inspiration, Just interesting)
   - **Note:** Ghi chú cá nhân
4. Nhấn **Save**

### 3. Xem Library (Thư viện)

Xem tất cả nội dung đã lưu:

1. Mở app → Tab **Library**
2. Chuyển đổi giữa **Grid** (dạng lưới) và **List** (dạng danh sách) bằng nút góc phải
3. Nhấn vào item để xem chi tiết

**Thông tin hiển thị:**
- Title (hoặc tên domain nếu chưa có metadata)
- Platform icon (Reddit, Instagram, TikTok, YouTube, X)
- Thời gian lưu
- Thumbnail (nếu đã tải)
- Badge "⚠ Online to view" (cần mạng để xem nội dung gốc)
- Badge "Quick Link" (metadata chưa load — tap để edit)

### 4. Search (Tìm kiếm)

Tìm nội dung đã lưu:

1. Nhấn tab **Search** ở dưới
2. Gõ từ khoá vào ô tìm kiếm
3. Kết quả hiện theo thời gian thực (FTS5 full-text search)

**Tìm được:**
- Title
- Description
- Note
- URL

### 5. Item Detail (Chi tiết item)

Xem chi tiết một nội dung:

1. Nhấn vào item trong Library
2. Xem thông tin:
   - Title
   - Platform
   - Thời gian lưu
   - Thumbnail (nếu có)
   - Description (nếu có)
   - Note + Why saved (nếu có)
3. Nhấn **"Open Original"** để mở link gốc trong trình duyệt
4. Nhấn icon **⭐** để đánh dấu yêu thích

### 6. Edit Note/Why (Sửa ghi chú)

Chỉnh sửa note và lý do lưu bất kỳ lúc nào:

1. Vào Item Detail
2. Nhấn vào khu vực Note/Why (hoặc nút **"Add note or why"** nếu chưa có)
3. Chỉnh sửa nội dung
4. Nhấn **Save**

### 7. Open Original (Mở nội dung gốc)

Mở link gốc từ trong app:

1. Vào Item Detail
2. Nhấn **"Open Original"**
3. App sẽ mở link trong trình duyệt (Chrome, Safari...)

**Lưu ý:** Nội dung gốc cần kết nối Internet để xem.

### 8. Favorites (Yêu thích)

Đánh dấu nội dung yêu thích:

1. Vào Item Detail
2. Nhấn icon **⭐** ở góc trên phải
3. Star chuyển sang màu vàng = đã yêu thích
4. Item yêu thích được ưu tiên hiển thị trong Resurface

---

## ✨ Resurface (Tái hiện)

Reclip tự động gợi ý nội dung bạn đã lưu từ lâu nhưng chưa xem lại:

- Hiển thị ở đầu Library screen
- Hiện tối đa **5 items** mỗi ngày
- Items được chọn dựa trên:
  - Thời gian lưu (> 24h)
  - Lý do lưu (Learn this > Try this > Read later > Inspiration > Just interesting)
  - Yêu thích (⭐ được nhân 1.5x điểm)
  - Items đã hiện trong 3 ngày qua sẽ bị loại
- Nhấn vào item để xem chi tiết

**Lưu ý:** Section sẽ ẩn nếu library có < 5 items hợp lệ.

---

## 📦 Backup & Restore

Sao lưu và khôi phục dữ liệu:

### Export (Xuất)

1. Vào **Settings** → **Backup & Restore**
2. Nhấn **"Export backup now"**
3. Chọn nơi lưu file (Google Drive, Files app, email...)
4. File JSON chứa tất cả: items, collections, tags

### Import (Nhập)

1. Vào **Settings** → **Backup & Restore**
2. Nhấn **"Restore from file"**
3. Chọn file backup JSON
4. Dữ liệu sẽ được **merge** (không xóa dữ liệu hiện có):
   - Items mới → thêm vào
   - Items trùng URL → giữ bản hiện tại, merge tags/collections

**Lưu ý:**
- File backup có checksum SHA-256 để kiểm tra integrity
- Không bao gồm file ảnh thumbnail (chỉ dữ liệu có cấu trúc)
- Sau restore, thumbnail sẽ được tải lại từ URL gốc

---

## Collections (Bộ sưu tập)

Tổ chức nội dung theo chủ đề:

1. Vào Smart Save → Chọn **Collection**
2. Tạo collection mới hoặc chọn có sẵn
3. Gán item vào nhiều collection (many-to-many)

**Ví dụ:**
- "Công nghệ" — lưu các bài về tech
- "Recipes" — lưu các công thức nấu ăn
- "Learning" — lưu các tài liệu học tập

---

## Tags (Nhãn)

Gắn nhãn cho nội dung:

1. Vào Smart Save → Chọn **Tags**
2. Tạo tag mới hoặc chọn có sẵn
3. Một item có nhiều tag

**Ví dụ:**
- `#flutter`, `#javascript`, `#python`
- `#tutorial`, `#inspiration`, `#funny`

---

## Why saving? (Lý do lưu)

Ghi lại tại sao bạn lưu nội dung:

| Lý do | Khi nào dùng | Hệ số Resurface |
|-------|--------------|-----------------|
| Learn this | Học từ nội dung | 1.4x (cao nhất) |
| Try this | Thử làm theo | 1.3x |
| Read later | Đọc sau khi rảnh | 1.2x |
| Inspiration | Lấy cảm hứng | 1.0x |
| Just interest | Chỉ thấy hay hay | 0.8x |

---

## Tips

### Tốc độ lưu
- Quick Save luôn < 1 giây
- Không cần mở app trước — share trực tiếp từ app khác
- Save offline được (lưu URL, không cần mạng)

### Tìm lại nội dung
- Dùng Search với từ khoá trong title/note/URL
- Dùng Collections để lọc theo chủ đề
- Dùng Tags để lọc theo nhãn
- Xem lại item cũ qua Resurface section
- Đánh dấu ⭐ cho items quan trọng

### Offline
- Library, Search, Collections hoạt động offline
- Nội dung gốc cần Internet để xem (badge "⚠ Online to view")
- Thumbnail sẽ tải khi có mạng

### Backup
- Export định kỳ để tránh mất dữ liệu
- Import merge an toàn — không xóa dữ liệu hiện có
- Lưu file backup vào Google Drive hoặc email cho chính mình

---

## Troubleshooting

### App không hiện trong danh sách Share?
- Đảm bảo đã cài đặt app
- Thử khởi động lại app
- Kiểm tra Android Settings → Apps → Reclip → Defaults

### Save không thành công?
- Kiểm tra link có hợp lệ không
- Thử copy link thủ công → paste vào app

### Thumbnail không hiển thị?
- Thumbnail tải khi có kết nối Internet
- Kiểm tra badge metadata status trên item
- Nếu là "Quick Link" → thumbnail chưa có, tap để edit title

### App crash khi mở?
- Gỡ cài đặt → Cài đặt lại
- Kiểm tra Android version (cần 8.0+)

---

## Technical Info

- **Framework:** Flutter 3.24
- **Database:** Drift (SQLite) + FTS5
- **State Management:** flutter_riverpod
- **HTTP:** Dio
- **Caching:** flutter_cache_manager (200MB LRU thumbnails)
- **Min Android:** API 26 (Android 8.0)
- **Architecture:** Client-only, local-first, zero server

---

## Links

- **GitHub:** https://github.com/hoangsoft90/reclip
- **Build Status:** https://github.com/hoangsoft90/reclip/actions
- **Report Issues:** https://github.com/hoangsoft90/reclip/issues

---

*Last updated: August 2026 — Phase 3 (Value Loop)*
