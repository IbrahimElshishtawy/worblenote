import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/notifications/app_notification.dart';
import 'package:writdle/core/notifications/app_notification_cubit.dart';
import 'package:writdle/data/datasources/game_stats_service.dart';
import 'package:writdle/domain/entities/wordle_game_logic.dart';
import 'package:writdle/domain/repositories/profile_repository.dart';
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
    game.initGame().then((_) {
      if (game.gameEnded) {
        game.updateCooldownTimer(() => setState(() {}));
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    game.dispose();
    super.dispose();
  }

  Future<void> _onKeyTap(String key) async {
    if (!game.canPlay()) {
      return;
    }

    setState(() {
      game.tapKey(key);
    });

    if (key != 'ENTER') {
      return;
    }

    final guess = game.guesses[game.currentRow];
    if (guess.length != 5) {
      return;
    }

    final message = await game.submitGuess(guess);
    if (message != null && mounted) {
      context.read<AppNotificationCubit>().show(
        message,
        type: AppNotificationType.info,
      );
    }

    if (game.gameEnded) {
      final repository = context.read<IProfileRepository>();
      final currentStats = await repository.getStats();
      final updatedStats = game.didWin
          ? currentStats.copyWith(
              totalGames: currentStats.totalGames + 1,
              winsFirstTry:
                  currentStats.winsFirstTry + (game.resultAttempt == 1 ? 1 : 0),
              winsSecondTry:
                  currentStats.winsSecondTry + (game.resultAttempt == 2 ? 1 : 0),
              winsThirdTry:
                  currentStats.winsThirdTry + (game.resultAttempt == 3 ? 1 : 0),
              winsFourthTry:
                  currentStats.winsFourthTry + (game.resultAttempt == 4 ? 1 : 0),
            )
          : currentStats.copyWith(
              totalGames: currentStats.totalGames + 1,
              losses: currentStats.losses + 1,
            );

      await repository.saveStats(updatedStats);

      if (game.didWin) {
        await statsService.incrementGame(
          isWin: true,
          tryNumber: game.resultAttempt,
        );
      } else {
        await statsService.incrementGame(isWin: false);
      }

      widget.onGameFinished?.call();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Wordle Game'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Expanded(
                flex: 2,
                child: WordleGrid(
                  guesses: game.guesses.map((guess) => guess.split('')).toList(),
                  results: game.results,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 70),
                    child: Column(
                      children: [
                        KeyboardWidget(
                          keyStatus: game.keyStatus,
                          onKeyTap: _onKeyTap,
                        ),
                        if (game.gameEnded) ...[
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.black,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(30),
                                  ),
                                ),
                                builder: (_) => SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  child: StatsPage(
                                    resultAttempt: game.resultAttempt,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.bar_chart),
                            label: const Text('View Stats'),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Come back in: ${game.formatDuration(game.cooldownLeft)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
