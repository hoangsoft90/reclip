import 'package:flutter/material.dart';
import 'package:reclip/core/constants/platforms.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/core/constants/app_strings.dart';
import '../../application/facet_filter_controller.dart';

/// Compact filter bar with search field, dropdown selects, and toggle buttons.
class FacetFilterBar extends StatefulWidget {
  final FacetFilterController controller;

  const FacetFilterBar({super.key, required this.controller});

  @override
  State<FacetFilterBar> createState() => _FacetFilterBarState();
}

class _FacetFilterBarState extends State<FacetFilterBar> {
  final _searchController = TextEditingController();
  bool _expanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        final activeCount = state.activeCount;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Search field + filter toggle ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  // Search field
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by title, content, note…',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  widget.controller.setSearchQuery('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        widget.controller.setSearchQuery(value);
                        setState(() {}); // update clear icon
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Filter toggle button with badge
                  Badge(
                    label: activeCount > 0 ? Text('$activeCount') : null,
                    isLabelVisible: activeCount > 0,
                    child: IconButton(
                      icon: Icon(
                        _expanded ? Icons.filter_list_off : Icons.filter_list,
                        color: activeCount > 0 ? Theme.of(context).colorScheme.primary : null,
                      ),
                      onPressed: () => setState(() => _expanded = !_expanded),
                      tooltip: 'Filters',
                    ),
                  ),
                ],
              ),
            ),

            // ── Expanded filter options ──
            if (_expanded) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    // Dropdowns row
                    Row(
                      children: [
                        // Platform dropdown
                        Expanded(
                          child: _buildDropdown<PlatformEnum>(
                            label: 'Platform',
                            value: state.platforms.isEmpty ? null : state.platforms.first,
                            items: PlatformEnum.values
                                .where((p) => p != PlatformEnum.other)
                                .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            PlatformInfo.info[p]?.icon ?? Icons.language,
                                            size: 16,
                                            color: PlatformInfo.info[p]?.color,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            PlatformInfo.info[p]?.displayName ?? p.name,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) => widget.controller.setPlatform(value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Content type dropdown
                        Expanded(
                          child: _buildDropdown<ContentTypeEnum>(
                            label: 'Type',
                            value: state.contentTypes.isEmpty ? null : state.contentTypes.first,
                            items: ContentTypeEnum.values
                                .where((t) => t != ContentTypeEnum.unknown)
                                .map((t) => DropdownMenuItem(
                                      value: t,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(_contentTypeIcon(t), size: 16),
                                          const SizedBox(width: 6),
                                          Text(t.name, style: const TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) => widget.controller.setContentType(value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Why saved dropdown
                    _buildDropdown<String>(
                      label: 'Why saved',
                      value: state.whySaved,
                      items: AppStrings.whySavedOptions.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value, style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (value) => widget.controller.setWhySaved(value),
                    ),
                    const SizedBox(height: 8),
                    // Toggle buttons row
                    Row(
                      children: [
                        _buildToggleButton(
                          icon: Icons.star,
                          label: 'Favorites',
                          active: state.isFavorite == true,
                          activeColor: Colors.amber,
                          onTap: () => widget.controller.toggleFavorite(),
                        ),
                        const SizedBox(width: 8),
                        _buildToggleButton(
                          icon: Icons.archive,
                          label: 'Archived',
                          active: state.isArchived == true,
                          onTap: () => widget.controller.toggleArchived(),
                        ),
                        const SizedBox(width: 8),
                        _buildToggleButton(
                          icon: Icons.note_alt_outlined,
                          label: 'Has note',
                          active: state.hasNote == true,
                          onTap: () => widget.controller.setHasNote(
                            state.hasNote == true ? null : true,
                          ),
                        ),
                        const Spacer(),
                        // Clear all
                        if (!state.isEmpty)
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              widget.controller.clearAll();
                            },
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Clear', style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],

            // ── Active filter chips (when collapsed) ──
            if (!_expanded && activeCount > 0)
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    if (state.searchQuery.isNotEmpty)
                      _buildActiveChip(
                        icon: Icons.search,
                        label: '"${state.searchQuery}"',
                        onRemove: () {
                          _searchController.clear();
                          widget.controller.setSearchQuery('');
                        },
                      ),
                    for (final platform in state.platforms)
                      _buildActiveChip(
                        icon: PlatformInfo.info[platform]?.icon ?? Icons.language,
                        label: PlatformInfo.info[platform]?.displayName ?? platform.name,
                        color: PlatformInfo.info[platform]?.color,
                        onRemove: () => widget.controller.togglePlatform(platform),
                      ),
                    for (final type in state.contentTypes)
                      _buildActiveChip(
                        icon: _contentTypeIcon(type),
                        label: type.name,
                        onRemove: () => widget.controller.toggleContentType(type),
                      ),
                    if (state.isFavorite == true)
                      _buildActiveChip(
                        icon: Icons.star,
                        label: 'Favorites',
                        color: Colors.amber,
                        onRemove: () => widget.controller.toggleFavorite(),
                      ),
                    if (state.isArchived == true)
                      _buildActiveChip(
                        icon: Icons.archive,
                        label: 'Archived',
                        onRemove: () => widget.controller.toggleArchived(),
                      ),
                    if (state.hasNote == true)
                      _buildActiveChip(
                        icon: Icons.note_alt_outlined,
                        label: 'Has note',
                        onRemove: () => widget.controller.setHasNote(null),
                      ),
                    if (state.whySaved != null)
                      _buildActiveChip(
                        icon: Icons.bookmark,
                        label: AppStrings.whySavedOptions[state.whySaved] ?? state.whySaved!,
                        onRemove: () => widget.controller.setWhySaved(null),
                      ),
                    _buildActiveChip(
                      icon: Icons.close,
                      label: 'Clear all',
                      onRemove: () {
                        _searchController.clear();
                        widget.controller.clearAll();
                      },
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Helpers ──

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isDense: true,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool active,
    Color? activeColor,
    required VoidCallback onTap,
  }) {
    final color = active ? (activeColor ?? Colors.black) : Colors.grey.shade600;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? color.withOpacity(0.3) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveChip({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        avatar: Icon(icon, size: 14, color: color),
        label: Text(label, style: const TextStyle(fontSize: 11)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onRemove,
        backgroundColor: color?.withOpacity(0.08),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
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
