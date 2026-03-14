import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:writdle/domain/entities/word_generator_time.dart';
import 'package:writdle/presentation/bloc/app_settings_cubit.dart';

enum LetterStatus { correct, present, absent, initial }

class WordleGameLogic {
  WordleGameLogic() {
    _configureBoard(GameDifficulty.normal.attempts);
  }

  static const _stateKey = 'wordle_state_v3';
  static const _lastPlayedKey = 'wordle_last_played';

  late String correctWord;
  late List<String> guesses;
  late List<List<LetterStatus>> results;
  final Map<String, LetterStatus> keyStatus = {};

  int currentRow = 0;
  bool gameEnded = false;
  bool isReadyForManualRestart = false;
  Duration cooldownLeft = Duration.zero;
  Timer? timer;
  String? latestResultMessage;
  int maxAttempts = GameDifficulty.normal.attempts;
  int cooldownHours = 12;
  GameDifficulty difficulty = GameDifficulty.normal;

  int _attemptResult = -1;
  int get resultAttempt => _attemptResult;
  bool get didWin => _attemptResult > 0;

  void _configureBoard(int attempts) {
    maxAttempts = attempts;
    guesses = List.filled(attempts, '');
    results = List.generate(
      attempts,
      (_) => List.filled(5, LetterStatus.initial),
    );
  }

  Future<void> initGame({
    required bool requireManualRestart,
    required GameDifficulty difficulty,
    required int cooldownHours,
  }) async {
    this.difficulty = difficulty;
    this.cooldownHours = cooldownHours;
    _configureBoard(difficulty.attempts);

    final prefs = await SharedPreferences.getInstance();
    final todayWord = WordGenerator.getWordOfTheDay();
    final rawState = prefs.getString(_stateKey);

    if (rawState != null) {
      final decoded = jsonDecode(rawState) as Map<String, dynamic>;
      final savedWord = decoded['correctWord'] as String?;
      final savedAttempts = decoded['maxAttempts'] as int?;
      final savedCooldownHours = decoded['cooldownHours'] as int?;
      if (savedWord == todayWord &&
          savedAttempts == maxAttempts &&
          savedCooldownHours == cooldownHours) {
        _restoreState(decoded);
        await _refreshCooldownState(requireManualRestart: requireManualRestart);
        return;
      }
    }

    final lastPlayed = prefs.getInt(_lastPlayedKey);
    if (lastPlayed != null) {
      final remaining = _remainingCooldown(lastPlayed);
      if (remaining > Duration.zero) {
        correctWord = todayWord;
        latestResultMessage = 'Come back after the countdown for the next round.';
        gameEnded = true;
        cooldownLeft = remaining;
        isReadyForManualRestart = false;
        await _persistState();
        return;
      }

      if (requireManualRestart) {
        correctWord = todayWord;
        gameEnded = true;
        cooldownLeft = Duration.zero;
        isReadyForManualRestart = true;
        latestResultMessage = 'A new round is ready. Start when you want.';
        await _persistState();
        return;
      }
    }

    await restartGame();
  }

  Future<void> restartGame() async {
    _configureBoard(difficulty.attempts);
    correctWord = WordGenerator.getWordOfTheDay();
    currentRow = 0;
    gameEnded = false;
    isReadyForManualRestart = false;
    cooldownLeft = Duration.zero;
    latestResultMessage = null;
    _attemptResult = -1;
    keyStatus.clear();

    await _persistState();
  }

  Future<void> _refreshCooldownState({required bool requireManualRestart}) async {
    if (!gameEnded) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastPlayed = prefs.getInt(_lastPlayedKey);
    if (lastPlayed == null) {
      return;
    }

    final remaining = _remainingCooldown(lastPlayed);
    cooldownLeft = remaining;

    if (remaining == Duration.zero) {
      if (requireManualRestart) {
        isReadyForManualRestart = true;
        latestResultMessage = 'Your saved result is here. Start a new round when you are ready.';
      } else {
        await restartGame();
        return;
      }
    }

    await _persistState();
  }

