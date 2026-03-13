import 'package:flutter/material.dart';

class NoteEditorSheet extends StatelessWidget {
  const NoteEditorSheet({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.isEditing,
    required this.onSave,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final bool isEditing;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, bottomInset + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isEditing ? 'Edit Note' : 'Create Note',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep it clear, short, and easy to find later.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: titleController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Title',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: descriptionController,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Write your note',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 84),
                child: Icon(Icons.notes_rounded),
              ),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save_outlined),
            label: Text(isEditing ? 'Save changes' : 'Add note'),
          ),
        ],
      ),
    );
  }
}
