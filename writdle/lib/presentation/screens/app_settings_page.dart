import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/app_localizations.dart';
import 'package:writdle/presentation/bloc/app_settings_cubit.dart';
import 'package:writdle/presentation/widgets/settings/appearance_settings_panel.dart';
import 'package:writdle/presentation/widgets/settings/settings_about_panel.dart';
import 'package:writdle/presentation/widgets/settings/settings_section_card.dart';

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          AppearanceSettingsPanel(),
          SizedBox(height: 18),
          _InlineGameSettingsPanel(),
          SizedBox(height: 18),
          SettingsAboutPanel(),
        ],
      ),
    );
  }
}

class _InlineGameSettingsPanel extends StatelessWidget {
  const _InlineGameSettingsPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String difficultyLabel(GameDifficulty difficulty) {
      if (l10n.locale.languageCode == 'ar') {
        return switch (difficulty) {
          GameDifficulty.easy => 'سهل',
          GameDifficulty.normal => 'عادي',
          GameDifficulty.hard => 'صعب',
        };
      }

      return difficulty.label;
    }
    final settings = context.watch<AppSettingsCubit>().state;
    final reminderTime = TimeOfDay(
      hour: settings.gameReminderHour,
      minute: settings.gameReminderMinute,
    );
    final formattedReminderTime = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(reminderTime);

    return SettingsSectionCard(
      title: l10n.t('wordle_setup'),
      children: [
        DropdownButtonFormField<GameDifficulty>(
          initialValue: settings.gameDifficulty,
          decoration: InputDecoration(
            labelText: l10n.t('difficulty_level'),
            prefixIcon: Icon(Icons.speed_rounded),
          ),
          items: GameDifficulty.values
              .map(
                (difficulty) => DropdownMenuItem(
                  value: difficulty,
                  child: Text(
                    '${difficultyLabel(difficulty)} - ${difficulty.attempts}',
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<AppSettingsCubit>().setGameDifficulty(value);
            }
          },
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(
          initialValue: settings.gameCooldownHours,
          decoration: InputDecoration(
            labelText: l10n.t('next_round_time'),
            prefixIcon: Icon(Icons.schedule_rounded),
          ),
          items: [
            DropdownMenuItem(value: 6, child: Text(l10n.t('every_6_hours'))),
            DropdownMenuItem(value: 12, child: Text(l10n.t('every_12_hours'))),
            DropdownMenuItem(value: 24, child: Text(l10n.t('every_24_hours'))),
          ],
          onChanged: (value) {
            if (value != null) {
              context.read<AppSettingsCubit>().setGameCooldownHours(value);
            }
          },
        ),
        const SizedBox(height: 14),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: settings.gameReminderEnabled,
          onChanged: (value) {
            context.read<AppSettingsCubit>().setGameReminderEnabled(value);
          },
          title: Text(l10n.t('daily_game_reminder')),
          subtitle: Text(l10n.t('daily_game_reminder_subtitle')),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          enabled: settings.gameReminderEnabled,
          leading: const Icon(Icons.alarm_rounded),
          title: Text(l10n.t('reminder_time')),
          subtitle: Text(formattedReminderTime),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: !settings.gameReminderEnabled
              ? null
              : () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: reminderTime,
                  );
                  if (picked == null || !context.mounted) {
                    return;
                  }
                  await context.read<AppSettingsCubit>().setGameReminderTime(
                    hour: picked.hour,
                    minute: picked.minute,
                  );
                },
        ),
        const SizedBox(height: 12),
        Text(
          l10n.t('wordle_setup_help'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: settings.competitiveGameUi,
          onChanged: (value) {
            context.read<AppSettingsCubit>().setCompetitiveGameUi(value);
          },
          title: Text(l10n.t('competitive_layout')),
          subtitle: Text(l10n.t('competitive_layout_subtitle')),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: settings.highContrastGame,
          onChanged: (value) {
            context.read<AppSettingsCubit>().setHighContrastGame(value);
          },
          title: Text(l10n.t('high_contrast_colors')),
          subtitle: Text(l10n.t('high_contrast_colors_subtitle')),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: settings.requireManualGameRestart,
          onChanged: (value) {
            context.read<AppSettingsCubit>().setRequireManualGameRestart(value);
          },
          title: Text(l10n.t('manual_restart_only')),
          subtitle: Text(l10n.t('manual_restart_only_subtitle')),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: settings.showGameHints,
          onChanged: (value) {
            context.read<AppSettingsCubit>().setShowGameHints(value);
          },
          title: Text(l10n.t('show_gameplay_hints')),
          subtitle: Text(l10n.t('show_gameplay_hints_subtitle')),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: settings.showAttemptBadge,
          onChanged: (value) {
            context.read<AppSettingsCubit>().setShowAttemptBadge(value);
          },
          title: Text(l10n.t('show_attempt_badge')),
          subtitle: Text(l10n.t('show_attempt_badge_subtitle')),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: settings.showCountdownBadge,
          onChanged: (value) {
            context.read<AppSettingsCubit>().setShowCountdownBadge(value);
          },
          title: Text(l10n.t('show_countdown_badge')),
          subtitle: Text(l10n.t('show_countdown_badge_subtitle')),
        ),
      ],
    );
  }
}
