class WordleLogic {
  final String targetWord;
  int _currentAttempt = 0;
  final int _maxAttempts = 6;
  int _resultAttempt = -1;

  WordleLogic(this.targetWord);

  int get resultAttempt => _resultAttempt;

  List<String> validateGuess(String guess) {
    if (guess.length != targetWord.length) {
      throw Exception('Guess must be ${targetWord.length} characters long');
    }

    if (isGameOver) {
      throw Exception('Game is already over');
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

    _currentAttempt++;

    if (isCorrect(guess)) {
      _resultAttempt = _currentAttempt;
    } else if (_currentAttempt == _maxAttempts) {
      _resultAttempt = 0;
    }

    return result;
  }

  bool isCorrect(String guess) => guess == targetWord;

  bool get isGameOver => _resultAttempt != -1;
}
