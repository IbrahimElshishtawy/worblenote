// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key, required this.resultAttempt});

  final int resultAttempt;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Future<List<int>> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    return [
      prefs.getInt('win1') ?? 0,
      prefs.getInt('win2') ?? 0,
      prefs.getInt('win3') ?? 0,
      prefs.getInt('win4') ?? 0,
      prefs.getInt('total_losses') ?? 0,
    ];
  }

  Future<void> _resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('win1');
    await prefs.remove('win2');
    await prefs.remove('win3');
    await prefs.remove('win4');
    await prefs.remove('total_losses');
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmReset() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;

        return AlertDialog(
          backgroundColor: scheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            'Reset statistics',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'This will clear all saved Wordle performance data on this device.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _resetStats();
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final labels = <String>[
      '1st attempt',
      '2nd attempt',
      '3rd attempt',
      '4th attempt',
      'Missed round',
    ];

    final icons = <IconData>[
      LucideIcons.badgeCheck,
      LucideIcons.sparkles,
      LucideIcons.target,
      LucideIcons.timerReset,
      LucideIcons.circleOff,
    ];

    final colors = <Color>[
      const Color(0xFF16A34A),
      const Color(0xFF22C55E),
      const Color(0xFFF59E0B),
      const Color(0xFFF97316),
      const Color(0xFFEF4444),
    ];

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: FutureBuilder<List<int>>(
          future: _loadStats(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final values = snapshot.data!;
            final totalGames = values.fold(0, (sum, val) => sum + val);
            final totalWins = values.take(4).fold(0, (sum, val) => sum + val);
            final totalLosses = values[4];
            final winRate = totalGames == 0
                ? 0
                : ((totalWins / totalGames) * 100).round();

            final latestLabel = widget.resultAttempt > 0
                ? 'Solved in ${widget.resultAttempt}'
                : 'No result yet';

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 12, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: scheme.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Reset statistics',
                        onPressed: _confirmReset,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: scheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          gradient: LinearGradient(
                            colors: [
                              scheme.primary,
                              scheme.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Match State',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: scheme.onPrimary.withValues(alpha: 0.82),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Performance Overview',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Your local Wordle record, win spread, and latest round summary.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onPrimary.withValues(alpha: 0.9),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _HeroBadge(
                                  label: 'Win Rate',
                                  value: '$winRate%',
                                  color: scheme.onPrimary,
                                ),
                                _HeroBadge(
                                  label: 'Latest',
                                  value: latestLabel,
                                  color: scheme.onPrimary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: 'Games',
                              value: '$totalGames',
                              icon: LucideIcons.gamepad2,
                              accent: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SummaryCard(
                              title: 'Wins',
                              value: '$totalWins',
                              icon: LucideIcons.trophy,
                              accent: const Color(0xFF16A34A),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SummaryCard(
                              title: 'Losses',
                              value: '$totalLosses',
                              icon: Icons.close_rounded,
                              accent: scheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Attempt Breakdown',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'See how often you finish in each round window.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...List.generate(labels.length, (index) {
                        final value = values[index];
                        final ratio = totalGames == 0 ? 0.0 : value / totalGames;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AttemptStatTile(
                            label: labels[index],
                            value: value,
                            progress: ratio,
                            icon: icons[index],
                            color: colors[index],
                          ),
                        );
                      }),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Back to game'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.78),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttemptStatTile extends StatelessWidget {
  const _AttemptStatTile({
    required this.label,
    required this.value,
    required this.progress,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final double progress;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$value',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: scheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
