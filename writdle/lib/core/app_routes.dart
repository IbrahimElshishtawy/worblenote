import 'package:flutter/material.dart';
import 'package:writdle/core/app_navigation.dart';
import 'package:writdle/presentation/screens/Splash_Screen_page.dart';
import 'package:writdle/presentation/screens/app_settings_page.dart';
import 'package:writdle/presentation/screens/home_page.dart';
import 'package:writdle/presentation/screens/login_page.dart';
import 'package:writdle/presentation/screens/task_page.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = _pageFor(settings);
    if (page == null) {
      return AppNavigation.page(
        const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
        settings: settings,
      );
    }

    final name = settings.name ?? '';
    final useScale =
        name == '/login' || name == '/register' || name == '/splash';

    return AppNavigation.page(
      page,
      settings: settings,
      useScale: useScale,
    );
  }

  static Widget? _pageFor(RouteSettings settings) {
    return switch (settings.name) {
      '/splash' => const SplashScreen(),
      '/home' => const HomePage(),
      '/login' => const LoginPage(),
      '/register' => const LoginPage(),
      '/welcome-profile' => const LoginPage(),
      '/games' => const HomePage(initialIndex: 1),
      '/notes' => const HomePage(initialIndex: 2),
      '/activity' => const HomePage(initialIndex: 3),
      '/profile' => const HomePage(initialIndex: 4),
      '/calendar' => TasksPage(selectedDay: DateTime.now()),
      '/settings' => const AppSettingsPage(),
      _ => null,
    };
  }
}
