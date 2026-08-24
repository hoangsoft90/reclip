import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'quick_save_service.dart';

class ShareIntentHandler {
  final QuickSaveService _quickSaveService;
  StreamSubscription<List<SharedMediaFile>>? _subscription;

  /// Emits SaveResult after each share intent (URL saved or duplicate)
  final _onSaveController = StreamController<SaveResult>.broadcast();
  Stream<SaveResult> get onSave => _onSaveController.stream;

  /// Queued result from cold start (before listener is attached)
  SaveResult? _pendingResult;

  ShareIntentHandler(this._quickSaveService);

  void init() {
    // Listen to sharing media (when app is already running — warm start)
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

    // Check if app was opened via share intent (cold start)
    ReceiveSharingIntent.instance.getInitialMedia().then(
      (List<SharedMediaFile> files) {
        for (final file in files) {
          _handleShare(file.path);
        }
      },
    );
  }

  /// Called by app.dart after setting up the listener.
  /// If there's a pending cold-start result, emit it now.
  void emitPendingIfAny() {
    if (_pendingResult != null) {
      final result = _pendingResult!;
      _pendingResult = null;
      // Use addPostFrameCallback to avoid calling listener during build
      Future.microtask(() => _onSaveController.add(result));
    }
  }

  void _handleShare(String rawContent) {
    // Extract URL from shared content
    final url = _extractUrl(rawContent);
    if (url != null) {
      // Auto-save and emit result (not just URL)
      _quickSaveService.quickSave(url).then((result) {
        if (_onSaveController.hasListener) {
          _onSaveController.add(result);
        } else {
          // Listener not ready yet (cold start) — queue it
          _pendingResult = result;
        }
      });
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
    _onSaveController.close();
  }
}
