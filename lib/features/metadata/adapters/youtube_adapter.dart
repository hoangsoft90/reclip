import 'package:dio/dio.dart';
import 'package:reclip/core/database/database.dart';
import '../domain/platform_adapter.dart';
import '../domain/metadata_result.dart';

/// YouTube adapter using oEmbed API (no API key needed).
class YouTubeAdapter implements PlatformAdapter {
  final Dio _dio;
  YouTubeAdapter(this._dio);

  @override
  Duration get timeout => const Duration(seconds: 6);

  @override
  Future<MetadataResult> fetch(String canonicalUrl) async {
    try {
      final oEmbedUrl = 'https://www.youtube.com/oembed?url=${Uri.encodeComponent(canonicalUrl)}&format=json';
      final response = await _dio.get(
        oEmbedUrl,
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );
      final data = response.data;
      if (data is! Map) return MetadataResult.failed('youtube_invalid_format');

      final title = data['title'] as String?;
      final authorName = data['author_name'] as String?;
      final authorUrl = data['author_url'] as String?;
      final thumbnailUrl = data['thumbnail_url'] as String?;

      if (title == null) return MetadataResult.failed('youtube_no_title');

      return MetadataResult(
        status: MetadataStatusEnum.success,
        title: title,
        author: authorName,
        authorUrl: authorUrl,
        thumbnailUrl: thumbnailUrl,
        contentType: ContentTypeEnum.video,
      );
    } catch (e) {
      return MetadataResult.failed('youtube_fetch_error: $e');
    }
  }
}
