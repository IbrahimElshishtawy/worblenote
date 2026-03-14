import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:writdle/domain/entities/task_model.dart';
import 'package:writdle/presentation/widgets/tasks/task_editor_intro.dart';
import 'package:writdle/presentation/widgets/tasks/task_reminder_card.dart';

class TaskEditorSheet extends StatelessWidget {
  const TaskEditorSheet({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.selectedPriority,
    required this.reminderAt,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onPickReminder,
    required this.onClearReminder,
    required this.onSave,
    required this.isEditing,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String selectedCategory;
  final TaskPriority selectedPriority;
  final DateTime? reminderAt;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<TaskPriority> onPriorityChanged;
  final VoidCallback onPickReminder;
  final VoidCallback onClearReminder;
  final VoidCallback onSave;
  final bool isEditing;

  static const categories = ['General', 'Work', 'Study', 'Health', 'Personal'];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final reminderText = reminderAt == null
        ? 'No reminder selected'
        : DateFormat('EEE, d MMM - hh:mm a').format(reminderAt!);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, bottomInset + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskEditorIntro(isEditing: isEditing),
            const SizedBox(height: 18),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Task title',
                prefixIcon: Icon(Icons.task_alt_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: descriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 52),
                  child: Icon(Icons.notes_rounded),
                ),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: categories
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onCategoryChanged(value);
                }
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<TaskPriority>(
              initialValue: selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: TaskPriority.values
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onPriorityChanged(value);
                }
              },
            ),
            const SizedBox(height: 14),
            TaskReminderCard(
              reminderText: reminderText,
              onPickReminder: onPickReminder,
              onClearReminder: onClearReminder,
              hasReminder: reminderAt != null,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save_outlined),
                label: Text(isEditing ? 'Save task' : 'Add task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
