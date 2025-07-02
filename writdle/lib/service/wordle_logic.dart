class WordleLogic {
  final String targetWord;

  WordleLogic(this.targetWord);

  List<String> validateGuess(String guess) {
    if (guess.length != targetWord.length) {
      throw Exception('Guess must be ${targetWord.length} characters long');
    }

    List<String> result = [];
    for (int i = 0; i < guess.length; i++) {
      if (guess[i] == targetWord[i]) {
        result.add('correct');
      } else if (targetWord.contains(guess[i])) {
        result.add('present');
      } else {
        result.add('absent');
      }
    }
    return result;
  }

  bool isCorrect(String guess) {
    return guess == targetWord;
  }
}
