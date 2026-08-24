import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:reclip/core/constants/app_strings.dart';
import 'package:reclip/core/constants/platforms.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/features/item_detail/application/open_original_service.dart';
import 'package:reclip/features/item_detail/presentation/edit_note_why_sheet.dart';
import 'package:reclip/features/smart_save/presentation/smart_save_bottom_sheet.dart';

class ItemDetailScreen extends StatefulWidget {
  final SavedItem item;
  final AppDatabase db;

  const ItemDetailScreen({super.key, required this.item, required this.db});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late SavedItem _item;
  List<Collection> _collections = [];
  List<Tag> _tags = [];

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _loadCollectionsAndTags();
  }

  Future<void> _loadCollectionsAndTags() async {
    final collections = await widget.db.getCollectionsForItem(_item.id);
    final tags = await widget.db.getTagsForItem(_item.id);
    if (mounted) {
      setState(() {
        _collections = collections;
        _tags = tags;
      });
    }
  }

  Future<void> _reloadItem() async {
    final fresh = await widget.db.getSavedItemById(_item.id);
    if (fresh != null && mounted) {
      setState(() => _item = fresh);
    }
  }

  @override
  Widget build(BuildContext context) {
    final platformInfo =
        PlatformInfo.info[_item.platform] ?? PlatformInfo.info[PlatformEnum.other]!;
    final displayTitle = _item.title ?? _extractDomain(_item.canonicalUrl);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          widget.db.touchLastAccessed(_item.id);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(platformInfo.displayName),
          actions: [
            IconButton(
              icon: Icon(
                _item.isFavorite ? Icons.star : Icons.star_border,
                color: _item.isFavorite ? Colors.amber : null,
              ),
              onPressed: () async {
                await widget.db.updateSavedItem(
                  id: _item.id,
                  isFavorite: !_item.isFavorite,
                );
                await _reloadItem();
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleMenuAction(value),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit_note',
                  child: Row(
                    children: [
                      Icon(Icons.edit_note, color: Colors.grey.shade700, size: 20),
                      const SizedBox(width: 12),
                      const Text('Edit note'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit_details',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.grey.shade700, size: 20),
                      const SizedBox(width: 12),
                      const Text('Add details'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(
                        _item.isArchived ? Icons.unarchive : Icons.archive,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(_item.isArchived ? 'Unarchive' : 'Archive'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                      const SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: Colors.red.shade400)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail — tries local file first, falls back to network
              _buildThumbnail(platformInfo),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Platform info + save date
                    Row(
                      children: [
                        Icon(platformInfo.icon, size: 16, color: platformInfo.color),
                        const SizedBox(width: 6),
                        Text(
                          platformInfo.displayName,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Saved ${_formatDate(_item.savedAt)}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Content type badge
                    if (_item.contentType != ContentTypeEnum.unknown)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_contentTypeIcon(_item.contentType), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                _item.contentType.name.toUpperCase(),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Author
                    if (_item.author != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _item.author!,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    // Video badge
                    if (_item.contentType == ContentTypeEnum.video)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.videocam_off, size: 14, color: Colors.orange),
                            SizedBox(width: 6),
                            Text(
                              AppStrings.badgeVideoUnavailableOffline,
                              style: TextStyle(fontSize: 12, color: Colors.orange),
                            ),
                          ],
                        ),
                      ),
                    // Online badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_off, size: 14, color: Colors.orange),
                          SizedBox(width: 6),
                          Text(
                            AppStrings.badgeOnlineToView,
                            style: TextStyle(fontSize: 12, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description
                    if (_item.description != null && _item.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _item.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    // Collections chips
                    _buildCollectionsSection(),
                    const SizedBox(height: 8),
                    // Tags chips
                    _buildTagsSection(),
                    const SizedBox(height: 16),
                    // Note + Why — show when data exists
                    if ((_item.note != null && _item.note!.isNotEmpty) ||
                        _item.whySaved != null)
                      GestureDetector(
                        onTap: () async {
                          await _showEditNoteWhySheet();
                          await _reloadItem();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Spacer(),
                                  Icon(Icons.edit, size: 16, color: Colors.blue.shade600),
                                ],
                              ),
                              if (_item.note != null && _item.note!.isNotEmpty)
                                Text(
                                  _item.note!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade800,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              if (_item.whySaved != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Chip(
                                    label: Text(
                                      AppStrings.whySavedOptions[_item.whySaved] ?? _item.whySaved!,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: Colors.purple.shade50,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    // Edit note/why button (when empty)
                    if (_item.note == null &&
                        (_item.note == null || _item.note!.isEmpty) &&
                        _item.whySaved == null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _showEditNoteWhySheet();
                            await _reloadItem();
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Add note or why'),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Open Original button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final service = OpenOriginalService();
                          final opened = await service.open(_item);
                          if (!opened && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(AppStrings.openOriginalFailedSnackbar),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text(AppStrings.openOriginalButton),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Smart Save (Add details)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => SmartSaveBottomSheet(item: _item, db: widget.db),
                          );
                          await _reloadItem();
                          await _loadCollectionsAndTags();
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text(AppStrings.addDetailsAction),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Thumbnail: local file → network URL → placeholder ──

  Widget _buildThumbnail(PlatformInfo platformInfo) {
    return FutureBuilder<Thumbnail?>(
      future: widget.db.findThumbnailByItemId(_item.id),
      builder: (context, snapshot) {
        final thumb = snapshot.data;

        // 1. Try local file
        if (thumb != null &&
            thumb.localPath != null &&
            thumb.downloadStatus == DownloadStatusEnum.done) {
          return Image.file(
            io.File(thumb.localPath!),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildThumbnailPlaceholder(platformInfo),
          );
        }

        // 2. Try network URL
        if (thumb != null && thumb.remoteUrl != null && thumb.remoteUrl!.isNotEmpty) {
          return Image.network(
            thumb.remoteUrl!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                width: double.infinity,
                height: 200,
                color: platformInfo.color.withOpacity(0.05),
                child: Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: platformInfo.color,
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => _buildThumbnailPlaceholder(platformInfo),
          );
        }

        // 3. Placeholder
        return _buildThumbnailPlaceholder(platformInfo);
      },
    );
  }

  Widget _buildThumbnailPlaceholder(PlatformInfo platformInfo) {
    return Container(
      width: double.infinity,
      height: 200,
      color: platformInfo.color.withOpacity(0.1),
      child: Center(
        child: Icon(
          platformInfo.icon,
          size: 64,
          color: platformInfo.color.withOpacity(0.5),
        ),
      ),
    );
  }

  // ── Collections Section ──

  Widget _buildCollectionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.folder_outlined, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              AppStrings.collectionLabel,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _showAddCollectionSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: Colors.blue.shade600),
                    const SizedBox(width: 4),
                    Text('Add', style: TextStyle(fontSize: 12, color: Colors.blue.shade600)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (_collections.isEmpty)
          Text(
            'No collections yet',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _collections.map((c) {
              return Chip(
                label: Text(c.name, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () async {
                  await widget.db.removeCollectionFromItem(_item.id, c.id);
                  await _loadCollectionsAndTags();
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  // ── Tags Section ──

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tag, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              AppStrings.tagsLabel,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _showAddTagDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: Colors.green.shade600),
                    const SizedBox(width: 4),
                    Text('Add', style: TextStyle(fontSize: 12, color: Colors.green.shade600)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (_tags.isEmpty)
          Text(
            'No tags yet',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _tags.map((t) {
              return Chip(
                label: Text('#${t.name}', style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () async {
                  await widget.db.removeTagFromItem(_item.id, t.id);
                  await _loadCollectionsAndTags();
                },
                backgroundColor: Colors.green.shade50,
              );
            }).toList(),
          ),
      ],
    );
  }

  // ── Add Collection Bottom Sheet ──

  Future<void> _showAddCollectionSheet() async {
    final allCollections = await widget.db.getAllCollections();
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final existingIds = _collections.map((c) => c.id).toSet();
        final available = allCollections.where((c) => !existingIds.contains(c.id)).toList();

        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.7,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Add to Collection',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: available.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.folder_off, size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                Text(
                                  'No collections available.\nCreate one from the main menu.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: available.length,
                            itemBuilder: (context, index) {
                              final c = available[index];
                              return ListTile(
                                leading: Icon(Icons.folder, color: Colors.grey.shade600),
                                title: Text(c.name),
                                onTap: () async {
                                  await widget.db.addToCollection(_item.id, c.id);
                                  await _loadCollectionsAndTags();
                                  if (mounted) Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Add Tag Dialog ──

  Future<void> _showAddTagDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Tag name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) Navigator.pop(context, value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      final tag = await widget.db.getOrCreateTag(result);
      // Check if already on this item
      final existing = _tags.any((t) => t.id == tag.id);
      if (!existing) {
        await widget.db.addTagToItem(_item.id, tag.id);
        await _loadCollectionsAndTags();
      }
    }
  }

  // ── Menu actions ──

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'edit_note':
        await _showEditNoteWhySheet();
        await _reloadItem();
        break;
      case 'edit_details':
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => SmartSaveBottomSheet(item: _item, db: widget.db),
        );
        await _reloadItem();
        await _loadCollectionsAndTags();
        break;
      case 'archive':
        await widget.db.updateSavedItem(
          id: _item.id,
          isArchived: !_item.isArchived,
        );
        await _reloadItem();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_item.isArchived ? 'Unarchived' : 'Archived'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete this item?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await widget.db.deleteItem(_item.id);
          if (mounted) Navigator.pop(context);
        }
        break;
    }
  }

  // ── Helpers ──

  Future<void> _showEditNoteWhySheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditNoteWhySheet(item: _item, db: widget.db),
    );
  }

  IconData _contentTypeIcon(ContentTypeEnum type) {
    switch (type) {
      case ContentTypeEnum.video:
        return Icons.videocam;
      case ContentTypeEnum.image:
        return Icons.image;
      case ContentTypeEnum.text:
        return Icons.article;
      case ContentTypeEnum.gallery:
        return Icons.collections;
      case ContentTypeEnum.link:
        return Icons.link;
      case ContentTypeEnum.mixed:
        return Icons.dashboard;
      case ContentTypeEnum.unknown:
        return Icons.help_outline;
    }
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
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
