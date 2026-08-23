import 'package:flutter_test/flutter_test.dart';
import 'package:reclip/core/url/url_normalizer.dart';

void main() {
  group('UrlNormalizer.canonicalize', () {
    test('loại bỏ utm_source, utm_medium, utm_campaign', () {
      final result = UrlNormalizer.canonicalize(
        'https://example.com/page?utm_source=twitter&utm_medium=social&utm_campaign=spring',
      );
      expect(result, 'https://example.com/page');
    });

    test('loại bỏ igsh param (Instagram share id)', () {
      final result = UrlNormalizer.canonicalize(
        'https://www.instagram.com/p/ABC123/?igshid=abc123',
      );
      expect(result, 'https://www.instagram.com/p/ABC123');
    });

    test('loại bỏ fbclid', () {
      final result = UrlNormalizer.canonicalize(
        'https://example.com/page?fbclid=abc123def456',
      );
      expect(result, 'https://example.com/page');
    });

    test('giữ nguyên query param không nằm trong danh sách tracking', () {
      final result = UrlNormalizer.canonicalize(
        'https://example.com/page?utm_source=fb&v=2&sort=new',
      );
      expect(result, 'https://example.com/page?v=2&sort=new');
    });

    test('loại bỏ fragment (#...)', () {
      final result = UrlNormalizer.canonicalize(
        'https://example.com/page#section1',
      );
      expect(result, 'https://example.com/page');
    });

    test('bỏ trailing slash nhưng giữ nguyên path gốc / nếu là root', () {
      final result1 = UrlNormalizer.canonicalize('https://example.com/page/');
      expect(result1, 'https://example.com/page');

      // Root path '/' should stay as '/'
      final result2 = UrlNormalizer.canonicalize('https://example.com/');
      expect(result2, 'https://example.com');
    });

    test('URL rỗng hoặc không parse được → trả lại nguyên input đã trim', () {
      final result1 = UrlNormalizer.canonicalize('   ');
      expect(result1, '');

      final result2 = UrlNormalizer.canonicalize('not-a-url');
      expect(result2, 'not-a-url');
    });

    test('URL có query params viết hoa (UTM_SOURCE) vẫn bị loại bỏ đúng', () {
      final result = UrlNormalizer.canonicalize(
        'https://example.com/page?UTM_SOURCE=google&UTM_MEDIUM=cpc',
      );
      expect(result, 'https://example.com/page');
    });

    test('giữ nguyên query param si và ref', () {
      // si and ref are in tracking params list
      final result = UrlNormalizer.canonicalize(
        'https://youtube.com/watch?v=abc123&si=xyz',
      );
      expect(result, 'https://youtube.com/watch?v=abc123');
    });

    test('xử lý URL có nhiều tracking param lẫn non-tracking param', () {
      final result = UrlNormalizer.canonicalize(
        'https://reddit.com/r/flutter?ref=sidebar&sort=top&t=week&feature=share',
      );
      // ref, t, feature are all tracking params → removed; sort stays
      expect(result, 'https://reddit.com/r/flutter?sort=top');
    });
  });
}
