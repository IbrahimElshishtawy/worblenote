import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writdle/core/notifications/local_notification_service.dart';

enum GameDifficulty { easy, normal, hard }

enum AppLanguage { english, arabic }

extension AppLanguageX on AppLanguage {
  String get storageValue {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.arabic:
        return 'ar';
    }
  }

  static AppLanguage fromStorage(String? value) {
    switch (value) {
      case 'ar':
        return AppLanguage.arabic;
      default:
        return AppLanguage.english;
    }
  }
}

extension GameDifficultyX on GameDifficulty {
  String get storageValue {
    switch (this) {
      case GameDifficulty.easy:
        return 'easy';
      case GameDifficulty.normal:
        return 'normal';
      case GameDifficulty.hard:
        return 'hard';
    }
  }

  String get label {
    switch (this) {
      case GameDifficulty.easy:
        return 'Easy';
      case GameDifficulty.normal:
        return 'Normal';
      case GameDifficulty.hard:
        return 'Hard';
    }
  }

  int get attempts {
    switch (this) {
      case GameDifficulty.easy:
        return 6;
      case GameDifficulty.normal:
        return 5;
      case GameDifficulty.hard:
        return 4;
    }
  }

  static GameDifficulty fromStorage(String? value) {
    switch (value) {
      case 'easy':
        return GameDifficulty.easy;
      case 'hard':
        return GameDifficulty.hard;
      default:
        return GameDifficulty.normal;
    }
  }
}

class AppSettingsState {
  const AppSettingsState({
    this.language = AppLanguage.english,
    this.textScale = 1.0,
    this.highContrastGame = false,
    this.reduceMotion = false,
    this.requireManualGameRestart = true,
    this.showGameHints = true,
    this.competitiveGameUi = true,
    this.showAttemptBadge = true,
    this.showCountdownBadge = true,
    this.gameDifficulty = GameDifficulty.normal,
    this.gameCooldownHours = 12,
    this.gameReminderEnabled = false,
    this.gameReminderHour = 20,
    this.gameReminderMinute = 0,
  });

  final AppLanguage language;
  final double textScale;
  final bool highContrastGame;
  final bool reduceMotion;
  final bool requireManualGameRestart;
  final bool showGameHints;
  final bool competitiveGameUi;
  final bool showAttemptBadge;
  final bool showCountdownBadge;
  final GameDifficulty gameDifficulty;
  final int gameCooldownHours;
  final bool gameReminderEnabled;
  final int gameReminderHour;
  final int gameReminderMinute;

  AppSettingsState copyWith({
    AppLanguage? language,
    double? textScale,
    bool? highContrastGame,
    bool? reduceMotion,
    bool? requireManualGameRestart,
    bool? showGameHints,
    bool? competitiveGameUi,
    bool? showAttemptBadge,
    bool? showCountdownBadge,
    GameDifficulty? gameDifficulty,
    int? gameCooldownHours,
    bool? gameReminderEnabled,
    int? gameReminderHour,
    int? gameReminderMinute,
  }) {
    return AppSettingsState(
      language: language ?? this.language,
      textScale: textScale ?? this.textScale,
      highContrastGame: highContrastGame ?? this.highContrastGame,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      requireManualGameRestart:
          requireManualGameRestart ?? this.requireManualGameRestart,
      showGameHints: showGameHints ?? this.showGameHints,
      competitiveGameUi: competitiveGameUi ?? this.competitiveGameUi,
      showAttemptBadge: showAttemptBadge ?? this.showAttemptBadge,
      showCountdownBadge: showCountdownBadge ?? this.showCountdownBadge,
      gameDifficulty: gameDifficulty ?? this.gameDifficulty,
      gameCooldownHours: gameCooldownHours ?? this.gameCooldownHours,
      gameReminderEnabled: gameReminderEnabled ?? this.gameReminderEnabled,
      gameReminderHour: gameReminderHour ?? this.gameReminderHour,
      gameReminderMinute: gameReminderMinute ?? this.gameReminderMinute,
    );
  }
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit() : super(const AppSettingsState()) {
    load();
  }

