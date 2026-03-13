import 'package:flutter/material.dart';
import 'package:writdle/presentation/widgets/settings/settings_section_card.dart';

class SettingsAboutPanel extends StatelessWidget {
  const SettingsAboutPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsSectionCard(
      title: 'About preferences',
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'These settings are saved on the device and applied across the app, including theme, text size, and gameplay behavior.',
          ),
        ),
      ],
    );
  }
}
