import '../constants/platforms.dart';

class PlatformDetector {
  static PlatformEnum detect(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return PlatformEnum.other;
    final host = uri.host.toLowerCase();

    if (_matchesAny(host, [
      'reddit.com', 'www.reddit.com', 'redd.it', 'v.redd.it',
    ])) return PlatformEnum.reddit;

    if (_matchesAny(host, [
      'instagram.com', 'www.instagram.com', 'instagr.am',
    ])) return PlatformEnum.instagram;

    if (_matchesAny(host, [
      'tiktok.com', 'www.tiktok.com', 'vt.tiktok.com', 'vm.tiktok.com',
    ])) return PlatformEnum.tiktok;

    if (_matchesAny(host, [
      'youtube.com', 'www.youtube.com', 'youtu.be', 'm.youtube.com',
    ])) return PlatformEnum.youtube;

    if (_matchesAny(host, [
      'twitter.com', 'x.com', 'www.x.com', 'www.twitter.com', 't.co',
    ])) return PlatformEnum.x;

    return PlatformEnum.other;
  }

  static bool _matchesAny(String host, List<String> domains) {
    return domains.any((d) => host == d || host.endsWith('.$d'));
  }
}
