import 'package:flutter/material.dart';

class TaskReminderCard extends StatelessWidget {
  const TaskReminderCard({
    super.key,
    required this.reminderText,
    required this.onPickReminder,
    required this.onClearReminder,
    required this.hasReminder,
  });

  final String reminderText;
  final VoidCallback onPickReminder;
  final VoidCallback onClearReminder;
  final bool hasReminder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminder',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  reminderText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onPickReminder,
            icon: const Icon(Icons.notifications_active_outlined),
          ),
          if (hasReminder)
            IconButton(
              onPressed: onClearReminder,
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
    );
  }
}
