import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/presentation/bloc/app_settings_cubit.dart';
import 'package:writdle/presentation/widgets/settings/appearance_settings_panel.dart';
import 'package:writdle/presentation/widgets/settings/settings_about_panel.dart';
import 'package:writdle/presentation/widgets/settings/settings_section_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
    final settings = context.watch<AppSettingsCubit>().state;
    final reminderTime = TimeOfDay(
      hour: settings.gameReminderHour,
      minute: settings.gameReminderMinute,
    );
    final formattedReminderTime = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(reminderTime);

    return SettingsSectionCard(
      title: 'Wordle Setup',
      children: [
        DropdownButtonFormField<GameDifficulty>(
          initialValue: settings.gameDifficulty,
          decoration: const InputDecoration(
            labelText: 'Difficulty level',
            prefixIcon: Icon(Icons.speed_rounded),
          ),
          items: GameDifficulty.values
              .map(
                (difficulty) => DropdownMenuItem(
                  value: difficulty,
                  child: Text('${difficulty.label} - ${difficulty.attempts} tries'),
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
          decoration: const InputDecoration(
            labelText: 'Next round time',
            prefixIcon: Icon(Icons.schedule_rounded),
          ),
          items: const [
            DropdownMenuItem(value: 6, child: Text('Every 6 hours')),
            DropdownMenuItem(value: 12, child: Text('Every 12 hours')),
            DropdownMenuItem(value: 24, child: Text('Every 24 hours')),
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
          title: const Text('Daily game reminder'),
          subtitle: const Text('Show a local reminder outside the app every day.'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          enabled: settings.gameReminderEnabled,
          leading: const Icon(Icons.alarm_rounded),
          title: const Text('Reminder time'),
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
          'Difficulty controls the number of attempts. Next round time controls when the game becomes available again after finishing. Daily reminder shows a local notification at your chosen time.',
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
          title: const Text('Competitive layout'),
          subtitle: const Text('Use a sharper, match-style game presentation.'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: settings.highContrastGame,
          onChanged: (value) {
            context.read<AppSettingsCubit>().setHighContrastGame(value);
          },
          title: const Text('High contrast colors'),
          subtitle: const Text('Improve tile and keyboard visibility.'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: settings.requireManualGameRestart,
          onChanged: (value) {
            context.read<AppSettingsCubit>().setRequireManualGameRestart(value);
          },
          title: const Text('Manual restart only'),
          subtitle: const Text('Keep finished rounds until you restart yourself.'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: settings.showGameHints,
          onChanged: (value) {
            context.read<AppSettingsCubit>().setShowGameHints(value);
          },
          title: const Text('Show gameplay hints'),
          subtitle: const Text('Display helper text around results and states.'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: settings.showAttemptBadge,
          onChanged: (value) {
            context.read<AppSettingsCubit>().setShowAttemptBadge(value);
          },
          title: const Text('Show attempt badge'),
          subtitle: const Text('Display the live attempt counter on the game HUD.'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: settings.showCountdownBadge,
          onChanged: (value) {
            context.read<AppSettingsCubit>().setShowCountdownBadge(value);
          },
          title: const Text('Show countdown badge'),
          subtitle: const Text('Display cooldown timer on the game HUD after finishing.'),
        ),
      ],
    );
  }
}
