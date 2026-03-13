import 'package:flutter/material.dart';
import 'package:writdle/domain/entities/user_stats_summary.dart';

class ProfileHighlightPanel extends StatelessWidget {
  const ProfileHighlightPanel({
    super.key,
    required this.stats,
  });

  final UserStatsSummary stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final completionTone =
        stats.completedTasks >= 5 ? 'Strong momentum' : 'Keep building';
    final winTone =
        stats.winRate >= 60 ? 'Competitive form' : 'Progress in motion';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Overview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Track how your productivity and game results move together in one clear dashboard.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          _HighlightRow(
            title: 'Win rate',
            value: '${stats.winRate.toStringAsFixed(0)}%',
            subtitle: winTone,
            progress: (stats.winRate / 100).clamp(0, 1),
            color: scheme.primary,
          ),
          const SizedBox(height: 18),
          _HighlightRow(
            title: 'Task execution',
            value: '${stats.completedTasks}',
            subtitle: completionTone,
            progress: (stats.completedTasks / 10).clamp(0, 1),
            color: scheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: color.withValues(alpha: 0.10),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
