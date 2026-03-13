import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/presentation/bloc/app_settings_cubit.dart';
import 'package:writdle/presentation/bloc/theme_cubit.dart';
import 'package:writdle/presentation/widgets/settings/settings_section_card.dart';

class AppearanceSettingsPanel extends StatelessWidget {
  const AppearanceSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsCubit>().state;
    final themeMode = context.watch<ThemeCubit>().state;

    return SettingsSectionCard(
      title: 'Appearance',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Theme mode'),
          subtitle: const Text('Choose how the whole app looks.'),
          trailing: DropdownButton<ThemeMode>(
            value: themeMode,
            items: const [
              DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
              DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
            ],
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeCubit>().setTheme(value);
              }
            },
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Text size'),
          subtitle: Text('Current scale: ${settings.textScale.toStringAsFixed(2)}x'),
        ),
        Slider(
          value: settings.textScale,
          min: 0.9,
          max: 1.35,
          divisions: 9,
          label: settings.textScale.toStringAsFixed(2),
          onChanged: (value) {
            context.read<AppSettingsCubit>().setTextScale(value);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: settings.reduceMotion,
          onChanged: (value) {
            context.read<AppSettingsCubit>().setReduceMotion(value);
          },
          title: const Text('Reduce motion'),
          subtitle: const Text('Use calmer transitions and animations.'),
        ),
      ],
    );
  }
}
