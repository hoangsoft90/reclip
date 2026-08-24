import 'dart:io';
import 'package:flutter/material.dart';
import 'package:reclip/core/constants/platforms.dart';
import 'package:reclip/core/database/database.dart';

class ResurfaceCard extends StatelessWidget {
  final SavedItem item;
  final String? thumbnailPath;
  final VoidCallback onTap;

  const ResurfaceCard({
    super.key,
    required this.item,
    this.thumbnailPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final platformInfo = PlatformInfo.fromEnum(item.platform);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: platformInfo.color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: thumbnailPath != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.file(
                        File(thumbnailPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(platformInfo),
                      ),
                    )
                  : _buildPlaceholder(platformInfo),
            ),
            // Title + platform
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? item.originalUrl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(platformInfo.icon, size: 12, color: platformInfo.color),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          platformInfo.displayName,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          overflow: TextOverflow.ellipsis,
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

  Widget _buildPlaceholder(PlatformInfo platformInfo) {
    return Center(
      child: Icon(
        platformInfo.icon,
        size: 32,
        color: platformInfo.color.withOpacity(0.5),
      ),
    );
  }
}
