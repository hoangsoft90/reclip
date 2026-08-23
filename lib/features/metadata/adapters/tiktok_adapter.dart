import 'package:dio/dio.dart';
import 'package:reclip/core/database/database.dart';
import '../domain/platform_adapter.dart';
import '../domain/metadata_result.dart';

/// TikTok adapter - best-effort, fails fast (4s timeout).
class TikTokAdapter implements PlatformAdapter {
  final Dio _dio;
  TikTokAdapter(this._dio);

  @override
  Duration get timeout => const Duration(seconds: 4);

  @override
  Future<MetadataResult> fetch(String canonicalUrl) async {
    try {
      final response = await _dio.get(
        canonicalUrl,
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36',
          },
        ),
      );
      final body = response.data.toString();
      final title = _extractMeta(body, 'og:title') ?? _extractTitleTag(body);
      final description = _extractMeta(body, 'og:description');
      final image = _extractMeta(body, 'og:image');
      if (title == null && image == null) {
        return MetadataResult.failed('tiktok_no_metadata');
      }
      return MetadataResult(
        status: (title != null && image != null)
            ? MetadataStatusEnum.success
            : MetadataStatusEnum.partial,
        title: title,
        description: description,
        thumbnailUrl: image,
        contentType: ContentTypeEnum.video,
      );
    } catch (e) {
      return MetadataResult.failed('tiktok_fetch_error: $e');
    }
  }

  String? _extractMeta(String body, String property) {
    final name = RegExp.escape(property);
    final regex1 = RegExp(
      '<meta[ 	]+[^>]*property=["\']' + name + '["\'][^>]*content=["\']([^"\']*)["\']',
      caseSensitive: false,
    );
    final m1 = regex1.firstMatch(body);
    if (m1 != null) return m1.group(1);
    final regex2 = RegExp(
      '<meta[ 	]+[^>]*content=["\']([^"\']*)["\'][^>]*property=["\']' + name + '["\']',
      caseSensitive: false,
    );
    return regex2.firstMatch(body)?.group(1);
  }

  String? _extractTitleTag(String body) {
    final match =
        RegExp(r'<title[^>]*>(.*?)</title>', dotAll: true).firstMatch(body);
    return match?.group(1)?.trim();
  }
}
