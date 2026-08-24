# Reclip — Pre-Launch Checklist (Deploy Play Store trong 1-2 ngày)

> Mục tiêu: ổn định, không crash, đáp ứng yêu cầu bắt buộc của Play Store. Không mở rộng tính năng — chỉ hardening + compliance. Ước tính tổng thời gian: 1–1.5 ngày làm + thời gian chờ Google review (xem mục 7).

---

## 1. Smoke Test — bắt buộc, 15-20 phút, làm TRƯỚC mọi việc khác

Chạy liên tục 1 lượt (không phải test từng phase tách rời) trên **thiết bị Android thật**, không phải emulator:

- [ ] Share 1 link Reddit, 1 TikTok, 1 Instagram, 1 YouTube, 1 X → tất cả xuất hiện trong Library, không crash.
- [ ] Đợi enrichment chạy nền → mở lại app → metadata cập nhật đúng (hoặc rơi về Quick Link card nếu fail, không phải màn hình trắng/lỗi).
- [ ] Mở Item Detail, sửa Note + Why → quay lại Library → thấy thay đổi được lưu.
- [ ] Bấm Open Original cho từng platform → mở đúng app/browser, không crash khi app gốc chưa cài.
- [ ] Kéo xuống xem Resurface section → không crash khi library còn ít item.
- [ ] Export backup → Import lại chính file đó → không mất/trùng dữ liệu.
- [ ] Tắt Wi-Fi/mobile data hoàn toàn → mở app, browse Library, search → không crash, không treo (ANR).
- [ ] Kill app hoàn toàn (swipe khỏi recent apps) → mở lại → dữ liệu vẫn còn nguyên.
- [ ] Xoay màn hình (nếu hỗ trợ) hoặc chuyển app đi/lại (background/foreground) giữa lúc đang enrichment chạy → không crash.

**Nếu bất kỳ mục nào fail → sửa trước, đừng qua bước 2.** Đây là rào chắn rẻ nhất bạn có.

---

## 2. Stability Hardening — các lỗi phổ biến nhất gây crash/ANR khi release

- [ ] **Bọc try-catch ở mọi entry point xử lý dữ liệu ngoài (Share Intent, JSON parse từ backup, response từ metadata adapter).** Đã làm phần lớn ở Phase 2 (adapter không throw), nhưng kiểm tra thêm: `receive_sharing_intent` callback, `jsonDecode` khi import backup, DB migration.
- [ ] **Global error handler** — bắt lỗi Flutter framework-level và Dart async không bắt được, để app không crash trắng xoá màn hình:
```dart
// main.dart
void main() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // log local, KHÔNG gửi đi đâu nếu chưa quyết định dùng Crashlytics (xem mục 5)
  };
  runZonedGuarded(() {
    runApp(const ReclipApp());
  }, (error, stack) {
    // catch lỗi ngoài Flutter widget tree (async, isolate...)
  });
}
```
- [ ] **Database migration an toàn:** verify `onUpgrade`/`onCreate` không throw nếu app được cài mới hoàn toàn (chưa từng có DB cũ) — test bằng cách uninstall hẳn app rồi cài lại.
- [ ] **Không có `!` (null assertion) ở bất kỳ đường code nào xử lý dữ liệu từ network/user input** — dò lại nhanh trong `metadata_result.dart`, `platform_detector.dart`, adapter code. Đây là nguồn crash phổ biến nhất khi dữ liệu thật khác dữ liệu test.
- [ ] **Timeout đã set đúng ở mọi network call** (đã có ở Phase 2 adapters) — verify không có call nào thiếu timeout, dễ gây ANR khi mạng yếu.
- [ ] **Ảnh lớn không làm crash do OOM:** verify `cached_network_image`/`flutter_cache_manager` có giới hạn kích thước decode hợp lý, không load ảnh gốc độ phân giải cao trực tiếp vào grid nhỏ.
- [ ] **Release build thật** (không phải debug build) — chạy `flutter build apk --release` và test trên thiết bị thật, vì hành vi release khác debug (đặc biệt với R8/ProGuard có thể strip nhầm code nếu thiếu keep rules).

---

## 3. Play Store — yêu cầu bắt buộc, không có thì không submit được

