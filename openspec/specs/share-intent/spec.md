# share-intent

## Purpose
Nhận URL từ Android Share Sheet (khi user share từ Reddit/Instagram/TikTok/YouTube/X), trích xuất URL, và trigger Quick Save tự động.

## Requirements

### REQ-1: Nhận share intent khi app đang chạy
Khi app đang mở và user share → `getMediaStream()` nhận được list `SharedMediaFile`.

**Scenario: Share khi app đang chạy**
- Given: App đang mở
- When: User share URL từ app khác qua Share Sheet → chọn "Reclip"
- Then: `getMediaStream()` emit list files, mỗi file `.path` được xử lý qua `_handleShare`
- Reference: `lib/features/share_intent/share_intent_handler.dart:16-24`

### REQ-2: Nhận share intent khi app mới mở
Khi app được mở bởi share intent → `getInitialMedia()` trả về media đã share.

**Scenario: Share khi app chưa mở**
- Given: App chưa chạy
- When: User share URL từ app khác → chọn "Reclip"
- Then: App mở, `getInitialMedia()` trả về list files, mỗi file `.path` được xử lý qua `_handleShare`
- Reference: `lib/features/share_intent/share_intent_handler.dart:28-34`

### REQ-3: Trích xuất URL từ nội dung share
Nội dung share có thể là URL trực tiếp hoặc text chứa URL.

**Scenario: URL trực tiếp**
- Given: Nội dung share là `https://reddit.com/r/flutter/post123`
- When: Gọi `_extractUrl(content)`
- Then: Trả về `https://reddit.com/r/flutter/post123`
- Reference: `lib/features/share_intent/share_intent_handler.dart:51-54`

**Scenario: Text chứa URL**
- Given: Nội dung share là `"Check this out: https://youtube.com/watch?v=abc"`
- When: Gọi `_extractUrl(content)`
- Then: Trả về `https://youtube.com/watch?v=abc` (URL đầu tiên tìm được)
- Reference: `lib/features/share_intent/share_intent_handler.dart:57-62`

**Scenario: Nội dung rỗng hoặc không có URL**
- Given: Nội dung share là `"Hello world"` hoặc `""`
- When: Gọi `_extractUrl(content)`
- Then: Trả về `null`
- Reference: `lib/features/share_intent/share_intent_handler.dart:48-50`

### REQ-4: Auto-save ngay sau khi nhận URL
Sau khi trích xuất URL, tự động gọi `QuickSaveService.quickSave(url)` — KHÔNG chờ user xác nhận.

**Scenario: Auto-save**
- Given: URL `https://reddit.com/r/flutter` được trích xuất thành công
- When: `_handleShare` xử lý
- Then: Gọi `_quickSaveService.quickSave(url)` ngay lập tức, đồng thời emit URL qua `_onShareController`
- Reference: `lib/features/share_intent/share_intent_handler.dart:37-42`

### REQ-5: Broadcast URL cho UI (Toast)
URL cũng được emit qua `Stream<String> get onShare` để UI hiển thị Toast.

**Scenario: UI nhận URL**
- Given: URL được trích xuất thành công
- When: `_handleShare` xử lý
- Then: URL được add vào `_onShareController`, `app.dart` lắng nghe stream và hiển thị QuickSaveToast
- Reference: `lib/features/share_intent/share_intent_handler.dart:40`, `lib/app.dart:46-52`

### REQ-6: Intent filter trong AndroidManifest
App đăng ký nhận `ACTION_SEND` với `text/plain` mime type.

**Scenario: Android nhận share intent**
- Given: User share text/plain từ bất kỳ app nào
- When: Chọn "Reclip" trong Share Sheet
- Then: Android gửi intent đến `.MainActivity` với action `android.intent.action.SEND`
- Reference: `android/app/src/main/AndroidManifest.xml:20-24`

### REQ-7: Xử lý lỗi stream
Lỗi từ `getMediaStream()` được log ra console, không crash app.

**Scenario: Stream error**
- Given: `getMediaStream()` throw error
- When: Error xảy ra
- Then: Log `[ShareIntent] Error receiving media stream: $error`, app vẫn chạy bình thường
- Reference: `lib/features/share_intent/share_intent_handler.dart:25-27`

### REQ-8: Cleanup resources
`dispose()` hủy subscription và đóng stream controller.

**Scenario: Dispose**
- Given: `ShareIntentHandler` đã init
- When: Gọi `handler.dispose()`
- Then: `_subscription` bị cancel, `_onShareController` bị close
- Reference: `lib/features/share_intent/share_intent_handler.dart:67-70`

## Cần làm rõ
- `ReceiveSharingIntent` version `^1.8.0` — API dùng `.getMediaStream()` và `.getInitialMedia()` trả về `List<SharedMediaFile>`. File `.path` chứa nội dung shared (text hoặc URL). Nếu share image, `.path` sẽ là đường dẫn file, không phải URL — hiện tại `_extractUrl` sẽ trả về `null` cho image share (không xử lý).
- Regex `r'https?://[^\s]+'` — chỉ match URL bắt đầu bằng `http://` hoặc `https://`. Nếu user share raw text không chứa URL, không có gì xảy ra (silent no-op).
- Provider `shareIntentHandlerProvider` trong `main.dart` tự động gọi `handler.init()` khi tạo — không cần gọi manual từ app.