  static const _languageKey = 'app_language';
  static const _textScaleKey = 'app_text_scale';
  static const _highContrastGameKey = 'app_high_contrast_game';
  static const _reduceMotionKey = 'app_reduce_motion';
  static const _manualRestartKey = 'app_manual_restart';
  static const _showGameHintsKey = 'app_show_game_hints';
  static const _competitiveGameUiKey = 'app_competitive_game_ui';
  static const _showAttemptBadgeKey = 'app_show_attempt_badge';
  static const _showCountdownBadgeKey = 'app_show_countdown_badge';
  static const _gameDifficultyKey = 'app_game_difficulty';
  static const _gameCooldownHoursKey = 'app_game_cooldown_hours';
  static const _gameReminderEnabledKey = 'app_game_reminder_enabled';
  static const _gameReminderHourKey = 'app_game_reminder_hour';
  static const _gameReminderMinuteKey = 'app_game_reminder_minute';

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final nextState = AppSettingsState(
      language: AppLanguageX.fromStorage(
        preferences.getString(_languageKey),
      ),
      textScale: preferences.getDouble(_textScaleKey) ?? 1.0,
      highContrastGame: preferences.getBool(_highContrastGameKey) ?? false,
      reduceMotion: preferences.getBool(_reduceMotionKey) ?? false,
      requireManualGameRestart: preferences.getBool(_manualRestartKey) ?? true,
      showGameHints: preferences.getBool(_showGameHintsKey) ?? true,
      competitiveGameUi: preferences.getBool(_competitiveGameUiKey) ?? true,
      showAttemptBadge: preferences.getBool(_showAttemptBadgeKey) ?? true,
      showCountdownBadge: preferences.getBool(_showCountdownBadgeKey) ?? true,
      gameDifficulty: GameDifficultyX.fromStorage(
        preferences.getString(_gameDifficultyKey),
      ),
      gameCooldownHours: preferences.getInt(_gameCooldownHoursKey) ?? 12,
      gameReminderEnabled:
          preferences.getBool(_gameReminderEnabledKey) ?? false,
      gameReminderHour: preferences.getInt(_gameReminderHourKey) ?? 20,
      gameReminderMinute: preferences.getInt(_gameReminderMinuteKey) ?? 0,
    );

    emit(nextState);
    await _syncGameReminder(nextState);
  }

  Future<void> setLanguage(AppLanguage value) async {
    emit(state.copyWith(language: value));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, value.storageValue);
  }

  Future<void> setTextScale(double value) async {
    emit(state.copyWith(textScale: value));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_textScaleKey, value);
  }

  Future<void> setHighContrastGame(bool value) async {
    emit(state.copyWith(highContrastGame: value));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_highContrastGameKey, value);
  }

  Future<void> setReduceMotion(bool value) async {
    emit(state.copyWith(reduceMotion: value));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_reduceMotionKey, value);
  }

  Future<void> setRequireManualGameRestart(bool value) async {
    emit(state.copyWith(requireManualGameRestart: value));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_manualRestartKey, value);
  }

  Future<void> setShowGameHints(bool value) async {
    emit(state.copyWith(showGameHints: value));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_showGameHintsKey, value);
  }

  Future<void> setCompetitiveGameUi(bool value) async {
    emit(state.copyWith(competitiveGameUi: value));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_competitiveGameUiKey, value);
  }

  Future<void> setShowAttemptBadge(bool value) async {
    emit(state.copyWith(showAttemptBadge: value));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_showAttemptBadgeKey, value);
  }

  Future<void> setShowCountdownBadge(bool value) async {
    emit(state.copyWith(showCountdownBadge: value));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_showCountdownBadgeKey, value);
  }

  Future<void> setGameDifficulty(GameDifficulty value) async {
    emit(state.copyWith(gameDifficulty: value));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_gameDifficultyKey, value.storageValue);
  }

  Future<void> setGameCooldownHours(int value) async {
    emit(state.copyWith(gameCooldownHours: value));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_gameCooldownHoursKey, value);
  }

  Future<void> setGameReminderEnabled(bool value) async {
    final nextState = state.copyWith(gameReminderEnabled: value);
    emit(nextState);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_gameReminderEnabledKey, value);
    await _syncGameReminder(nextState);
  }

  Future<void> setGameReminderTime({
    required int hour,
    required int minute,
  }) async {
    final nextState = state.copyWith(
      gameReminderHour: hour,
      gameReminderMinute: minute,
    );
    emit(nextState);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_gameReminderHourKey, hour);
    await preferences.setInt(_gameReminderMinuteKey, minute);
    await _syncGameReminder(nextState);
  }

  Future<void> _syncGameReminder(AppSettingsState settings) async {
    if (!settings.gameReminderEnabled) {
      await LocalNotificationService.instance.cancel(
        LocalNotificationService.gameReminderNotificationId,
      );
      return;
    }

    await LocalNotificationService.instance.scheduleDailyGameReminder(
      hour: settings.gameReminderHour,
      minute: settings.gameReminderMinute,
    );
  }
}
