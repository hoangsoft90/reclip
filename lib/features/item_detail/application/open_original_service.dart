import 'package:url_launcher/url_launcher.dart';
import 'package:reclip/core/database/database.dart';

class OpenOriginalService {
  Future<bool> open(SavedItem item) async {
    // Step 1: Try deep link to native app (Phase 1: returns null, always goes to Step 2)
    final deepLink = _buildDeepLink(item);
    if (deepLink != null) {
      final launched = await _tryLaunch(deepLink, mode: LaunchMode.externalApplication);
      if (launched) return true;
    }

    // Step 2: Fallback to browser
    final browserLaunched = await _tryLaunch(
      Uri.parse(item.originalUrl),
      mode: LaunchMode.externalApplication,
    );
    if (browserLaunched) return true;

    // Step 3: Both failed
    return false;
  }

  Uri? _buildDeepLink(SavedItem item) {
    // Phase 1: deep link scheme not implemented yet
    // _buildDeepLink returns null → always falls through to browser (Step 2)
    // This is ACCEPTED BEHAVIOR per technical brief section 8
    return null;
  }

  Future<bool> _tryLaunch(Uri uri, {required LaunchMode mode}) async {
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: mode);
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
