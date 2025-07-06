// ignore_for_file: avoid_print

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writdle/models/word_generator_time.dart';
import 'package:writdle/service/game_stats_service.dart';

enum LetterStatus { correct, present, absent, initial }

class WordleGameLogic {
  late String correctWord;
  bool get didWin => _attemptResult > 0;
  final List<String> guesses = List.filled(4, '');
  final List<List<LetterStatus>> results = List.generate(
    4,
    (_) => List.filled(5, LetterStatus.initial),
  );
  final Map<String, LetterStatus> keyStatus = {};

  int currentRow = 0;
  bool gameEnded = false;
  Duration cooldownLeft = Duration.zero;
  Timer? timer;

  int _attemptResult = -1;
  int get resultAttempt => _attemptResult;

  Future<void> initGame() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPlayed = prefs.getInt('lastPlayed') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const cooldownDuration = 18 * 60 * 60 * 1000;

    final passedTime = now - lastPlayed;
    if (passedTime < cooldownDuration) {
      gameEnded = true;
      cooldownLeft = Duration(milliseconds: cooldownDuration - passedTime);
    } else {
      correctWord = WordGenerator.getWordOfTheDay();
      print("🔤###### Today's Word: $correctWord ##############");
    }
  }

  void updateCooldownTimer(Function callback) {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (cooldownLeft.inSeconds <= 1) {
        timer?.cancel();
      } else {
        cooldownLeft -= const Duration(seconds: 1);
        callback();
      }
    });
  }

  void dispose() {
    timer?.cancel();
  }

  bool canPlay() => !gameEnded && currentRow < 4;

  void tapKey(String key) {
    if (!canPlay()) return;

    String currentGuess = guesses[currentRow];

    if (key == 'EN') {
      evaluateGuess(currentGuess);
    } else if (key == 'DEL') {
      if (currentGuess.isNotEmpty) {
        guesses[currentRow] = currentGuess.substring(
          0,
          currentGuess.length - 1,
        );
      }
    } else {
      if (currentGuess.length < 5) {
        guesses[currentRow] = currentGuess + key;
      }
    }
  }

  Future<String?> submitGuess(String guess) async {
    final status = List<LetterStatus>.filled(5, LetterStatus.absent);
    final used = List<bool>.filled(5, false);

    for (int i = 0; i < 5; i++) {
      if (guess[i] == correctWord[i]) {
        status[i] = LetterStatus.correct;
        used[i] = true;
      }
    }

    for (int i = 0; i < 5; i++) {
      if (status[i] == LetterStatus.correct) continue;
      for (int j = 0; j < 5; j++) {
        if (!used[j] && guess[i] == correctWord[j]) {
          status[i] = LetterStatus.present;
          used[j] = true;
          break;
        }
      }
    }

    for (int i = 0; i < 5; i++) {
      final letter = guess[i];
      final currentStatus = keyStatus[letter];
      if (status[i] == LetterStatus.correct ||
          (status[i] == LetterStatus.present &&
              currentStatus != LetterStatus.correct)) {
        keyStatus[letter] = status[i];
      } else if (currentStatus == null) {
        keyStatus[letter] = status[i];
      }
    }

    results[currentRow] = status;

    if (guess == correctWord) {
      await _endGame(currentRow + 1);
      return '🎉 You win!';
    } else if (currentRow >= 3) {
      await _endGame(0);
      return '❌ You lose! The word was $correctWord';
    } else {
      currentRow++;
      return null;
    }
  }

  Future<void> _endGame(int attempt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastPlayed', DateTime.now().millisecondsSinceEpoch);

    final statsService = GameStatsService();
    await statsService.incrementGame(
      isWin: attempt > 0,
      tryNumber: attempt > 0 ? attempt : null,
    );

    _attemptResult = attempt;
    gameEnded = true;
    cooldownLeft = const Duration(hours: 12);
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  // ✅ الدالة المفعّلة الآن
  void evaluateGuess(String guess) async {
    if (guess.length != 5) return;

    final message = await submitGuess(guess);
    if (message != null) {
      print(message); // أو استخدم Snackbar لعرض الرسالة في الواجهة
    }
  }
}
