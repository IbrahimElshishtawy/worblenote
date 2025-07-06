import 'dart:math';

class WordGenerator {
  static const int cycleDays = 100;
  static const int wordLength = 5;
  static const int wordCount = 100;
  static final Random _random = Random();

  static List<String> generateWordsForCycle(int cycleSeed) {
    const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final Set<String> words = {};

    while (words.length < wordCount) {
      String word = '';
      while (word.length < wordLength) {
        String letter = alphabet[_random.nextInt(alphabet.length)];
        if (!word.contains(letter)) {
          word += letter;
        }
      }
      words.add(word);
    }

    return words.toList();
  }

  static String getWordOfTheDay() {
    final now = DateTime.now();
    final baseDate = DateTime(2025, 1, 1);
    final totalDays = now.difference(baseDate).inDays;

    final cycleNumber = totalDays ~/ cycleDays;
    final cycleSeed = cycleNumber;

    final words = generateWordsForCycle(cycleSeed);

    final dailyIndex = totalDays % wordCount;
    return words[dailyIndex];
  }
}
