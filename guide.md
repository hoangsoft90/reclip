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
2. Hoặc vào Library → chọn item → nhấn **"Add details"**
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
- Badge "⚠ Online to view" (cần mạng để xem nội dung gốc)

### 4. Search (Tìm kiếm)

Tìm nội dung đã lưu:

1. Nhấn tab **Search** ở dưới
2. Gõ từ khoá vào ô tìm kiếm
3. Kết quả hiện theo thời gian thực (FTS5 full-text search)

**Tìm được:**
- Title
- Description
- Note
- Tag

### 5. Item Detail (Chi tiết item)

Xem chi tiết một nội dung:

1. Nhấn vào item trong Library
2. Xem thông tin:
   - Title
   - Platform
   - Thời gian lưu
   - Description (nếu có)
   - Note (nếu có)
   - Why saved (nếu có)

3. Nhấn **"Open Original"** để mở link gốc trong trình duyệt

### 6. Open Original (Mở nội dung gốc)

Mở link gốc từ trong app:

1. Vào Item Detail
2. Nhấn **"Open Original"**
3. App sẽ mở link trong trình duyệt (Chrome, Safari...)

**Lưu ý:** Nội dung gốc cần kết nối Internet để xem.

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

| Lý do | Khi nào dùng |
|-------|--------------|
| Read later | Đọc sau khi rảnh |
| Try this | Thử làm theo |
| Learn this | Học từ nội dung |
| Inspiration | Lấy cảm hứng |
| Just interesting | Chỉ thấy hay hay |

---

## Tips

### Tốc độ lưu
- Quick Save luôn < 1 giây
- Không cần mở app trước — share trực tiếp từ app khác
- Save offline được (lưu URL, không cần mạng)

### Tìm lại nội dung
- Dùng Search với từ khoá trong title/note
- Dùng Collections để lọc theo chủ đề
- Dùng Tags để lọc theo nhãn
- Xem lại item cũ qua "Why saving?"

### Offline
- Library, Search, Collections hoạt động offline
- Nội dung gốc cần Internet để xem (badge "⚠ Online to view")
- Thumbnail sẽ tải khi có mạng (Phase 2)

---

## Troubleshooting

### App không hiện trong danh sách Share?
- Đảm bảo đã cài đặt app
- Thử khởi động lại app
- Kiểm tra Android Settings → Apps → Reclip → Defaults

### Save không thành công?
- Kiểm tra link có hợp lệ không
- Thử copy link thủ công → paste vào app

### App crash khi mở?
- Gỡ cài đặt → Cài đặt lại
- Kiểm tra Android version (cần 8.0+)

---

## Technical Info

- **Framework:** Flutter 3.24
- **Database:** Drift (SQLite) + FTS5
- **State Management:** flutter_riverpod
- **Min Android:** API 26 (Android 8.0)

---

## Links

- **GitHub:** https://github.com/hoangsoft90/reclip
- **Build Status:** https://github.com/hoangsoft90/reclip/actions
- **Report Issues:** https://github.com/hoangsoft90/reclip/issues

---

*Last updated: August 2026*
