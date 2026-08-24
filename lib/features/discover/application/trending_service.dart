import 'dart:convert';
import 'package:http/http.dart' as http;

/// A trending post from a platform.
class TrendingPost {
  final String title;
  final String url;
  final String? thumbnailUrl;
  final String source;
  final String? author;
  final int? score;
  final String? subreddit;

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

/// Fetches trending content from platforms with public APIs.
class TrendingService {
  final http.Client _client;

  TrendingService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch top stories from Hacker News (public Firebase API, no auth).
  Future<List<TrendingPost>> fetchHackerNewsTrending() async {
    try {
      // Get top story IDs
      final idsResponse = await _client
          .get(Uri.parse('https://hacker-news.firebaseio.com/v0/topstories.json'))
          .timeout(const Duration(seconds: 10));

      if (idsResponse.statusCode != 200) return [];

      final ids = (jsonDecode(idsResponse.body) as List).cast<int>();
      final topIds = ids.take(20).toList();

      // Fetch each story in parallel
      final futures = topIds.map((id) => _fetchHnStory(id));
      final results = await Future.wait(futures);
      return results.whereType<TrendingPost>().toList();
    } catch (e) {
      return [];
    }
  }

  Future<TrendingPost?> _fetchHnStory(int id) async {
    try {
      final response = await _client
          .get(Uri.parse('https://hacker-news.firebaseio.com/v0/item/$id.json'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return null;

      final story = jsonDecode(response.body) as Map<String, dynamic>;
      final title = story['title'] as String? ?? '';
      final url = story['url'] as String? ?? '';
      final by = story['by'] as String?;
      final score = story['score'] as int?;

      if (title.isEmpty) return null;

      // HN stories without URL link to HN discussion
      final storyUrl = url.isNotEmpty ? url : 'https://news.ycombinator.com/item?id=$id';

      return TrendingPost(
        title: title,
        url: storyUrl,
        source: 'Hacker News',
        author: by,
        score: score,
      );
    } catch (_) {
      return null;
    }
  }

  /// Fetch trending from all available sources.
  Future<List<TrendingPost>> fetchAllTrending() async {
    return fetchHackerNewsTrending();
  }

  void dispose() {
    _client.close();
  }
}
