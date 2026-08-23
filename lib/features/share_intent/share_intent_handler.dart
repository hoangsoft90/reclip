import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'quick_save_service.dart';

class ShareIntentHandler {
  final QuickSaveService _quickSaveService;
  StreamSubscription<List<SharedMediaFile>>? _subscription;

  final _onShareController = StreamController<String>.broadcast();
  Stream<String> get onShare => _onShareController.stream;

  ShareIntentHandler(this._quickSaveService);

  void init() {
    // Listen to sharing media (when app is already running)
    _subscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> files) {
        for (final file in files) {
          _handleShare(file.path);
        }
      },
      onError: (err) {
        print('[ShareIntent] Error receiving media stream: $err');
      },
    );

    // Check if app was opened via share intent
    ReceiveSharingIntent.instance.getInitialMedia().then(
      (List<SharedMediaFile> files) {
        for (final file in files) {
          _handleShare(file.path);
        }
      },
    );
  }

  void _handleShare(String rawContent) {
    // Extract URL from shared content
    final url = _extractUrl(rawContent);
    if (url != null) {
      _onShareController.add(url);
      // Auto-save immediately
      _quickSaveService.quickSave(url);
    }
  }

  String? _extractUrl(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return null;

    // Check if it's a direct URL
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    // Try to find URL in text content
    final urlRegex = RegExp(r'https?://[^\s]+');
    final match = urlRegex.firstMatch(trimmed);
    if (match != null) {
      return match.group(0);
    }

    return null;
  }

  void dispose() {
    _subscription?.cancel();
    _onShareController.close();
  }
}
