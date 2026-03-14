import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:writdle/domain/entities/task_model.dart';

class TaskItemCard extends StatelessWidget {
  const TaskItemCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _priorityColor() {
    switch (task.priority) {
      case TaskPriority.low:
        return const Color(0xFF15803D);
      case TaskPriority.medium:
        return const Color(0xFFEA580C);
      case TaskPriority.high:
        return const Color(0xFFDC2626);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final priorityColor = _priorityColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: task.description.isEmpty ? 122 : 150,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(26)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: onToggle,
                        borderRadius: BorderRadius.circular(999),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10, top: 2),
                          child: Icon(
                            task.completed ? Icons.check_circle_rounded : Icons.circle_outlined,
                            color: task.completed
                                ? const Color(0xFF15803D)
                                : scheme.onSurfaceVariant,
                            size: 26,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                decoration: task.completed ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                task.description,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TaskChip(
                        label: task.category,
                        icon: Icons.category_outlined,
                        color: scheme.primary,
                      ),
                      _TaskChip(
                        label: task.priority.label,
                        icon: Icons.flag_outlined,
                        color: priorityColor,
                      ),
                      if (task.reminderAt != null)
                        _TaskChip(
                          label: DateFormat('d MMM, hh:mm a').format(task.reminderAt!),
                          icon: Icons.notifications_active_outlined,
                          color: const Color(0xFF7C3AED),
                        ),
                      if (task.id.startsWith('local_'))
                        const _TaskChip(
                          label: 'On device',
                          icon: Icons.phone_android_rounded,
                          color: Color(0xFF92400E),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskChip extends StatelessWidget {
  const _TaskChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
