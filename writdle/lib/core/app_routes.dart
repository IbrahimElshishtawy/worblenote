import 'package:flutter/material.dart';
import 'package:writdle/presentation/screens/Splash_Screen_page.dart';
import 'package:writdle/presentation/screens/activity_page.dart';
import 'package:writdle/presentation/screens/app_settings_page.dart';
import 'package:writdle/presentation/screens/games_page.dart';
import 'package:writdle/presentation/screens/home_page.dart';
import 'package:writdle/presentation/screens/login_page.dart';
import 'package:writdle/presentation/screens/note_page.dart';
import 'package:writdle/presentation/screens/task_page.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = _pageFor(settings);
    if (page == null) {
      return _buildRoute(
        const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
        settings: settings,
      );
    }

    final name = settings.name ?? '';
    final useScale =
        name == '/login' || name == '/register' || name == '/splash';

    return _buildRoute(
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
      '/activity' => const ActivityPage(),
      '/notes' => const NotesPage(),
      '/games' => const WordlePage(),
      '/calendar' => TasksPage(selectedDay: DateTime.now()),
      '/settings' => const AppSettingsPage(),
      _ => null,
    };
  }

  static PageRouteBuilder<dynamic> _buildRoute(
    Widget page, {
    required RouteSettings settings,
    bool useScale = false,
  }) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        if (useScale) {
          final scale = Tween<double>(begin: 0.96, end: 1).animate(fade);
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              child: child,
            ),
          );
        }

        final slide = Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(fade);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: child,
          ),
        );
      },
    );
  }
}
