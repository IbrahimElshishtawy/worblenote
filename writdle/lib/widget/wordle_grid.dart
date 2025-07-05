import 'package:flutter/material.dart';
import 'package:writdle/models/wordle_game_logic.dart';

class WordleGrid extends StatelessWidget {
  final List<List<String>> guesses;
  final List<List<LetterStatus>> results;

  const WordleGrid({super.key, required this.guesses, required this.results});

  @override
  Widget build(BuildContext context) {
    debugPrint('🔠 Building WordleGrid...');
    debugPrint('Guesses: $guesses');
    debugPrint('Results: $results');

    int numRows = results.length;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(numRows, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (col) {
            final letter = col < guesses[row].length
                ? guesses[row][col].toUpperCase()
                : '';
            final status = results[row][col];

            debugPrint(
              '🟦 Row $row, Col $col => Letter: "$letter", Status: $status',
            );

            return Container(
              margin: const EdgeInsets.all(4),
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: _getColor(status),
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 24,
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
        return Colors.orange;
      case LetterStatus.absent:
        return Colors.grey.shade800;
      default:
        return Colors.black;
    }
  }
}
