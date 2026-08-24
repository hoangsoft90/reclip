import 'package:flutter/material.dart';
import 'package:reclip/core/database/database.dart';
import 'package:reclip/features/smart_save/presentation/shared_note_why_fields.dart';

class EditNoteWhySheet extends StatefulWidget {
  final SavedItem item;
  final AppDatabase db;

  const EditNoteWhySheet({
    super.key,
    required this.item,
    required this.db,
  });

  @override
  State<EditNoteWhySheet> createState() => _EditNoteWhySheetState();
}

class _EditNoteWhySheetState extends State<EditNoteWhySheet> {
  String? _note;
  String? _whySaved;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
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
              const Text(
                'Edit Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Shared fields
              SharedNoteWhyFields(
                initialNote: widget.item.note,
                initialWhySaved: widget.item.whySaved,
                onNoteChanged: (value) => _note = value,
                onWhySavedChanged: (value) => _whySaved = value,
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
                    'Save',
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
                    'Cancel',
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
    await widget.db.updateSavedItem(
      id: widget.item.id,
      note: _note?.isEmpty == true ? null : _note,
      whySaved: _whySaved,
    );
    if (mounted) Navigator.of(context).pop();
  }
}
