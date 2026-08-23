class UrlNormalizer {
  static const _trackingParams = {
    'utm_source',
    'utm_medium',
    'utm_campaign',
    'utm_content',
    'utm_term',
    'igsh',
    'igshid',
    'fbclid',
    'gclid',
    'si',
    'ref',
    'ref_src',
    'ref_url',
    's',
    't',
    'feature',
  };

  static int _defaultPort(String scheme) {
    if (scheme == 'https') return 443;
    return 80; // http
  }

  static String canonicalize(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return trimmed;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.host.isEmpty) return trimmed;

    final cleanParams = Map<String, String>.from(uri.queryParameters)
      ..removeWhere((key, _) => _trackingParams.contains(key.toLowerCase()));

    // Build URL string manually to avoid Uri.toString() appending '#' for empty fragment
    final buf = StringBuffer()
      ..write(uri.scheme)
      ..write('://')
      ..write(uri.host);
    if (uri.hasPort && uri.port != _defaultPort(uri.scheme)) {
      buf.write(':${uri.port}');
    }
    buf.write(uri.path);
    if (cleanParams.isNotEmpty) {
      final qs = cleanParams.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      buf.write('?$qs');
    }
    // No fragment — intentionally omitted

    // Remove trailing slash
    var result = buf.toString();
    if (result.endsWith('/') && result.length > 1) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }
}
