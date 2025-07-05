// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:writdle/models/wordle_game_logic.dart';
import 'package:writdle/screen/Stats_games_Page.dart';
import 'package:writdle/widget/keyboard_widget.dart';
import 'package:writdle/widget/wordle_grid.dart';
import 'package:writdle/data/game_stats.dart'; // لإرسال البيانات للبروفايل

class WordlePage extends StatefulWidget {
  final VoidCallback? onGameFinished;

  const WordlePage({super.key, this.onGameFinished});

  @override
  State<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends State<WordlePage> {
  final WordleGameLogic game = WordleGameLogic();

  @override
  void initState() {
    super.initState();
    game.initGame().then((_) {
      print('🕹️ Game initialized');
      if (game.gameEnded) {
        print('⛔ Game already ended. Starting cooldown timer...');
        game.updateCooldownTimer(() => setState(() {}));
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    game.dispose();
    print('🧹 Game disposed');
    super.dispose();
  }

  void _onKeyTap(String key) async {
    if (!game.canPlay()) {
      print('⛔ Game is not playable now');
      return;
    }

    print('⌨️ Key tapped: $key');
    setState(() {
      game.tapKey(key);
    });

    if (key == 'ENTER') {
      String guess = game.guesses[game.currentRow];
      print('📤 Submitting guess: $guess');

      if (guess.length == 5) {
        final message = await game.submitGuess(guess);

        if (message != null) {
          print('📢 Result message: $message');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }

        // ✅ إذا انتهت اللعبة، سجل الإحصائيات
        if (game.gameEnded) {
          print('✅ Game ended! Updating stats...');
          UserStats.updateStats(
            total: UserStats.totalGames + 1,
            first: UserStats.winsFirstTry,
            second: UserStats.winsSecondTry,
            third: UserStats.winsThirdTry,
            fourth: UserStats.winsFourthTry,
            loss: UserStats.losses,
            completed: 0,
            titles: [],
          );

          widget.onGameFinished?.call();
        }

        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Wordle Game'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Expanded(
                flex: 2,
                child: WordleGrid(
                  guesses: game.guesses.map((g) => g.split('')).toList(),
                  results: game.results,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 90.0),
                    child: Column(
                      children: [
                        KeyboardWidget(
                          keyStatus: game.keyStatus,
                          onKeyTap: _onKeyTap,
                        ),
                        if (game.gameEnded) ...[
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              print('📊 Opening stats modal');
                              showModalBottomSheet(
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
                            icon: const Icon(
                              Icons.bar_chart,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'View Stats',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '⏳ Come back in: ${game.formatDuration(game.cooldownLeft)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
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
