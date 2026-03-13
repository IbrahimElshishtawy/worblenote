import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/notifications/app_notification.dart';
import 'package:writdle/core/notifications/app_notification_cubit.dart';
import 'package:writdle/data/datasources/game_stats_service.dart';
import 'package:writdle/domain/entities/wordle_game_logic.dart';
import 'package:writdle/domain/repositories/profile_repository.dart';
import 'package:writdle/presentation/bloc/app_settings_cubit.dart';
import 'package:writdle/presentation/screens/Stats_games_Page.dart';
import 'package:writdle/presentation/widgets/keyboard_widget.dart';
import 'package:writdle/presentation/widgets/wordle_grid.dart';

class WordlePage extends StatefulWidget {
  const WordlePage({super.key, this.onGameFinished});

  final VoidCallback? onGameFinished;

  @override
  State<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends State<WordlePage> {
  final WordleGameLogic game = WordleGameLogic();
  final GameStatsService statsService = GameStatsService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  Future<void> _initializeGame() async {
    final settings = context.read<AppSettingsCubit>().state;
    await game.initGame(
      requireManualRestart: settings.requireManualGameRestart,
    );
    if (game.gameEnded && game.cooldownLeft > Duration.zero) {
      game.updateCooldownTimer(
        requireManualRestart: settings.requireManualGameRestart,
        callback: () {
          if (mounted) {
            setState(() {});
          }
        },
      );
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    game.dispose();
    super.dispose();
  }

  Future<void> _onKeyTap(String key) async {
    if (key == 'ENTER') {
      if (!game.canPlay()) {
        return;
      }
      final message = await game.submitCurrentGuess();
      if (message != null && mounted) {
        context.read<AppNotificationCubit>().show(
          message,
          type: game.didWin ? AppNotificationType.success : AppNotificationType.info,
        );
      }

      if (game.gameEnded) {
        final repository = context.read<IProfileRepository>();
        final currentStats = await repository.getStats();
        final updatedStats = game.didWin
            ? currentStats.copyWith(
                totalGames: currentStats.totalGames + 1,
                winsFirstTry: currentStats.winsFirstTry + (game.resultAttempt == 1 ? 1 : 0),
                winsSecondTry: currentStats.winsSecondTry + (game.resultAttempt == 2 ? 1 : 0),
                winsThirdTry: currentStats.winsThirdTry + (game.resultAttempt == 3 ? 1 : 0),
                winsFourthTry: currentStats.winsFourthTry + (game.resultAttempt == 4 ? 1 : 0),
              )
            : currentStats.copyWith(
                totalGames: currentStats.totalGames + 1,
                losses: currentStats.losses + 1,
              );
        await repository.saveStats(updatedStats);

        if (game.didWin) {
          await statsService.incrementGame(isWin: true, tryNumber: game.resultAttempt);
        } else {
          await statsService.incrementGame(isWin: false);
        }

        widget.onGameFinished?.call();
      }
    } else {
      await game.tapKey(key);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _restartGame() async {
    await game.restartGame();
    if (mounted) {
      context.read<AppNotificationCubit>().show(
        'New round started.',
        type: AppNotificationType.success,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsCubit>().state;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Wordle Game'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withValues(alpha: 0.06),
              scheme.surface,
              scheme.secondary.withValues(alpha: 0.04),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _GameStatusCard(
                  game: game,
                  showHints: settings.showGameHints,
                  onRestart: game.isReadyForManualRestart ? _restartGame : null,
                  onStats: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      builder: (_) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: StatsPage(resultAttempt: game.resultAttempt),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: WordleGrid(
                      guesses: game.guesses.map((guess) => guess.split('')).toList(),
                      results: game.results,
                      highContrast: settings.highContrastGame,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                KeyboardWidget(
                  keyStatus: game.keyStatus,
                  onKeyTap: _onKeyTap,
                  highContrast: settings.highContrastGame,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameStatusCard extends StatelessWidget {
  const _GameStatusCard({
    required this.game,
    required this.showHints,
    required this.onStats,
    this.onRestart,
  });

  final WordleGameLogic game;
  final bool showHints;
  final VoidCallback onStats;
  final VoidCallback? onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final title = game.gameEnded
        ? (game.didWin ? 'You solved it' : 'Round completed')
        : 'Current Round';

    final subtitle = game.latestResultMessage ??
        (showHints
            ? 'Guess the 5-letter word. Correct letters stay green, present letters move to amber.'
            : 'Play your current saved session.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (game.gameEnded && game.cooldownLeft > Duration.zero)
                _InfoChip(
                  icon: Icons.timer_outlined,
                  label: game.formatDuration(game.cooldownLeft),
                  color: const Color(0xFF7C3AED),
                ),
              _InfoChip(
                icon: Icons.grid_view_rounded,
                label: 'Attempt ${game.currentRow + 1}/4',
                color: const Color(0xFF2563EB),
              ),
              if (game.resultAttempt > 0)
                _InfoChip(
                  icon: Icons.emoji_events_outlined,
                  label: 'Solved in ${game.resultAttempt}',
                  color: const Color(0xFF16A34A),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onStats,
                icon: const Icon(Icons.bar_chart_rounded),
                label: const Text('Stats'),
              ),
              const SizedBox(width: 10),
              if (onRestart != null)
                ElevatedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Restart'),
                ),
            ],
          ),
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
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
