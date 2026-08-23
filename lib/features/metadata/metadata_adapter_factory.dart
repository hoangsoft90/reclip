import 'package:dio/dio.dart';
import 'package:reclip/core/database/database.dart';
import 'domain/platform_adapter.dart';
import 'adapters/reddit_adapter.dart';
import 'adapters/youtube_adapter.dart';
import 'adapters/x_adapter.dart';
import 'adapters/tiktok_adapter.dart';
import 'adapters/instagram_adapter.dart';
import 'adapters/generic_opengraph_adapter.dart';

class MetadataAdapterFactory {
  final Dio _dio;
  late final Map<PlatformEnum, PlatformAdapter> _adapters;
  late final GenericOpenGraphAdapter _openGraphFallback;

  MetadataAdapterFactory(this._dio) {
    _openGraphFallback = GenericOpenGraphAdapter(_dio);
    _adapters = {
      PlatformEnum.reddit: RedditAdapter(_dio),
      PlatformEnum.youtube: YouTubeAdapter(_dio),
      PlatformEnum.x: XAdapter(_dio),
      PlatformEnum.tiktok: TikTokAdapter(_dio),
      PlatformEnum.instagram: InstagramAdapter(_dio),
    };
  }

  PlatformAdapter forPlatform(PlatformEnum platform) {
    return _adapters[platform] ?? _openGraphFallback;
  }

  PlatformAdapter get openGraphFallback => _openGraphFallback;
}
