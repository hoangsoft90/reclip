import 'package:flutter/material.dart';
import 'package:reclip/core/constants/app_strings.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/features/smart_save/presentation/shared_note_why_fields.dart';

class SmartSaveBottomSheet extends StatefulWidget {
  final SavedItem item;
  final AppDatabase db;

  const SmartSaveBottomSheet({super.key, required this.item, required this.db});

  @override
  State<SmartSaveBottomSheet> createState() => _SmartSaveBottomSheetState();
}

class _SmartSaveBottomSheetState extends State<SmartSaveBottomSheet> {
  String? _note;
  String? _selectedWhySaved;
  List<Collection> _selectedCollections = [];
  List<Tag> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final collections = await widget.db.getCollectionsForItem(widget.item.id);
    final tags = await widget.db.getTagsForItem(widget.item.id);
    if (mounted) {
      setState(() {
        _selectedCollections = collections;
        _selectedTags = tags;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          body: ListView(
            controller: scrollController,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Text(
                AppStrings.smartSaveTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // URL preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.item.originalUrl,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),

              // ── Collection Section ──
              _buildSection(
                AppStrings.collectionLabel,
                _buildCollectionWidget(),
              ),
              const SizedBox(height: 12),

              // ── Tags Section ──
              _buildSection(
                AppStrings.tagsLabel,
                _buildTagsWidget(),
              ),
              const SizedBox(height: 12),

              // Note + Why (shared widget)
              SharedNoteWhyFields(
                initialNote: widget.item.note,
                initialWhySaved: widget.item.whySaved,
                onNoteChanged: (value) => _note = value,
                onWhySavedChanged: (value) => _selectedWhySaved = value,
              ),
              const SizedBox(height: 24),
              // Save button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    AppStrings.saveButton,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Cancel
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    AppStrings.cancelButton,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Collection Widget ──

  Widget _buildCollectionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedCollections.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _selectedCollections.map((c) {
                return Chip(
                  label: Text(c.name, style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () {
                    setState(() => _selectedCollections.remove(c));
                  },
                );
              }).toList(),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showAddCollectionSheet,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add to collection', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showAddCollectionSheet() async {
    final allCollections = await widget.db.getAllCollections();
    if (!mounted) return;

    final existingIds = _selectedCollections.map((c) => c.id).toSet();
    final available = allCollections.where((c) => !existingIds.contains(c.id)).toList();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return _CollectionPickerSheet(
              available: available,
              db: widget.db,
              onSelected: (collection) {
                setState(() => _selectedCollections.add(collection));
              },
            );
          },
        );
      },
    );
  }

  // ── Tags Widget ──

  Widget _buildTagsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedTags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _selectedTags.map((t) {
                return Chip(
                  label: Text('#${t.name}', style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () {
                    setState(() => _selectedTags.remove(t));
                  },
                  backgroundColor: Colors.green.shade50,
                );
              }).toList(),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showAddTagDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add tag', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

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
              hintText: 'e.g. recipes, travel, tutorial',
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
      final existing = _selectedTags.any((t) => t.name == result);
      if (!existing) {
        final tag = await widget.db.getOrCreateTag(result);
        setState(() => _selectedTags.add(tag));
      }
    }
  }

  // ── Save ──

  void _save() async {
    // Save note + why
    await widget.db.updateSavedItem(
      id: widget.item.id,
      note: _note?.isEmpty == true ? null : _note,
      whySaved: _selectedWhySaved,
    );

    // Sync collections: remove all then add selected
    final currentCollections = await widget.db.getCollectionsForItem(widget.item.id);
    for (final c in currentCollections) {
      if (!_selectedCollections.any((sc) => sc.id == c.id)) {
        await widget.db.removeCollectionFromItem(widget.item.id, c.id);
      }
    }
    for (final c in _selectedCollections) {
      await widget.db.addToCollection(widget.item.id, c.id);
    }

    // Sync tags: remove all then add selected
    final currentTags = await widget.db.getTagsForItem(widget.item.id);
    for (final t in currentTags) {
      if (!_selectedTags.any((st) => st.id == t.id)) {
        await widget.db.removeTagFromItem(widget.item.id, t.id);
      }
    }
    for (final t in _selectedTags) {
      await widget.db.addTagToItem(widget.item.id, t.id);
    }

    if (mounted) Navigator.of(context).pop();
  }

  // ── Helper ──

  Widget _buildSection(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// Reusable collection picker sheet with inline create-new functionality.
class _CollectionPickerSheet extends StatefulWidget {
  final List<Collection> available;
  final AppDatabase db;
  final ValueChanged<Collection> onSelected;

  const _CollectionPickerSheet({
    required this.available,
    required this.db,
    required this.onSelected,
  });

  @override
  State<_CollectionPickerSheet> createState() => _CollectionPickerSheetState();
}

class _CollectionPickerSheetState extends State<_CollectionPickerSheet> {
  final _newCollectionController = TextEditingController();
  List<Collection> _collections = [];
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _collections = List.from(widget.available);
  }

  @override
  void dispose() {
    _newCollectionController.dispose();
    super.dispose();
  }

  Future<void> _createCollection() async {
    final name = _newCollectionController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isCreating = true);
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final collection = await widget.db.insertCollection(id: id, name: name);
      _newCollectionController.clear();
      widget.onSelected(collection);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // Inline create new collection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCollectionController,
                    decoration: InputDecoration(
                      hintText: 'Create new collection…',
                      prefixIcon: const Icon(Icons.create_new_folder, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _createCollection(),
                  ),
                ),
                const SizedBox(width: 8),
                _isCreating
                    ? const SizedBox(
                        width: 36,
                        height: 36,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        onPressed: _createCollection,
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: 'Create',
                      ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade200),
          // Existing collections list
          Expanded(
            child: _collections.isEmpty
                ? Center(
                    child: Text(
                      'No collections yet — create one above',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    itemCount: _collections.length,
                    itemBuilder: (context, index) {
                      final c = _collections[index];
                      return ListTile(
                        leading: Icon(Icons.folder, color: Colors.grey.shade600),
                        title: Text(c.name),
                        onTap: () {
                          widget.onSelected(c);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