- [ ] **Privacy Policy URL** — **bắt buộc 100%**, kể cả app hoàn toàn local-first không có server. Google yêu cầu mọi app phải có link Privacy Policy công khai trong Play Console. Cách nhanh nhất: viết 1 trang đơn giản (có thể dùng GitHub Pages hoặc Google Sites, không cần server riêng) nêu rõ: app lưu dữ liệu local trên máy, không gửi lên server (nếu đúng vậy), có dùng Crashlytics hay không (xem mục 5) thì phải khai rõ.
- [ ] **Data Safety form** trong Play Console — khai đúng những gì app thực sự thu thập. Vì app hiện tại local-first + có thể thêm crash reporting, khai trung thực: "Không thu thập dữ liệu cá nhân" nếu không dùng Crashlytics, hoặc khai rõ "Crash logs" nếu có dùng.
- [ ] **Target SDK version** — kiểm tra `android/app/build.gradle`, Play Store yêu cầu targetSdkVersion mới nhất theo chính sách hiện hành (thường là Android 14/API 34 trở lên cho app mới) — build lỗi target SDK cũ sẽ bị Play Console từ chối ngay khi upload.
- [ ] **App Bundle (.aab), không phải .apk** — Play Store bắt buộc dùng Android App Bundle:
```bash
flutter build appbundle --release
```
- [ ] **Signing key** — tạo keystore riêng, lưu an toàn (mất file này = không update được app sau này):
```bash
keytool -genkey -v -keystore ~/reclip-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias reclip
```
Cấu hình trong `android/key.properties` (không commit file này vào git) và `android/app/build.gradle`.
- [ ] **App icon** đủ kích thước (adaptive icon cho Android 8+), tránh dùng icon mặc định Flutter.
- [ ] **Content rating questionnaire** trong Play Console — điền đúng (app lưu link mạng xã hội, không có nội dung tự sinh ra, thường rating thấp).
- [ ] **Store listing tối thiểu:** tên app, mô tả ngắn/dài, ít nhất 2 screenshot thật từ app (không phải mockup), feature graphic (1024x500).
- [ ] **Permissions đã khai đúng** trong `AndroidManifest.xml` — verify chỉ có `INTERNET`, không có permission thừa nào Play Console sẽ hỏi lý do (như storage permission không cần thiết đã loại bỏ từ Phase 0-1 brief).
- [ ] **Package name (applicationId)** chốt cứng, không đổi sau khi submit lần đầu — kiểm tra kỹ trước khi build release đầu tiên.

---

## 4. Version & Build config

```gradle
// android/app/build.gradle
defaultConfig {
    applicationId "com.yourcompany.reclip"   // chốt cứng, verify đúng trước khi build
    versionCode 1
    versionName "1.0.0"
    minSdkVersion 26   // Android 8.0, đúng như đã chốt ở Phase 0-1 brief
    targetSdkVersion flutter.targetSdkVersion
}
```

- [ ] Verify `minSdkVersion 26` khớp với quyết định ban đầu ở technical brief Phase 0-1.
- [ ] ProGuard/R8: nếu dùng `drift`, `dio`, cần verify không bị strip nhầm — test kỹ release build (mục 2) chính là để bắt lỗi này, vì lỗi ProGuard chỉ xuất hiện ở release build, không xuất hiện lúc debug.

---

## 5. Crash monitoring sau khi launch — khuyến nghị thêm, không bắt buộc nhưng nên có

Với timeline 1-2 ngày, bạn sẽ không kịp test hết mọi thiết bị/tình huống — nên có cách biết app crash ở đâu sau khi lên Store, thay vì mù thông tin hoàn toàn.

**Đề xuất:** thêm Firebase Crashlytics (free, setup nhanh ~30 phút, không phải "backend tự host" — là managed service của Google chỉ để nhận crash log). Đây là ngoại lệ hợp lý so với nguyên tắc "zero server" đã giữ xuyên suốt — vì mục đích khác hẳn (giám sát vận hành, không phải tính năng sản phẩm), và bắt buộc phải khai vào Data Safety form (mục 3) nếu dùng.

**Nếu không có thời gian setup Crashlytics trong 1-2 ngày:** bỏ qua, chấp nhận rủi ro không biết crash rate sau launch — nhưng nên làm ngay sau khi launch, đừng để lâu.

---

## 6. Rollout Strategy — giảm rủi ro cho timeline gấp

Vì không có bước test người dùng thật trước, **đừng release thẳng 100% ngay lần đầu**. Play Console hỗ trợ sẵn cơ chế này miễn phí:

- [ ] Submit qua **Internal Testing track** trước (chỉ mất vài phút để lên, không cần Google review lâu) — tự cài qua link internal, chạy lại Smoke Test (mục 1) trên chính bản build sẽ lên Store, không phải bản debug.
- [ ] Sau đó submit **Production** nhưng dùng **Staged Rollout** (ví dụ 20% user trước) thay vì 100% ngay — nếu có crash bất ngờ ở thiết bị/Android version bạn chưa test tới, ảnh hưởng ít người hơn và bạn có thể dừng rollout kịp thời.

---

## 7. Timeline thực tế — lưu ý quan trọng

"Deploy lên Play Store trong 1-2 ngày" cần tách rõ 2 việc:
- **Chuẩn bị + submit:** hoàn toàn khả thi trong 1-2 ngày nếu làm đúng checklist trên.
- **Google review app mới (lần đầu):** thường mất **thêm vài giờ đến vài ngày** ngoài tầm kiểm soát của bạn (Google Play policy hiện tại, có thể thay đổi) — đặc biệt app mới từ tài khoản developer mới có thể bị review kỹ hơn. Nên tính mốc "submit xong" trong 1-2 ngày, không phải "user tải được" trong 1-2 ngày.

---

## Tóm tắt thứ tự làm việc

1. Smoke test (mục 1) — 20 phút, bắt buộc trước tiên.
2. Stability hardening (mục 2) — sửa mọi lỗi phát hiện được ở bước 1.
3. Build release + verify trên thiết bị thật (không phải debug build).
4. Chuẩn bị Play Store assets (privacy policy, icon, screenshot, store listing) — mục 3.
5. Setup signing + build .aab — mục 4.
6. (Khuyến nghị) Setup Crashlytics nhanh — mục 5.
7. Submit Internal Testing → verify lại → Production với Staged Rollout — mục 6.