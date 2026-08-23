import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:reclip/core/database/database.dart';
import '../domain/platform_adapter.dart';
import '../domain/metadata_result.dart';

/// Generic OpenGraph fallback - used when platform-specific adapter fails.
/// Parses og:title, og:image, og:description from HTML.
class GenericOpenGraphAdapter implements PlatformAdapter {
  final Dio _dio;
  GenericOpenGraphAdapter(this._dio);

  @override
  Duration get timeout => const Duration(seconds: 5);

  @override
  Future<MetadataResult> fetch(String canonicalUrl) async {
    try {
      final response = await _dio.get(
        canonicalUrl,
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
          headers: {'User-Agent': 'Mozilla/5.0 (compatible; Reclip/1.0)'},
        ),
      );
      final document = html_parser.parse(response.data);
      final title = _metaContent(document, 'og:title') ??
          document.querySelector('title')?.text;
      final image = _metaContent(document, 'og:image');
      final description = _metaContent(document, 'og:description');

      if (title == null && image == null) {
        return MetadataResult.failed('no_og_tags_found');
      }
      return MetadataResult(
        status: (title != null && image != null)
            ? MetadataStatusEnum.success
            : MetadataStatusEnum.partial,
        title: title,
        thumbnailUrl: image,
        description: description,
      );
    } catch (e) {
      return MetadataResult.failed('opengraph_fetch_error: $e');
    }
  }

  String? _metaContent(dynamic doc, String property) {
    return doc
        .querySelector('meta[property="$property"]')
        ?.attributes['content'];
  }
}
