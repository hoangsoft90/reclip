import 'package:flutter/material.dart';
import 'package:reclip/core/constants/app_strings.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/core/constants/platforms.dart';
import 'package:reclip/core/network/connectivity_service.dart';
import 'package:reclip/features/item_detail/presentation/item_detail_screen.dart';
import 'package:reclip/features/library/presentation/widgets/quick_link_card.dart';
import 'package:reclip/features/library/presentation/widgets/offline_banner.dart';
import 'package:reclip/features/library/presentation/widgets/facet_filter_bar.dart';
import 'package:reclip/features/library/application/facet_filter_controller.dart';

class LibraryScreen extends StatefulWidget {
  final AppDatabase db;

  const LibraryScreen({super.key, required this.db});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _isGridView = true;
  final _filterController = FacetFilterController();
  final _connectivityService = ConnectivityService();
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _connectivityService.onlineStatusStream.listen((online) {
      if (mounted) setState(() => _isOnline = online);
    });
    _connectivityService.isOnline.then((online) {
      if (mounted) setState(() => _isOnline = online);
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

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
      body: Column(
        children: [
          // Offline banner
          if (!_isOnline) const OfflineBanner(),
          // Filter bar
          FacetFilterBar(controller: _filterController),
          // Items
          Expanded(
            child: StreamBuilder<List<SavedItem>>(
              stream: widget.db.select(widget.db.savedItems).watch(),
              builder: (context, snapshot) {
                final allItems = snapshot.data ?? [];
                final items = _filterController.applyFilter(allItems);

                if (allItems.isEmpty) {
                  return _buildEmptyState();
                }
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No items match filter',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  );
                }

                if (_isGridView) {
                  return _buildGrid(items);
                }
                return _buildList(items);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            AppStrings.libraryEmptyTitle,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
        final isPending = item.metadataStatus == MetadataStatusEnum.pending;
        final isFailed = item.metadataStatus == MetadataStatusEnum.failed;

        if (isPending || isFailed) {
          return QuickLinkCard(
            item: item,
            onTap: () => _openDetail(item),
            onEditTitle: () => _showEditTitleDialog(item),
          );
        }
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
        final isPending = item.metadataStatus == MetadataStatusEnum.pending;
        final isFailed = item.metadataStatus == MetadataStatusEnum.failed;

        if (isPending || isFailed) {
          return QuickLinkCard(
            item: item,
            onTap: () => _openDetail(item),
            onEditTitle: () => _showEditTitleDialog(item),
          );
        }
        return _buildListTile(item);
      },
    );
  }

  Widget _buildGridCard(SavedItem item) {
    final platformInfo =
        PlatformInfo.info[item.platform] ?? PlatformInfo.info[PlatformEnum.other]!;
    final displayTitle = item.title ?? _extractDomain(item.canonicalUrl);

    return GestureDetector(
      onTap: () => _openDetail(item),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with CachedNetworkImage
            Expanded(
              child: _buildThumbnail(item, platformInfo),
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
                      Icon(platformInfo.icon, size: 12, color: platformInfo.color),
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
    final platformInfo =
        PlatformInfo.info[item.platform] ?? PlatformInfo.info[PlatformEnum.other]!;
    final displayTitle = item.title ?? _extractDomain(item.canonicalUrl);

    return ListTile(
      leading: _buildThumbnailSmall(item, platformInfo),
      title: Text(
        displayTitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(
            platformInfo.displayName,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(item.savedAt),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
      trailing: item.isFavorite
          ? const Icon(Icons.star, size: 16, color: Colors.amber)
          : null,
      onTap: () => _openDetail(item),
    );
  }

  Widget _buildThumbnail(SavedItem item, PlatformInfo platformInfo) {
    final thumbnail = _getThumbnailLocalPath(item);
    if (thumbnail != null) {
      return Image.asset(
        thumbnail,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildThumbnailPlaceholder(platformInfo),
      );
    }
    return _buildThumbnailPlaceholder(platformInfo);
  }

  Widget _buildThumbnailSmall(SavedItem item, PlatformInfo platformInfo) {
    final thumbnail = _getThumbnailLocalPath(item);
    if (thumbnail != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          thumbnail,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildThumbnailPlaceholderSmall(platformInfo),
        ),
      );
    }
    return _buildThumbnailPlaceholderSmall(platformInfo);
  }

  Widget _buildThumbnailPlaceholder(PlatformInfo platformInfo) {
    return Container(
      width: double.infinity,
      color: platformInfo.color.withOpacity(0.1),
      child: Center(
        child: Icon(
          platformInfo.icon,
          size: 40,
          color: platformInfo.color.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholderSmall(PlatformInfo platformInfo) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: platformInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(platformInfo.icon, color: platformInfo.color),
    );
  }

  String? _getThumbnailLocalPath(SavedItem item) {
    // Will be populated from thumbnails table in real app
    // For now, return null (placeholder icons shown)
    return null;
  }

  void _openDetail(SavedItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
    );
  }

  void _showEditTitleDialog(SavedItem item) {
    final controller = TextEditingController(text: item.title ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.editTitleAction),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: AppStrings.editTitleHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.editTitleCancel),
          ),
          TextButton(
            onPressed: () async {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                await widget.db.updateSavedItem(id: item.id, title: title);
              }
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text(AppStrings.editTitleSave),
          ),
        ],
      ),
    );
  }

  String _extractDomain(String url) {
    try {
      return Uri.parse(url).host;
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
