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

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TrendingService _trendingService = TrendingService();

  List<TrendingPost> _redditPosts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTrending();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _trendingService.dispose();
    super.dispose();
  }

  Future<void> _loadTrending() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reddit = await _trendingService.fetchRedditTrending();
      if (mounted) {
        setState(() {
          _redditPosts = reddit;
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
    // Check if already saved
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

    // Save new item
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.forum), text: 'Reddit'),
            Tab(icon: Icon(Icons.play_circle), text: 'YouTube'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Reddit tab
          _buildRedditTab(),
          // YouTube tab (placeholder)
          _buildPlaceholderTab('YouTube', Icons.play_circle),
        ],
      ),
    );
  }

  Widget _buildRedditTab() {
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

    if (_redditPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum, size: 48, color: Colors.grey.shade300),
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
        itemCount: _redditPosts.length,
        itemBuilder: (context, index) {
          final post = _redditPosts[index];
          return _buildTrendingCard(post);
        },
      ),
    );
  }

  Widget _buildTrendingCard(TrendingPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          if (post.thumbnailUrl != null)
            Image.network(
              post.thumbnailUrl!,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 160,
                  color: Colors.grey.shade100,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                height: 160,
                color: Colors.grey.shade100,
                child: Center(
                  child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4500).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        post.subreddit != null ? 'r/${post.subreddit}' : post.source,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFFF4500),
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
                        'u/${post.author}',
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
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String name, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            '$name trending coming soon',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Requires API key integration',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
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
}
