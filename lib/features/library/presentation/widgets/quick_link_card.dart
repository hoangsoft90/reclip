import 'package:flutter/material.dart';
import 'package:reclip/core/constants/app_strings.dart';
import 'package:reclip/core/constants/platforms.dart';
import 'package:reclip/core/database/database.dart';

/// Quick Link Card — displayed when metadata_status = failed/pending.
/// First-class UI, not an error state — consistent style with full cards.
class QuickLinkCard extends StatelessWidget {
  final SavedItem item;
  final VoidCallback? onTap;
  final VoidCallback? onEditTitle;

  const QuickLinkCard({
    super.key,
    required this.item,
    this.onTap,
    this.onEditTitle,
  });

  @override
  Widget build(BuildContext context) {
    final platformInfo =
        PlatformInfo.info[item.platform] ?? PlatformInfo.info[PlatformEnum.other]!;
    final domain = _extractDomain(item.canonicalUrl);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon area (no thumbnail available)
            Container(
              width: double.infinity,
              height: 120,
              color: platformInfo.color.withOpacity(0.08),
              child: Center(
                child: Icon(
                  Icons.link,
                  size: 36,
                  color: platformInfo.color.withOpacity(0.4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Domain as title
                  Text(
                    domain,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Platform + saved time
                  Row(
                    children: [
                      Icon(platformInfo.icon, size: 12, color: platformInfo.color),
                      const SizedBox(width: 4),
                      Text(
                        platformInfo.displayName,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Edit title button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onEditTitle,
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text(
                        AppStrings.editTitleAction,
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
}
