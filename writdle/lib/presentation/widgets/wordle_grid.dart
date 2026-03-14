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
        const horizontalSpacing = 5.0;
        const verticalSpacing = 3.0;
        final tileSize = ((availableWidth - (5 * 2 * horizontalSpacing)) / 5)
            .clamp(26.0, 46.0);

        final gridWidth = (tileSize * 5) + (5 * 2 * horizontalSpacing);

        return FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: gridWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(results.length, (row) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (col) {
                    final letter = col < guesses[row].length
                        ? guesses[row][col].toUpperCase()
                        : '';
                    final status = results[row][col];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(
                        horizontal: horizontalSpacing,
                        vertical: verticalSpacing,
                      ),
                      width: tileSize,
                      height: tileSize,
                      decoration: BoxDecoration(
                        color: _getColor(status),
                        border: Border.all(
                          color: status == LetterStatus.initial
                              ? Theme.of(context).colorScheme.outlineVariant
                              : _getColor(status),
                        ),
                        borderRadius: BorderRadius.circular(tileSize * 0.22),
                      ),
                      child: Center(
                        child: FittedBox(
                          child: Text(
                            letter,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
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
