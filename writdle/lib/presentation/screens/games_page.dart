import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/app_navigation.dart';
import 'package:writdle/core/app_localizations.dart';
import 'package:writdle/core/notifications/app_notification.dart';
import 'package:writdle/core/notifications/app_notification_cubit.dart';
import 'package:writdle/data/datasources/game_stats_service.dart';
import 'package:writdle/domain/entities/wordle_game_logic.dart';
import 'package:writdle/domain/repositories/profile_repository.dart';
import 'package:writdle/presentation/bloc/app_settings_cubit.dart';
import 'package:writdle/presentation/screens/Stats_games_Page.dart';
import 'package:writdle/presentation/widgets/game/game_status_panel.dart';
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
      difficulty: settings.gameDifficulty,
      cooldownHours: settings.gameCooldownHours,
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
        context.l10n.t('new_round_started'),
        type: AppNotificationType.success,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.watch<AppSettingsCubit>().state;
    final scheme = Theme.of(context).colorScheme;

    return BlocListener<AppSettingsCubit, AppSettingsState>(
      listenWhen: (previous, current) =>
          previous.gameDifficulty != current.gameDifficulty ||
          previous.gameCooldownHours != current.gameCooldownHours ||
          previous.requireManualGameRestart != current.requireManualGameRestart,
      listener: (context, state) async {
        game.difficulty = state.gameDifficulty;
        game.cooldownHours = state.gameCooldownHours;
        await game.restartGame();
        if (!mounted) {
          return;
        }
        context.read<AppNotificationCubit>().show(
          l10n.t('game_settings_applied'),
          type: AppNotificationType.success,
        );
        setState(() {});
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: const SizedBox.shrink(),
          leadingWidth: 0,
          title: Text(l10n.t('wordle_game')),
          actions: [
            IconButton(
              onPressed: () async {
                await Navigator.pushNamed(context, '/settings');
                if (!mounted) {
                  return;
                }
                await _initializeGame();
              },
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
                  GameStatusPanel(
                    game: game,
                    showHints: settings.showGameHints,
                    competitiveMode: settings.competitiveGameUi,
                    showAttemptBadge: settings.showAttemptBadge,
                    showCountdownBadge: settings.showCountdownBadge,
                    onRestart: game.isReadyForManualRestart ? _restartGame : null,
                    onStats: () {
                      AppNavigation.showSheet<void>(
                        context,
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return AnimatedContainer(
                            duration: Duration(
                              milliseconds: settings.reduceMotion ? 0 : 240,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: settings.competitiveGameUi
                                  ? scheme.surface.withValues(alpha: 0.98)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(32),
                              border: settings.competitiveGameUi
                                  ? Border.all(color: scheme.outlineVariant)
                                  : null,
                              boxShadow: settings.competitiveGameUi
                                  ? [
                                      BoxShadow(
                                        color: scheme.shadow.withValues(alpha: 0.08),
                                        blurRadius: 28,
                                        offset: const Offset(0, 16),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth,
                                maxHeight: constraints.maxHeight,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: WordleGrid(
                                  guesses: game.guesses
                                      .map((guess) => guess.split(''))
                                      .toList(),
                                  results: game.results,
                                  highContrast: settings.highContrastGame,
                                ),
                              ),
                            ),
                          );
                        },
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
      ),
    );
  }
}
