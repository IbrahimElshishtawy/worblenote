import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/presentation/bloc/app_settings_cubit.dart';
import 'package:writdle/presentation/widgets/settings/settings_section_card.dart';

class GameSettingsPanel extends StatelessWidget {
  const GameSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsCubit>().state;

    return SettingsSectionCard(
      title: 'Wordle Setup',
      children: [
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
