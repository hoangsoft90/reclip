import 'package:flutter/material.dart';
import 'package:reclip/core/constants/app_strings.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/core/constants/platforms.dart';
import 'package:reclip/features/item_detail/presentation/item_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  final AppDatabase db;

  const LibraryScreen({super.key, required this.db});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.libraryTitle),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: StreamBuilder<List<SavedItem>>(
        stream: widget.db.select(widget.db.savedItems).watch(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.libraryEmptyTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.libraryEmptySubtitle,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (_isGridView) {
            return _buildGrid(items);
          }
          return _buildList(items);
        },
      ),
    );
  }

  Widget _buildGrid(List<SavedItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildGridCard(item);
      },
    );
  }

  Widget _buildList(List<SavedItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildListTile(item);
      },
    );
  }

  Widget _buildGridCard(SavedItem item) {
    final platformInfo = PlatformInfo.info[item.platform] ?? PlatformInfo.info[PlatformEnum.other]!;
    final displayTitle = item.title ?? _extractDomain(item.canonicalUrl);

    return GestureDetector(
      onTap: () => _openDetail(item),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                color: platformInfo.color.withOpacity(0.1),
                child: Center(
                  child: Icon(
                    platformInfo.icon,
                    size: 40,
                    color: platformInfo.color.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        platformInfo.icon,
                        size: 12,
                        color: platformInfo.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        platformInfo.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(SavedItem item) {
    final platformInfo = PlatformInfo.info[item.platform] ?? PlatformInfo.info[PlatformEnum.other]!;
    final displayTitle = item.title ?? _extractDomain(item.canonicalUrl);

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: platformInfo.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          platformInfo.icon,
          color: platformInfo.color,
        ),
      ),
      title: Text(
        displayTitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(
            platformInfo.displayName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(item.savedAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
      trailing: item.isFavorite ? const Icon(Icons.star, size: 16, color: Colors.amber) : null,
      onTap: () => _openDetail(item),
    );
  }

  void _openDetail(SavedItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(item: item),
      ),
    );
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (_) {
      return url;
    }
  }

  String _formatDate(int epochMillis) {
    final date = DateTime.fromMillisecondsSinceEpoch(epochMillis);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
