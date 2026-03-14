import 'package:flutter/material.dart';
import 'package:writdle/presentation/widgets/settings/settings_section_card.dart';

class SettingsAboutPanel extends StatelessWidget {
  const SettingsAboutPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SettingsSectionCard(
      title: 'About preferences',
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'These settings are saved on the device and applied across the app, including theme, text size, and gameplay behavior.',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.14),
            ),
          ),
          child: Text(
            'Developed by Ibrahim Elshishtawy',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
