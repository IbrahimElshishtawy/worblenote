import 'package:flutter/material.dart';
import 'package:writdle/models/wordle_game_logic.dart';

class WordleGrid extends StatelessWidget {
  final List<List<String>> guesses;
  final List<List<LetterStatus>> results;

  const WordleGrid({super.key, required this.guesses, required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(guesses.length, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (col) {
            final letter = col < guesses[row].length ? guesses[row][col] : '';
            final status = results[row][col];

            return Container(
              margin: const EdgeInsets.all(4),
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: _getColor(status),
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Color _getColor(LetterStatus status) {
    switch (status) {
      case LetterStatus.correct:
        return Colors.green;
      case LetterStatus.present:
        return Colors.amber;
      case LetterStatus.absent:
        return Colors.grey.shade800;
      default:
        return Colors.black;
    }
  }
}
