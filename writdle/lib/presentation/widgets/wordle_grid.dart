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
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final tileSize = ((availableWidth - 40) / 5).clamp(36.0, 50.0);
        final spacing = tileSize >= 46 ? 5.0 : 3.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(results.length, (row) {
            return Padding(
              padding: EdgeInsets.only(bottom: spacing * 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (col) {
                  final letter = col < guesses[row].length
                      ? guesses[row][col].toUpperCase()
                      : '';
                  final status = results[row][col];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: EdgeInsets.all(spacing),
                    width: tileSize,
                    height: tileSize,
                    decoration: BoxDecoration(
                      color: _getColor(status),
                      border: Border.all(
                        color: status == LetterStatus.initial
                            ? Theme.of(context).colorScheme.outlineVariant
                            : _getColor(status),
                      ),
                      borderRadius: BorderRadius.circular(tileSize * 0.24),
                    ),
                    child: Center(
                      child: FittedBox(
                        child: Text(
                          letter,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        );
      },
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
