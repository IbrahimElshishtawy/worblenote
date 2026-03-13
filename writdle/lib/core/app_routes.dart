import 'package:flutter/material.dart';
import 'package:writdle/presentation/screens/Splash_Screen_page.dart';
import 'package:writdle/presentation/screens/activity_page.dart';
import 'package:writdle/presentation/screens/games_page.dart';
import 'package:writdle/presentation/screens/home_page.dart';
import 'package:writdle/presentation/screens/login_page.dart';
import 'package:writdle/presentation/screens/note_page.dart';
import 'package:writdle/presentation/screens/register_page.dart';
import 'package:writdle/presentation/screens/settings_page.dart';
import 'package:writdle/presentation/screens/task_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes() {
    return {
      '/splash': (_) => const SplashScreen(),
      '/home': (_) => const HomePage(),
      '/login': (_) => const LoginPage(),
      '/register': (_) => const RegisterPage(),
      '/activity': (_) => const ActivityPage(),
      '/notes': (_) => const NotesPage(),
      '/games': (_) => const WordlePage(),
      '/calendar': (_) => TasksPage(selectedDay: DateTime.now()),
      '/settings': (_) => const SettingsPage(),
    };
  }
}
