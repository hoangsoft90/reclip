import 'package:reclip/core/database/database.dart';

/// Simple local event log for metadata success rates.
/// No analytics SDK — just prints to console for now.
class MetricsLogger {
  static final List<Map<String, dynamic>> _log = [];

  static void logEvent(String event, {Map<String, dynamic>? data}) {
    final entry = {
      'event': event,
      'timestamp': DateTime.now().toIso8601String(),
      ...?data,
    };
    _log.add(entry);
    // ignore: avoid_print
    print('[Metrics] $event ${data != null ? data : ''}');
  }

  static void logMetadataResult(PlatformEnum platform, MetadataStatusEnum status) {
    logEvent('metadata_result', data: {
      'platform': platform.name,
      'status': status.name,
    });
  }

  static List<Map<String, dynamic>> get allLogs => List.unmodifiable(_log);

  /// Calculate success rates per platform from logged data.
  static Map<String, Map<String, int>> getPlatformStats() {
    final stats = <String, Map<String, int>>{};
    for (final entry in _log) {
      if (entry['event'] == 'metadata_result') {
        final platform = entry['platform'] as String;
        final status = entry['status'] as String;
        stats.putIfAbsent(platform, () => {'success': 0, 'partial': 0, 'failed': 0});
        stats[platform]![status] = (stats[platform]![status] ?? 0) + 1;
      }
    }
    return stats;
  }
}
