import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/core/utils/id_generator.dart';
import 'package:reclip/features/rediscovery/application/rediscovery_service.dart';
import 'package:reclip/features/rediscovery/presentation/resurface_card.dart';

class ResurfaceSection extends ConsumerStatefulWidget {
  final AppDatabase db;
  final Function(SavedItem) onItemTap;

  const ResurfaceSection({
    super.key,
    required this.db,
    required this.onItemTap,
  });

  @override
  ConsumerState<ResurfaceSection> createState() => _ResurfaceSectionState();
}

class _ResurfaceSectionState extends ConsumerState<ResurfaceSection> {
  late final RediscoveryService _service;
  List<SavedItem> _items = [];
  Map<String, String> _thumbnails = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service = RediscoveryService(widget.db);
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _service.getTodaysResurfaceItems();
    if (items.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final itemIds = items.map((i) => i.id).toList();
    final thumbnails = await widget.db.getThumbnailPathsForItems(itemIds);

    if (mounted) {
      setState(() {
        _items = items;
        _thumbnails = thumbnails;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '✨ Resurface',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return ResurfaceCard(
                item: item,
                thumbnailPath: _thumbnails[item.id],
                onTap: () => widget.onItemTap(item),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
