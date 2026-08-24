import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:reclip/core/constants/app_strings.dart';
import 'package:reclip/core/constants/platforms.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/features/item_detail/application/open_original_service.dart';
import 'package:reclip/features/item_detail/presentation/edit_note_why_sheet.dart';
import 'package:reclip/features/smart_save/presentation/smart_save_bottom_sheet.dart';

class ItemDetailScreen extends StatelessWidget {
  final SavedItem item;
  final AppDatabase db;

  const ItemDetailScreen({super.key, required this.item, required this.db});

  @override
  Widget build(BuildContext context) {
    final platformInfo =
        PlatformInfo.info[item.platform] ?? PlatformInfo.info[PlatformEnum.other]!;
    final displayTitle = item.title ?? _extractDomain(item.canonicalUrl);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Touch lastAccessed when leaving detail screen
        if (didPop) {
          db.touchLastAccessed(item.id);
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(platformInfo.displayName),
        actions: [
          IconButton(
            icon: Icon(
              item.isFavorite ? Icons.star : Icons.star_border,
              color: item.isFavorite ? Colors.amber : null,
            ),
            onPressed: () async {
              await db.updateSavedItem(
                id: item.id,
                isFavorite: !item.isFavorite,
              );
              // Don't pop — user expects to stay on detail screen
              // The Library screen will auto-refresh via StreamBuilder
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Options menu — Phase 3
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail / placeholder
            FutureBuilder<Thumbnail?>(
              future: db.findThumbnailByItemId(item.id),
              builder: (context, snapshot) {
                final thumb = snapshot.data;
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
                return _buildThumbnailPlaceholder(platformInfo);
              },
            ),
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
                  // Platform info + content type badge
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
                        'Saved ${_formatDate(item.savedAt)}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Content type badge
                  if (item.contentType != ContentTypeEnum.unknown)
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
                            Icon(_contentTypeIcon(item.contentType), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              item.contentType.name.toUpperCase(),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Author
                  if (item.author != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            item.author!,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  // Video badge
                  if (item.contentType == ContentTypeEnum.video)
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
                  if (item.description != null && item.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        item.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  // Note + Why + Edit button
                  if (item.note != null && item.note!.isNotEmpty ||
                      item.whySaved != null)
                    GestureDetector(
                      onTap: () => _showEditNoteWhySheet(context),
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
                            if (item.note != null && item.note!.isNotEmpty)
                              Text(
                                item.note!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade800,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            if (item.whySaved != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Chip(
                                  label: Text(
                                    AppStrings.whySavedOptions[item.whySaved] ?? item.whySaved!,
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
                  if (item.note == null && item.whySaved == null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditNoteWhySheet(context),
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
                        final opened = await service.open(item);
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
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => SmartSaveBottomSheet(item: item, db: db),
                        );
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

  void _showEditNoteWhySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditNoteWhySheet(item: item, db: db),
    );
  }
}
