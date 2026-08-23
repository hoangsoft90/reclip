import 'package:flutter/material.dart';
import 'package:reclip/core/constants/app_strings.dart';
import 'package:reclip/core/database/database.dart';

class SmartSaveBottomSheet extends StatefulWidget {
  final SavedItem item;
  final AppDatabase db;

  const SmartSaveBottomSheet({super.key, required this.item, required this.db});

  @override
  State<SmartSaveBottomSheet> createState() => _SmartSaveBottomSheetState();
}

class _SmartSaveBottomSheetState extends State<SmartSaveBottomSheet> {
  late TextEditingController _noteController;
  String? _selectedWhySaved;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.item.note ?? '');
    _selectedWhySaved = widget.item.whySaved;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
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
              // Collection (placeholder)
              _buildSection(
                AppStrings.collectionLabel,
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'No collection selected',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Tags (placeholder)
              _buildSection(
                AppStrings.tagsLabel,
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'No tags added',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Why saved
              _buildSection(
                AppStrings.whySavedLabel,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppStrings.whySavedOptions.entries.map((entry) {
                    final isSelected = _selectedWhySaved == entry.key;
                    return ChoiceChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedWhySaved = selected ? entry.key : null;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              // Note
              _buildSection(
                AppStrings.noteLabel,
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Why did you save this?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
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

  void _save() async {
    final note = _noteController.text.trim();
    await widget.db.updateSavedItem(
      id: widget.item.id,
      note: note.isEmpty ? null : note,
      whySaved: _selectedWhySaved,
    );
    if (mounted) Navigator.of(context).pop();
  }

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
