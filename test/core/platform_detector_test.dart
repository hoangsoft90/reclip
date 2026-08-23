import 'package:flutter_test/flutter_test.dart';
import 'package:reclip/core/constants/platforms.dart';
import 'package:reclip/core/url/platform_detector.dart';

void main() {
  group('PlatformDetector.detect', () {
    test('reddit.com → reddit', () {
      expect(
        PlatformDetector.detect('https://www.reddit.com/r/flutter/comments/abc'),
        PlatformEnum.reddit,
      );
    });

    test('redd.it (short link) → reddit', () {
      expect(
        PlatformDetector.detect('https://redd.it/abc123'),
        PlatformEnum.reddit,
      );
    });

    test('v.redd.it → reddit', () {
      expect(
        PlatformDetector.detect('https://v.redd.it/abc123/video.mp4'),
        PlatformEnum.reddit,
      );
    });

    test('instagram.com/p/xxx → instagram', () {
      expect(
        PlatformDetector.detect('https://www.instagram.com/p/ABC123/'),
        PlatformEnum.instagram,
      );
    });

    test('instagr.am → instagram', () {
      expect(
        PlatformDetector.detect('https://instagr.am/p/ABC123/'),
        PlatformEnum.instagram,
      );
    });

    test('vt.tiktok.com (short link) → tiktok', () {
      expect(
        PlatformDetector.detect('https://vt.tiktok.com/ZSabcdef/'),
        PlatformEnum.tiktok,
      );
    });

    test('youtu.be (short link) → youtube', () {
      expect(
        PlatformDetector.detect('https://youtu.be/dQw4w9WgXcQ'),
        PlatformEnum.youtube,
      );
    });

    test('x.com và twitter.com đều → x', () {
      expect(
        PlatformDetector.detect('https://x.com/user/status/123'),
        PlatformEnum.x,
      );
      expect(
        PlatformDetector.detect('https://twitter.com/user/status/123'),
        PlatformEnum.x,
      );
      expect(
        PlatformDetector.detect('https://www.twitter.com/user/status/123'),
        PlatformEnum.x,
      );
    });

    test('domain lạ hoàn toàn → other, KHÔNG throw exception', () {
      expect(
        PlatformDetector.detect('https://example.com/page'),
        PlatformEnum.other,
      );
    });

    test('URL không hợp lệ → other, KHÔNG throw exception', () {
      expect(
        PlatformDetector.detect('not-a-url'),
        PlatformEnum.other,
      );
      expect(
        PlatformDetector.detect(''),
        PlatformEnum.other,
      );
    });

    test('vm.tiktok.com → tiktok', () {
      expect(
        PlatformDetector.detect('https://vm.tiktok.com/ZSabcdef/'),
        PlatformEnum.tiktok,
      );
    });

    test('m.youtube.com → youtube', () {
      expect(
        PlatformDetector.detect('https://m.youtube.com/watch?v=abc'),
        PlatformEnum.youtube,
      );
    });

    test('t.co (twitter short link) → x', () {
      expect(
        PlatformDetector.detect('https://t.co/abc123'),
        PlatformEnum.x,
      );
    });
  });
}
