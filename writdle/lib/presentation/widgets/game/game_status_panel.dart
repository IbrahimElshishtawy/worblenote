import 'package:flutter/material.dart';
import 'package:writdle/core/app_localizations.dart';
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

    final statusTitle = game.gameEnded
        ? (game.didWin ? 'Victory Locked' : 'Round Closed')
        : 'Round In Progress';
    final statusBadge = game.gameEnded
        ? (game.didWin ? 'FINAL' : 'CLOSED')
        : 'LIVE';
    final attemptLabel = '${game.currentRow + 1}/${game.maxAttempts}';

    final subtitle = game.latestResultMessage ??
        (showHints
            ? 'Read the board, manage the tries, and push for the cleanest solve.'
            : 'Your saved session is ready.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: competitiveMode
            ? LinearGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.98),
                  scheme.secondary.withValues(alpha: 0.90),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
              )
            : null,
        color: competitiveMode ? null : scheme.surface.withValues(alpha: 0.97),
        border: Border.all(
          color: competitiveMode
              ? scheme.primary.withValues(alpha: 0.35)
              : scheme.outlineVariant,
        ),
        boxShadow: competitiveMode
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.22),
                  blurRadius: 26,
                  offset: const Offset(0, 16),
                ),
              ]
            : [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBadgeRow(
                      scheme: scheme,
                      theme: theme,
                      competitiveMode: competitiveMode,
                      statusBadge: statusBadge,
                      onStats: onStats,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      statusTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: competitiveMode ? 18 : 16,
                        color: competitiveMode ? scheme.onPrimary : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        color: competitiveMode
                            ? scheme.onPrimary.withValues(alpha: 0.90)
                            : scheme.onSurfaceVariant,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _AttemptPanel(
                attemptLabel: attemptLabel,
                competitiveMode: competitiveMode,
                scheme: scheme,
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (showCountdownBadge && game.gameEnded && game.cooldownLeft > Duration.zero)
                _InfoChip(
                  icon: Icons.timer_outlined,
                  label: game.formatDuration(game.cooldownLeft),
                  color: competitiveMode ? scheme.onPrimary : const Color(0xFF7C3AED),
                  lightBackground: competitiveMode,
                ),
              if (showAttemptBadge && game.gameEnded)
                _InfoChip(
                  icon: Icons.grid_view_rounded,
                  label: 'Attempt $attemptLabel',
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
            const SizedBox(height: 8),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  minimumSize: Size.zero,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(context.l10n.t('restart')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopBadgeRow extends StatelessWidget {
  const _TopBadgeRow({
    required this.scheme,
    required this.theme,
    required this.competitiveMode,
    required this.statusBadge,
    required this.onStats,
  });

  final ColorScheme scheme;
  final ThemeData theme;
  final bool competitiveMode;
  final String statusBadge;
  final VoidCallback onStats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 220;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _BadgePill(
              label: statusBadge,
              color: competitiveMode ? scheme.onPrimary : scheme.primary,
              backgroundColor: competitiveMode
                  ? scheme.onPrimary.withValues(alpha: 0.16)
                  : scheme.primary.withValues(alpha: 0.10),
            ),
            InkWell(
              onTap: onStats,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 9 : 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: competitiveMode
                      ? scheme.onPrimary.withValues(alpha: 0.10)
                      : scheme.surfaceContainerHighest.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: competitiveMode
                        ? scheme.onPrimary.withValues(alpha: 0.12)
                        : scheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 16,
                      color: competitiveMode
                          ? scheme.onPrimary
                          : scheme.onSurfaceVariant,
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.t('stats'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: competitiveMode
                              ? scheme.onPrimary
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AttemptPanel extends StatelessWidget {
  const _AttemptPanel({
    required this.attemptLabel,
    required this.competitiveMode,
    required this.scheme,
    required this.theme,
  });

  final String attemptLabel;
  final bool competitiveMode;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: competitiveMode
            ? scheme.onPrimary.withValues(alpha: 0.10)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: competitiveMode
              ? scheme.onPrimary.withValues(alpha: 0.12)
              : scheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Text(
            context.l10n.t('attempt').toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 0.9,
              fontWeight: FontWeight.w800,
              fontSize: 9,
              color: competitiveMode
                  ? scheme.onPrimary.withValues(alpha: 0.88)
                  : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            attemptLabel,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: competitiveMode ? scheme.onPrimary : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
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



