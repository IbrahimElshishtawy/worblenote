import 'package:flutter/material.dart';
import 'package:writdle/presentation/widgets/settings/appearance_settings_panel.dart';
import 'package:writdle/presentation/widgets/settings/game_settings_panel.dart';
import 'package:writdle/presentation/widgets/settings/settings_about_panel.dart';

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
          GameSettingsPanel(),
          SizedBox(height: 18),
          SettingsAboutPanel(),
        ],
      ),
    );
  }
}
