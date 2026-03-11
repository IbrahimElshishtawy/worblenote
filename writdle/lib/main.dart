// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';
import 'package:writdle/domain/repositories/note_repository.dart';
import 'package:writdle/domain/repositories/task_repository.dart';
import 'package:writdle/data/repositories/auth_repository_impl.dart';
import 'package:writdle/data/repositories/note_repository_impl.dart';
import 'package:writdle/data/repositories/task_repository_impl.dart';
import 'package:writdle/presentation/providers/auth_provider.dart';
import 'package:writdle/presentation/providers/user_stats_provider.dart';
import 'package:writdle/presentation/providers/notes_provider.dart';
import 'package:writdle/presentation/providers/tasks_provider.dart';
import 'package:writdle/presentation/screens/Splash_Screen_page.dart';
import 'package:writdle/presentation/screens/home_page.dart';
import 'package:writdle/presentation/screens/login_page.dart';
import 'package:writdle/presentation/screens/register_page.dart';
import 'package:writdle/presentation/screens/activity_page.dart';
import 'package:writdle/presentation/screens/note_page.dart';
import 'package:writdle/presentation/screens/games_page.dart';
import 'package:writdle/presentation/screens/task_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Repositories
  final authRepository = AuthRepositoryImpl();
  final noteRepository = NoteRepositoryImpl();
  final taskRepository = TaskRepositoryImpl();

  runApp(
    MultiProvider(
      providers: [
        Provider<IAuthRepository>.value(value: authRepository),
        Provider<INoteRepository>.value(value: noteRepository),
        Provider<ITaskRepository>.value(value: taskRepository),
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(create: (_) => UserStatsProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider(noteRepository)),
        ChangeNotifierProvider(create: (_) => TasksProvider(taskRepository)),
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
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
          surface: const Color(0xFF121212),
          surfaceContainer: const Color(0xFF1E1E1E),
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
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
