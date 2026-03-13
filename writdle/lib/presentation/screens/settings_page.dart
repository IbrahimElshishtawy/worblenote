import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/presentation/bloc/app_settings_cubit.dart';
import 'package:writdle/presentation/bloc/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, settings) {
          final themeMode = context.watch<ThemeCubit>().state;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SettingsSection(
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
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                title: 'Wordle',
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.highContrastGame,
                    onChanged: (value) {
                      context.read<AppSettingsCubit>().setHighContrastGame(value);
                    },
                    title: const Text('High contrast colors'),
                    subtitle: const Text('Improve letter visibility in the game.'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.requireManualGameRestart,
                    onChanged: (value) {
                      context.read<AppSettingsCubit>().setRequireManualGameRestart(value);
                    },
                    title: const Text('Manual restart only'),
                    subtitle: const Text('Keep finished games saved until you choose to restart.'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.showGameHints,
                    onChanged: (value) {
                      context.read<AppSettingsCubit>().setShowGameHints(value);
                    },
                    title: const Text('Show gameplay hints'),
                    subtitle: const Text('Display guidance below the board and results.'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _SettingsSection(
                title: 'About preferences',
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'These settings are saved on the device and applied across the app, including theme, text size, and gameplay behavior.',
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
