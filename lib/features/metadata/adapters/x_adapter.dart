import 'package:dio/dio.dart';
import 'package:reclip/core/database/database.dart';
import '../domain/platform_adapter.dart';
import '../domain/metadata_result.dart';

/// X/Twitter adapter using oEmbed API (no API key needed).
class XAdapter implements PlatformAdapter {
  final Dio _dio;
  XAdapter(this._dio);

  @override
  Duration get timeout => const Duration(seconds: 6);

  @override
  Future<MetadataResult> fetch(String canonicalUrl) async {
    try {
      final oEmbedUrl = 'https://publish.twitter.com/oembed?url=${Uri.encodeComponent(canonicalUrl)}';
      final response = await _dio.get(
        oEmbedUrl,
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );
      final data = response.data;
      if (data is! Map) return MetadataResult.failed('x_invalid_format');

      final authorName = data['author_name'] as String?;
      final authorUrl = data['author_url'] as String?;
      // oEmbed HTML contains the tweet text — extract from <p> tag
      final html = data['html'] as String?;
      final title = _extractTitle(html);

      if (title == null) return MetadataResult.failed('x_no_title');

      return MetadataResult(
        status: MetadataStatusEnum.success,
        title: title,
        author: authorName,
        authorUrl: authorUrl,
        contentType: ContentTypeEnum.text,
      );
    } catch (e) {
      return MetadataResult.failed('x_fetch_error: $e');
    }
  }

  String? _extractTitle(String? html) {
    if (html == null || html.isEmpty) return null;
    // Extract text from <p> tag, strip HTML tags
    final pMatch = RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true).firstMatch(html);
    if (pMatch != null) {
      final text = pMatch.group(1) ?? '';
      // Strip any remaining HTML tags
      return text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    }
    return null;
  }
}
