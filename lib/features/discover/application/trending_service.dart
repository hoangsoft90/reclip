import 'dart:convert';
import 'package:http/http.dart' as http;

/// A trending post from a platform.
class TrendingPost {
  final String title;
  final String url;
  final String? thumbnailUrl;
  final String source; // e.g. "Reddit", "YouTube"
  final String? author;
  final int? score; // upvotes, views, etc.
  final String? subreddit; // Reddit-specific

  const TrendingPost({
    required this.title,
    required this.url,
    this.thumbnailUrl,
    required this.source,
    this.author,
    this.score,
    this.subreddit,
  });
}

/// Fetches trending content from various platforms.
/// Uses public APIs where available (Reddit).
class TrendingService {
  final http.Client _client;

  TrendingService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch trending posts from Reddit (public JSON API, no auth).
  Future<List<TrendingPost>> fetchRedditTrending({String subreddit = 'all'}) async {
    try {
      final uri = Uri.parse(
        'https://www.reddit.com/r/$subreddit/hot.json?limit=20&raw_json=1',
      );
      final response = await _client.get(
        uri,
        headers: {'User-Agent': 'Reclip/1.0 (Android)'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final children = (data['data']?['children'] as List?) ?? [];

      return children
          .where((c) => c['kind'] == 't3')
          .map((c) {
            final post = c['data'] as Map<String, dynamic>;
            final thumbnail = post['thumbnail'] as String?;
            final isExternal = post['is_self'] == false;

            return TrendingPost(
              title: post['title'] ?? '',
              url: isExternal
                  ? (post['url'] as String? ?? '')
                  : 'https://reddit.com${post['permalink'] ?? ''}',
              thumbnailUrl: thumbnail != null && thumbnail.startsWith('http')
                  ? thumbnail
                  : null,
              source: 'Reddit',
              author: post['author'],
              score: post['score'],
              subreddit: post['subreddit'],
            );
          })
          .where((p) => p.url.isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Placeholder for YouTube trending (requires API key).
  Future<List<TrendingPost>> fetchYouTubeTrending() async {
    // TODO: Integrate YouTube Data API v3 when API key is available
    return [];
  }

  /// Placeholder for TikTok trending (no public API).
  Future<List<TrendingPost>> fetchTikTokTrending() async {
    // TODO: Integrate when TikTok API is available
    return [];
  }

  /// Fetch trending from all available sources.
  Future<List<TrendingPost>> fetchAllTrending() async {
    final reddit = await fetchRedditTrending();
    return reddit; // Add more sources as APIs become available
  }

  void dispose() {
    _client.close();
  }
}
