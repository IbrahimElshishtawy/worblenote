import 'package:flutter/material.dart';
import 'package:writdle/domain/entities/wordle_game_logic.dart';

class WordleGrid extends StatelessWidget {
  const WordleGrid({
    super.key,
    required this.guesses,
    required this.results,
    this.highContrast = false,
  });

  final List<List<String>> guesses;
  final List<List<LetterStatus>> results;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(results.length, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (col) {
            final letter = col < guesses[row].length ? guesses[row][col].toUpperCase() : '';
            final status = results[row][col];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.all(5),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getColor(status),
                border: Border.all(
                  color: status == LetterStatus.initial
                      ? Theme.of(context).colorScheme.outlineVariant
                      : _getColor(status),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
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
    if (highContrast) {
      switch (status) {
        case LetterStatus.correct:
          return const Color(0xFF0EA5E9);
        case LetterStatus.present:
          return const Color(0xFFF97316);
        case LetterStatus.absent:
          return const Color(0xFF475569);
        case LetterStatus.initial:
          return const Color(0xFF111827);
      }
    }

    switch (status) {
      case LetterStatus.correct:
        return const Color(0xFF16A34A);
      case LetterStatus.present:
        return const Color(0xFFEAB308);
      case LetterStatus.absent:
        return const Color(0xFF374151);
      case LetterStatus.initial:
        return const Color(0xFF111827);
    }
  }
}
