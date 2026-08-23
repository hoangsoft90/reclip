import 'package:dio/dio.dart';
import 'package:reclip/core/database/database.dart';
import '../domain/platform_adapter.dart';
import '../domain/metadata_result.dart';

class RedditAdapter implements PlatformAdapter {
  final Dio _dio;
  RedditAdapter(this._dio);

  @override
  Duration get timeout => const Duration(seconds: 6);

  @override
  Future<MetadataResult> fetch(String canonicalUrl) async {
    try {
      final jsonUrl = _toJsonUrl(canonicalUrl);
      final response = await _dio.get(
        jsonUrl,
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
          headers: {'User-Agent': 'Reclip/1.0 (Android; personal use)'},
        ),
      );
      final data = response.data;
      if (data is! List || data.isEmpty) {
        return MetadataResult.failed('reddit_empty_response');
      }
      final listing = data[0];
      if (listing is! Map) return MetadataResult.failed('reddit_invalid_format');
      final dataMap = listing['data'];
      if (dataMap is! Map) return MetadataResult.failed('reddit_no_data');
      final children = dataMap['children'];
      if (children is! List || children.isEmpty) {
        return MetadataResult.failed('reddit_no_children');
      }
      final postData = children[0]['data'];
      if (postData is! Map) return MetadataResult.failed('reddit_no_post_data');

      return MetadataResult(
        status: MetadataStatusEnum.success,
        title: postData['title'] as String?,
        author: postData['author'] as String?,
        thumbnailUrl: _extractThumbnail(postData),
        contentType: _detectContentType(postData),
      );
    } catch (e) {
      return MetadataResult.failed('reddit_fetch_error: $e');
    }
  }

  String _toJsonUrl(String url) {
    final clean = url.split('?').first;
    return '${clean.endsWith('/') ? clean.substring(0, clean.length - 1) : clean}.json';
  }

  String? _extractThumbnail(Map postData) {
    final thumb = postData['thumbnail'] as String?;
    if (thumb == null || thumb == 'self' || thumb == 'default') return null;
    if (thumb.startsWith('http')) return thumb;
    return null;
  }

  ContentTypeEnum _detectContentType(Map postData) {
    if (postData['is_video'] == true) return ContentTypeEnum.video;
    if (postData['is_gallery'] == true) return ContentTypeEnum.gallery;
    if (postData['post_hint'] == 'image') return ContentTypeEnum.image;
    return ContentTypeEnum.text;
  }
}
