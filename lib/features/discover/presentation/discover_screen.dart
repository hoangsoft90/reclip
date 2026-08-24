import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/core/url/url_normalizer.dart';
import 'package:reclip/core/url/platform_detector.dart';
import 'package:reclip/core/utils/id_generator.dart';
import 'package:reclip/features/discover/application/trending_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  final AppDatabase db;

  const DiscoverScreen({super.key, required this.db});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final TrendingService _trendingService = TrendingService();

  List<TrendingPost> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  @override
  void dispose() {
    _trendingService.dispose();
    super.dispose();
  }

  Future<void> _loadTrending() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final posts = await _trendingService.fetchHackerNewsTrending();
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load trending: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _savePost(TrendingPost post) async {
    final canonical = UrlNormalizer.canonicalize(post.url);
    final existing = await widget.db.findByCanonicalUrl(canonical);
    if (existing != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Already saved'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      return;
    }

    final id = IdGenerator.generate();
    final platform = PlatformDetector.detect(post.url);
    await widget.db.insertSavedItem(
      id: id,
      originalUrl: post.url,
      canonicalUrl: canonical,
      platform: platform,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved to Library ✓'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrending,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTrending,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No trending posts found',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrending,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(_posts[index]);
        },
      ),
    );
  }

  Widget _buildPostCard(TrendingPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source badge + score
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    post.source,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (post.score != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_upward, size: 14, color: Colors.grey.shade500),
                  Text(
                    _formatScore(post.score!),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
                if (post.author != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    'by ${post.author}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              post.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            // URL domain
            Text(
              _extractDomain(post.url),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openPost(post),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Open'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _savePost(post),
                    icon: const Icon(Icons.bookmark_add, size: 16),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPost(TrendingPost post) async {
    final uri = Uri.parse(post.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatScore(int score) {
    if (score >= 1000) return '${(score / 1000).toStringAsFixed(1)}k';
    return '$score';
  }

  String _extractDomain(String url) {
    try {
      return Uri.parse(url).host;
    } catch (_) {
      return url;
    }
  }
}
