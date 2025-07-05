// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:writdle/screen/Splash_Screen_page.dart';
import 'package:writdle/screen/home_page.dart';
import 'package:writdle/screen/login_page.dart';
import 'package:writdle/screen/register_page.dart';
import 'package:writdle/screen/profile_page.dart';
import 'package:writdle/screen/activity_page.dart';
import 'package:writdle/screen/note_page.dart';
import 'package:writdle/screen/games_page.dart';
import 'package:writdle/screen/task_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Writdle App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/profile': (context) => const ProfilePage(),
        '/activity': (context) => const ActivityPage(),
        '/notes': (context) => const NotesPage(),
        '/games': (context) => const WordlePage(),
        '/calendar': (context) => TasksPage(selectedDay: DateTime.now()),
      },
    );
  }
}
