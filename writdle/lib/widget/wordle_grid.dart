import 'package:flutter/cupertino.dart';

class WordleGrid extends StatelessWidget {
  final List<List<String>> guesses;
  final int maxTries;

  const WordleGrid({super.key, required this.guesses, this.maxTries = 6});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(maxTries, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (col) {
            final letter = (row < guesses.length && col < guesses[row].length)
                ? guesses[row][col]
                : '';
            return Container(
              margin: const EdgeInsets.all(4),
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.systemGrey, width: 1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                letter.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
