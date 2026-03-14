import 'package:flutter/material.dart';
import 'package:writdle/domain/entities/task_model.dart';

class TaskOverviewCards extends StatelessWidget {
  const TaskOverviewCards({
    super.key,
    required this.tasks,
  });

  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context) {
    final openCount = tasks.where((task) => !task.completed).length;
    final doneCount = tasks.where((task) => task.completed).length;
    final alertsCount = tasks.where((task) => task.hasReminder).length;

    return Row(
      children: [
        Expanded(
          child: _OverviewCard(
            label: 'Open',
            value: '$openCount',
            color: const Color(0xFFEA580C),
            icon: Icons.hourglass_top_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OverviewCard(
            label: 'Done',
            value: '$doneCount',
            color: const Color(0xFF15803D),
            icon: Icons.task_alt_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OverviewCard(
            label: 'Alerts',
            value: '$alertsCount',
            color: const Color(0xFF7C3AED),
            icon: Icons.notifications_active_rounded,
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
