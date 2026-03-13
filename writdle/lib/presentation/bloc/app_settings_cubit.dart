import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsState {
  const AppSettingsState({
    this.textScale = 1.0,
    this.highContrastGame = false,
    this.reduceMotion = false,
    this.requireManualGameRestart = true,
    this.showGameHints = true,
    this.competitiveGameUi = true,
    this.showAttemptBadge = true,
    this.showCountdownBadge = true,
  });

  final double textScale;
  final bool highContrastGame;
  final bool reduceMotion;
  final bool requireManualGameRestart;
  final bool showGameHints;
  final bool competitiveGameUi;
  final bool showAttemptBadge;
  final bool showCountdownBadge;

  AppSettingsState copyWith({
    double? textScale,
    bool? highContrastGame,
    bool? reduceMotion,
    bool? requireManualGameRestart,
    bool? showGameHints,
    bool? competitiveGameUi,
    bool? showAttemptBadge,
    bool? showCountdownBadge,
  }) {
    return AppSettingsState(
      textScale: textScale ?? this.textScale,
      highContrastGame: highContrastGame ?? this.highContrastGame,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      requireManualGameRestart:
          requireManualGameRestart ?? this.requireManualGameRestart,
      showGameHints: showGameHints ?? this.showGameHints,
      competitiveGameUi: competitiveGameUi ?? this.competitiveGameUi,
      showAttemptBadge: showAttemptBadge ?? this.showAttemptBadge,
      showCountdownBadge: showCountdownBadge ?? this.showCountdownBadge,
    );
  }
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit() : super(const AppSettingsState()) {
    load();
  }

  static const _textScaleKey = 'app_text_scale';
  static const _highContrastGameKey = 'app_high_contrast_game';
  static const _reduceMotionKey = 'app_reduce_motion';
  static const _manualRestartKey = 'app_manual_restart';
  static const _showGameHintsKey = 'app_show_game_hints';
  static const _competitiveGameUiKey = 'app_competitive_game_ui';
  static const _showAttemptBadgeKey = 'app_show_attempt_badge';
  static const _showCountdownBadgeKey = 'app_show_countdown_badge';

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    emit(
      AppSettingsState(
        textScale: preferences.getDouble(_textScaleKey) ?? 1.0,
        highContrastGame: preferences.getBool(_highContrastGameKey) ?? false,
        reduceMotion: preferences.getBool(_reduceMotionKey) ?? false,
        requireManualGameRestart: preferences.getBool(_manualRestartKey) ?? true,
        showGameHints: preferences.getBool(_showGameHintsKey) ?? true,
        competitiveGameUi: preferences.getBool(_competitiveGameUiKey) ?? true,
        showAttemptBadge: preferences.getBool(_showAttemptBadgeKey) ?? true,
        showCountdownBadge: preferences.getBool(_showCountdownBadgeKey) ?? true,
      ),
    );
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
}
