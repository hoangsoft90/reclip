import 'metadata_result.dart';

abstract class PlatformAdapter {
  /// Per-adapter timeout — not shared across adapters.
  Duration get timeout;

  /// Fetch metadata. Must NEVER throw exceptions — catch all errors
  /// and return MetadataResult.failed() instead.
  Future<MetadataResult> fetch(String canonicalUrl);
}
