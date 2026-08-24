import 'package:flutter/material.dart';
import 'package:reclip/core/constants/app_strings.dart';

/// Shared widget for Note + Why Saved fields.
/// Used in both SmartSaveBottomSheet and EditNoteWhySheet.
class SharedNoteWhyFields extends StatefulWidget {
  final String? initialNote;
  final String? initialWhySaved;
  final ValueChanged<String?> onNoteChanged;
  final ValueChanged<String?> onWhySavedChanged;

  const SharedNoteWhyFields({
    super.key,
    this.initialNote,
    this.initialWhySaved,
    required this.onNoteChanged,
    required this.onWhySavedChanged,
  });

  @override
  State<SharedNoteWhyFields> createState() => _SharedNoteWhyFieldsState();
}

class _SharedNoteWhyFieldsState extends State<SharedNoteWhyFields> {
  late TextEditingController _noteController;
  String? _selectedWhySaved;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote ?? '');
    _selectedWhySaved = widget.initialWhySaved;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Why saved chips
        Text(
          AppStrings.whySavedLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
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
                widget.onWhySavedChanged(_selectedWhySaved);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Note field
        Text(
          AppStrings.noteLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _noteController,
          maxLines: 3,
          onChanged: widget.onNoteChanged,
          decoration: InputDecoration(
            hintText: 'Why did you save this?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
