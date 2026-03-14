import 'package:flutter/material.dart';
import 'package:writdle/domain/entities/wordle_game_logic.dart';

class GameStatusPanel extends StatelessWidget {
  const GameStatusPanel({
    super.key,
    required this.game,
    required this.showHints,
    required this.competitiveMode,
    required this.showAttemptBadge,
    required this.showCountdownBadge,
    required this.onStats,
    this.onRestart,
  });

  final WordleGameLogic game;
  final bool showHints;
  final bool competitiveMode;
  final bool showAttemptBadge;
  final bool showCountdownBadge;
  final VoidCallback onStats;
  final VoidCallback? onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final title = game.gameEnded
        ? (game.didWin ? 'Victory Locked' : 'Round Closed')
        : 'Live Match';

    final subtitle = game.latestResultMessage ??
        (showHints
            ? 'Read the board, manage the tries, and push for the cleanest solve.'
            : 'Your saved session is ready.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: competitiveMode
            ? LinearGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.95),
                  scheme.secondary.withValues(alpha: 0.88),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: competitiveMode ? null : scheme.surface.withValues(alpha: 0.96),
        border: Border.all(
          color: competitiveMode
              ? scheme.primary.withValues(alpha: 0.35)
              : scheme.outlineVariant,
        ),
        boxShadow: competitiveMode
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.20),
                  blurRadius: 26,
                  offset: const Offset(0, 16),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: competitiveMode ? scheme.onPrimary : null,
                  ),
                ),
              ),
              if (competitiveMode)
                InkWell(
                  onTap: onStats,
                  borderRadius: BorderRadius.circular(999),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: scheme.onPrimary.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          game.gameEnded ? 'FINAL' : 'RANKED',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: scheme.onPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'STATE',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: competitiveMode
                  ? scheme.onPrimary.withValues(alpha: 0.90)
                  : scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (showCountdownBadge && game.gameEnded && game.cooldownLeft > Duration.zero)
                _InfoChip(
                  icon: Icons.timer_outlined,
                  label: game.formatDuration(game.cooldownLeft),
                  color: competitiveMode ? scheme.onPrimary : const Color(0xFF7C3AED),
                  lightBackground: competitiveMode,
                ),
              if (showAttemptBadge)
                _InfoChip(
                  icon: Icons.grid_view_rounded,
                  label: 'Attempt ${game.currentRow + 1}/${game.maxAttempts}',
                  color: competitiveMode ? scheme.onPrimary : const Color(0xFF2563EB),
                  lightBackground: competitiveMode,
                ),
              if (game.resultAttempt > 0)
                _InfoChip(
                  icon: Icons.emoji_events_outlined,
                  label: 'Solved in ${game.resultAttempt}',
                  color: competitiveMode ? scheme.onPrimary : const Color(0xFF16A34A),
                  lightBackground: competitiveMode,
                ),
            ],
          ),
          if (onRestart != null) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: onRestart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: competitiveMode
                      ? scheme.onPrimary
                      : scheme.primary,
                  foregroundColor: competitiveMode
                      ? scheme.primary
                      : scheme.onPrimary,
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Restart'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    this.lightBackground = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool lightBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: lightBackground
            ? Colors.white.withValues(alpha: 0.12)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
