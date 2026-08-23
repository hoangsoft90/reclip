import 'package:flutter/material.dart';
import 'package:reclip/core/constants/platforms.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/core/constants/app_strings.dart';
import '../../application/facet_filter_controller.dart';

/// Horizontal filter bar for the Library screen.
/// Shows chips for platform, content type, has note, and why saved.
class FacetFilterBar extends StatelessWidget {
  final FacetFilterController controller;

  const FacetFilterBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        return SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              // Platform chips
              for (final platform in PlatformEnum.values)
                if (platform != PlatformEnum.other)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      avatar: Icon(
                        PlatformInfo.info[platform]?.icon ?? Icons.language,
                        size: 16,
                      ),
                      label: Text(
                        PlatformInfo.info[platform]?.displayName ?? platform.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                      selected: state.platforms.contains(platform),
                      onSelected: (_) => controller.togglePlatform(platform),
                      selectedColor: PlatformInfo.info[platform]?.color.withOpacity(0.2),
                      showCheckmark: false,
                    ),
                  ),
              // Content type chips
              for (final type in [ContentTypeEnum.video, ContentTypeEnum.image, ContentTypeEnum.text])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    avatar: Icon(_contentTypeIcon(type), size: 16),
                    label: Text(type.name, style: const TextStyle(fontSize: 12)),
                    selected: state.contentTypes.contains(type),
                    onSelected: (_) => controller.toggleContentType(type),
                    showCheckmark: false,
                  ),
                ),
              // Has note chip
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  avatar: const Icon(Icons.note_alt_outlined, size: 16),
                  label: const Text('Has note', style: TextStyle(fontSize: 12)),
                  selected: state.hasNote == true,
                  onSelected: (_) {
                    controller.setHasNote(state.hasNote == true ? null : true);
                  },
                  showCheckmark: false,
                ),
              ),
              // Why saved chip
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ActionChip(
                  avatar: const Icon(Icons.bookmark_border, size: 16),
                  label: const Text('Why saved', style: TextStyle(fontSize: 12)),
                  onPressed: () => _showWhySavedPicker(context),
                ),
              ),
              // Clear all
              if (!state.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ActionChip(
                    avatar: const Icon(Icons.close, size: 16),
                    label: const Text('Clear', style: TextStyle(fontSize: 12)),
                    onPressed: controller.clearAll,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showWhySavedPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                AppStrings.whySavedLabel,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            for (final entry in AppStrings.whySavedOptions.entries)
              ListTile(
                title: Text(entry.value),
                trailing: controller.state.whySaved == entry.key
                    ? const Icon(Icons.check, color: Colors.black)
                    : null,
                onTap: () {
                  controller.setWhySaved(
                    controller.state.whySaved == entry.key ? null : entry.key,
                  );
                  Navigator.of(context).pop();
                },
              ),
            const SizedBox(height: 8),
          ],
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
}
