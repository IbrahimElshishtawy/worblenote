import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/app_localizations.dart';
import 'package:writdle/presentation/bloc/app_settings_cubit.dart';
import 'package:writdle/presentation/bloc/theme_cubit.dart';
import 'package:writdle/presentation/widgets/settings/settings_section_card.dart';

class AppearanceSettingsPanel extends StatelessWidget {
  const AppearanceSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.watch<AppSettingsCubit>().state;
    final themeMode = context.watch<ThemeCubit>().state;

    return SettingsSectionCard(
      title: l10n.t('appearance'),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.t('language')),
          subtitle: Text(l10n.t('theme_mode_subtitle')),
          trailing: DropdownButton<AppLanguage>(
            value: settings.language,
            items: [
              DropdownMenuItem(
                value: AppLanguage.english,
                child: Text(l10n.t('english')),
              ),
              DropdownMenuItem(
                value: AppLanguage.arabic,
                child: Text(l10n.t('arabic')),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                context.read<AppSettingsCubit>().setLanguage(value);
              }
            },
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.t('theme_mode')),
          subtitle: Text(l10n.t('theme_mode_subtitle')),
          trailing: DropdownButton<ThemeMode>(
            value: themeMode,
            items: [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text(l10n.t('system')),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text(l10n.t('light')),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text(l10n.t('dark')),
              ),
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
          title: Text(l10n.t('text_size')),
          subtitle: Text(
            l10n.t(
              'current_scale',
              {'value': settings.textScale.toStringAsFixed(2)},
            ),
          ),
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
          title: Text(l10n.t('reduce_motion')),
          subtitle: Text(l10n.t('reduce_motion_subtitle')),
        ),
      ],
    );
  }
}
