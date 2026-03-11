// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:writdle/providers/auth_provider.dart';
import 'package:writdle/providers/user_stats_provider.dart';
import 'package:writdle/providers/notes_provider.dart';
import 'package:writdle/providers/tasks_provider.dart';
import 'package:writdle/screen/Splash_Screen_page.dart';
import 'package:writdle/screen/home_page.dart';
import 'package:writdle/screen/login_page.dart';
import 'package:writdle/screen/register_page.dart';
import 'package:writdle/screen/activity_page.dart';
import 'package:writdle/screen/note_page.dart';
import 'package:writdle/screen/games_page.dart';
import 'package:writdle/screen/task_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserStatsProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
      ],
      child: const Writdle(),
    ),
  );
}

class Writdle extends StatelessWidget {
  const Writdle({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Writdle App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
          primary: Colors.deepPurpleAccent,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/activity': (context) => const ActivityPage(),
        '/notes': (context) => const NotesPage(),
        '/games': (context) => const WordlePage(),
        '/calendar': (context) => TasksPage(selectedDay: DateTime.now()),
      },
    );
  }
}
