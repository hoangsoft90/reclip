import 'package:dio/dio.dart';

/// Shared Dio instance for all metadata adapters.
/// Each adapter applies its own timeout via Options.
class HttpClient {
  static final Dio instance = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'text/html,application/xhtml+xml,application/json',
      },
    ),
  );
}
