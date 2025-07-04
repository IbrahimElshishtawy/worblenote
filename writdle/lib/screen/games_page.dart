// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:writdle/models/wordle_game_logic.dart';
import 'package:writdle/screen/Stats_games_Page.dart';
import 'package:writdle/widget/keyboard_widget.dart';
import 'package:writdle/widget/wordle_grid.dart';

class WordlePage extends StatefulWidget {
  const WordlePage({super.key});

  @override
  State<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends State<WordlePage> {
  final WordleGameLogic game = WordleGameLogic();

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

  void _onKeyTap(String key) async {
    if (!game.canPlay()) return;

    setState(() {
      game.tapKey(key);
    });

    if (key == 'ENTER') {
      String guess = game.guesses[game.currentRow];
      if (guess.length == 5) {
        final message = await game.submitGuess(guess);
        if (message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          setState(() {});
        }
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
                                  child: StatsPage(resultAttempt: 0),
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
