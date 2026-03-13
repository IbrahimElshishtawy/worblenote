import 'package:flutter/material.dart';

class RecentWinsCard extends StatelessWidget {
  const RecentWinsCard({
    super.key,
    required this.completedTaskTitles,
  });

  final List<String> completedTaskTitles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: completedTaskTitles.isEmpty
          ? Text(
              'No completed tasks yet. Start with one small win.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            )
          : Column(
              children: completedTaskTitles
                  .map(
                    (title) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Color(0xFF15803D),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(title)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