  Duration _remainingCooldown(int lastPlayed) {
    final cooldown = Duration(hours: cooldownHours);
    final playedAt = DateTime.fromMillisecondsSinceEpoch(lastPlayed);
    final endAt = playedAt.add(cooldown);
    final remaining = endAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void updateCooldownTimer({
    required bool requireManualRestart,
    required void Function() callback,
  }) {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (cooldownLeft <= const Duration(seconds: 1)) {
        timer?.cancel();
        cooldownLeft = Duration.zero;
        if (requireManualRestart) {
          isReadyForManualRestart = true;
          latestResultMessage = 'The next round is ready. Tap restart when you want.';
          await _persistState();
          callback();
        } else {
          await restartGame();
          callback();
        }
      } else {
        cooldownLeft -= const Duration(seconds: 1);
        callback();
      }
    });
  }

  void dispose() {
    timer?.cancel();
  }

  bool canPlay() => !gameEnded && currentRow < guesses.length;

  Future<void> tapKey(String key) async {
    if (!canPlay()) {
      return;
    }

    final currentGuess = guesses[currentRow];

    if (key == 'BACK') {
      if (currentGuess.isNotEmpty) {
        guesses[currentRow] = currentGuess.substring(0, currentGuess.length - 1);
        await _persistState();
      }
      return;
    }

    if (key == 'ENTER') {
      return;
    }

    if (currentGuess.length < 5) {
      guesses[currentRow] = currentGuess + key;
      await _persistState();
    }
  }

  Future<String?> submitCurrentGuess() async {
    final guess = guesses[currentRow];
    if (guess.length != 5) {
      return 'Enter a full 5-letter word.';
    }
    return submitGuess(guess);
  }

  Future<String?> submitGuess(String guess) async {
    final upperGuess = guess.toUpperCase();
    final status = List<LetterStatus>.filled(5, LetterStatus.absent);
    final used = List<bool>.filled(5, false);

    for (int i = 0; i < 5; i++) {
      if (upperGuess[i] == correctWord[i]) {
        status[i] = LetterStatus.correct;
        used[i] = true;
      }
    }

    for (int i = 0; i < 5; i++) {
      if (status[i] == LetterStatus.correct) {
        continue;
      }
      for (int j = 0; j < 5; j++) {
        if (!used[j] && upperGuess[i] == correctWord[j]) {
          status[i] = LetterStatus.present;
          used[j] = true;
          break;
        }
      }
    }

    for (int i = 0; i < 5; i++) {
      final letter = upperGuess[i];
      final currentStatus = keyStatus[letter];
      if (status[i] == LetterStatus.correct ||
          (status[i] == LetterStatus.present && currentStatus != LetterStatus.correct)) {
        keyStatus[letter] = status[i];
      } else if (currentStatus == null) {
        keyStatus[letter] = status[i];
      }
    }

    guesses[currentRow] = upperGuess;
    results[currentRow] = status;

    if (upperGuess == correctWord) {
      await _endGame(currentRow + 1);
      latestResultMessage = 'Brilliant! You solved it in ${currentRow + 1} attempt(s).';
      await _persistState();
      return latestResultMessage;
    }

    if (currentRow >= guesses.length - 1) {
      await _endGame(0);
      latestResultMessage = 'Round finished. The word was $correctWord.';
      await _persistState();
      return latestResultMessage;
    }

    currentRow++;
    latestResultMessage = 'Keep going. You still have ${guesses.length - currentRow} tries.';
    await _persistState();
    return null;
  }

  Future<void> _endGame(int attempt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPlayedKey, DateTime.now().millisecondsSinceEpoch);

    _attemptResult = attempt;
    gameEnded = true;
    isReadyForManualRestart = false;
    cooldownLeft = Duration(hours: cooldownHours);
    await _persistState();
  }

  Future<void> _persistState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _stateKey,
      jsonEncode({
        'correctWord': correctWord,
        'guesses': guesses,
        'results': results
            .map((row) => row.map((item) => item.index).toList())
            .toList(),
        'keyStatus': keyStatus.map((key, value) => MapEntry(key, value.index)),
        'currentRow': currentRow,
        'gameEnded': gameEnded,
        'isReadyForManualRestart': isReadyForManualRestart,
        'attemptResult': _attemptResult,
        'latestResultMessage': latestResultMessage,
        'maxAttempts': maxAttempts,
        'cooldownHours': cooldownHours,
      }),
    );
  }

  void _restoreState(Map<String, dynamic> json) {
    correctWord = json['correctWord'] as String? ?? WordGenerator.getWordOfTheDay();

    final savedGuesses = List<String>.from(json['guesses'] as List<dynamic>? ?? []);
    for (var index = 0; index < guesses.length; index++) {
      guesses[index] = index < savedGuesses.length ? savedGuesses[index] : '';
    }

    final savedResults = List<List<dynamic>>.from(json['results'] as List<dynamic>? ?? []);
    for (var row = 0; row < results.length; row++) {
      if (row < savedResults.length) {
        final statuses = savedResults[row];
        results[row] = List.generate(
          5,
          (index) => LetterStatus.values[(statuses[index] as int?) ?? 3],
        );
      } else {
        results[row] = List.filled(5, LetterStatus.initial);
      }
    }

    keyStatus.clear();
    final savedKeyStatus = Map<String, dynamic>.from(json['keyStatus'] as Map? ?? {});
    for (final entry in savedKeyStatus.entries) {
      keyStatus[entry.key] = LetterStatus.values[(entry.value as int?) ?? 3];
    }

    currentRow = json['currentRow'] as int? ?? 0;
    gameEnded = json['gameEnded'] as bool? ?? false;
    isReadyForManualRestart = json['isReadyForManualRestart'] as bool? ?? false;
    _attemptResult = json['attemptResult'] as int? ?? -1;
    latestResultMessage = json['latestResultMessage'] as String?;
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
