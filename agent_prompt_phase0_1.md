# Bắt đầu code Reclip (Phase 0 + Phase 1)

> Copy toàn bộ nội dung dưới đây và đưa cho agent (Claude Code, Cursor, v.v.) cùng với 2 file đính kèm: `plan1_final_v2.md` và `plan1_technical_brief_phase0_1.md`. Đặt cả 2 file này ở gốc repo trước khi bắt đầu.

---

## PROMPT (copy từ đây)

Bạn đang giúp tôi xây dựng app Android tên **Reclip** bằng Flutter — một "personal social library" để lưu, tổ chức và tìm lại nội dung đã share từ Reddit, Instagram, TikTok, YouTube, X.

Trước khi viết bất kỳ dòng code nào, hãy đọc kỹ 2 file sau trong repo:
1. `plan1_final_v2.md` — kế hoạch sản phẩm, kiến trúc, roadmap tổng thể.
2. `plan1_technical_brief_phase0_1.md` — spec kỹ thuật chi tiết (schema, cấu trúc thư mục, package version, regex, string UI, acceptance criteria) **chỉ cho Phase 0 và Phase 1**.

### Quy tắc bắt buộc

1. **Chỉ làm đúng Phase 0 và Phase 1** như mô tả trong `plan1_technical_brief_phase0_1.md`. Mục 11 của file đó liệt kê rõ những việc KHÔNG được làm ở giai đoạn này (metadata adapter thật, thumbnail download thật, proxy backend, deep link scheme cụ thể, i18n, background job...). Nếu bạn thấy cần làm thứ gì ngoài phạm vi đó để "cho đẹp" hoặc "cho đầy đủ", DỪNG LẠI và hỏi tôi trước, đừng tự ý mở rộng scope.
2. **Dùng đúng cấu trúc thư mục, package version, schema, và toàn bộ UI string** đã chốt sẵn trong technical brief — không tự đổi tên file/class, không tự chọn version khác, không tự viết lại string hiển thị.
3. **Nguyên tắc sống còn của product:** Save phải luôn thành công, không bao giờ phụ thuộc vào việc lấy metadata có thành công hay không. Nếu bạn viết code mà Save flow có khả năng fail hoặc bị chặn vì một bước enrichment nào đó lỗi, đó là bug nghiêm trọng cần sửa ngay.
4. **Không tạo thêm abstraction** (interface/repository pattern, use-case class riêng cho từng action nhỏ...) trừ khi thực sự có ≥2 cách triển khai khác nhau cần switch qua lại. Giữ code đơn giản, đúng tinh thần MVP.
5. Sau khi code xong một phần việc, **tự chạy lại checklist Definition of Done ở mục 9 của technical brief** và báo cáo rõ mục nào pass, mục nào chưa, thay vì chỉ nói "đã xong".

### Thứ tự làm việc mong muốn

**Bước 1 — Xác nhận hiểu đúng trước khi code**
Tóm tắt lại ngắn gọn (5-10 dòng) những gì bạn hiểu về scope Phase 0–1, và liệt kê bất kỳ điểm nào trong 2 file chưa rõ ràng hoặc có vẻ mâu thuẫn. Tôi sẽ trả lời trước khi bạn code.

**Bước 2 — Khởi tạo project**
- Tạo Flutter project mới (`flutter create`), áp đúng cấu trúc thư mục ở mục 1 của technical brief.
- Thêm đúng dependencies ở mục 0, chạy `flutter pub get`, đảm bảo build sạch trên Android trước khi code tiếp.

**Bước 3 — Core layer (không phụ thuộc UI)**
- `UrlNormalizer`, `PlatformDetector` theo đúng code mẫu ở mục 3–4.
- Viết đầy đủ unit test theo danh sách ở mục 10 của technical brief — chạy pass 100% trước khi sang bước tiếp theo.

**Bước 4 — Database layer**
- Định nghĩa Drift tables đúng theo mục 2, chạy `build_runner` để generate code.
- Viết migration `schemaVersion = 1` với khung `onUpgrade` sẵn (dù chưa có logic).
- Setup FTS5 virtual table + triggers qua raw SQL trong migration.

**Bước 5 — Share Intent + Quick Save flow**
- Implement `receive_sharing_intent`, verify nhận được Intent thật (không chỉ mock).
- Implement `QuickSaveService.quickSave()` đúng logic dedup ở mục 3 — test kỹ case "đã tồn tại" không được tạo record trùng.
- Đo Time-to-Save bằng `Stopwatch`, log ra console.

**Bước 6 — UI tối thiểu**
- Library screen (Grid/List), Item Detail screen, Quick Save Toast, Smart Save bottom sheet.
- Dùng đúng string từ `AppStrings`, không hard-code text.

**Bước 7 — Open Original**
- Implement theo đúng logic fallback ở mục 8 (deep link → browser, `_buildDeepLink` trả `null` ở Phase 1 là hành vi chấp nhận được).

**Bước 8 — Chạy Acceptance Criteria**
- Với từng gạch đầu dòng ở mục 9 (Phase 0 DoD và Phase 1 DoD), báo cáo kết quả cụ thể (pass/fail + số liệu đo được, ví dụ Time-to-Save trung bình là bao nhiêu ms qua bao nhiêu lần thử).
- Với phần cần test trên thiết bị Android thật (Share Intent từ app mạng xã hội thật, Open Original), nếu bạn không có quyền truy cập thiết bị thật, nói rõ điều đó và liệt kê chính xác các bước tôi cần tự làm để verify.

### Khi nào cần hỏi lại tôi thay vì tự quyết định

- Bất kỳ lúc nào bạn cần thêm thư viện không có trong danh sách ở mục 0.
- Bất kỳ lúc nào bạn định implement thứ gì thuộc mục 11 ("không cover ở Phase 0-1").
- Nếu Definition of Done ở mục 9 không đạt được sau khi đã thử hợp lý (ví dụ Time-to-Save > 1000ms dù đã tối ưu) — báo cáo số liệu thật và đề xuất hướng xử lý, đừng tự hạ chuẩn để "cho pass".

Bắt đầu từ Bước 1.

---
