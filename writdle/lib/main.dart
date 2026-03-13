import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/notifications/app_notification_cubit.dart';
import 'package:writdle/core/notifications/local_notification_service.dart';
import 'package:writdle/data/repositories/auth_repository_impl.dart';
import 'package:writdle/data/repositories/note_repository_impl.dart';
import 'package:writdle/data/repositories/profile_repository_impl.dart';
import 'package:writdle/data/repositories/task_repository_impl.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';
import 'package:writdle/domain/repositories/note_repository.dart';
import 'package:writdle/domain/repositories/profile_repository.dart';
import 'package:writdle/domain/repositories/task_repository.dart';
import 'package:writdle/firebase_options.dart';
import 'package:writdle/presentation/bloc/auth_cubit.dart';
import 'package:writdle/presentation/bloc/notes_cubit.dart';
import 'package:writdle/presentation/bloc/profile_cubit.dart';
import 'package:writdle/presentation/bloc/tasks_cubit.dart';
import 'package:writdle/presentation/screens/Splash_Screen_page.dart';
import 'package:writdle/presentation/screens/activity_page.dart';
import 'package:writdle/presentation/screens/games_page.dart';
import 'package:writdle/presentation/screens/home_page.dart';
import 'package:writdle/presentation/screens/login_page.dart';
import 'package:writdle/presentation/screens/note_page.dart';
import 'package:writdle/presentation/screens/register_page.dart';
import 'package:writdle/presentation/screens/task_page.dart';
import 'package:writdle/presentation/widgets/app_notification_listener.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService.instance.initialize();

  final authRepository = AuthRepositoryImpl();
  final noteRepository = NoteRepositoryImpl();
  final taskRepository = TaskRepositoryImpl();
  final profileRepository = ProfileRepositoryImpl();

  runApp(
    Writdle(
      authRepository: authRepository,
      noteRepository: noteRepository,
      taskRepository: taskRepository,
      profileRepository: profileRepository,
    ),
  );
}

class Writdle extends StatelessWidget {
  const Writdle({
    super.key,
    required this.authRepository,
    required this.noteRepository,
    required this.taskRepository,
    required this.profileRepository,
  });

  final IAuthRepository authRepository;
  final INoteRepository noteRepository;
  final ITaskRepository taskRepository;
  final IProfileRepository profileRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthRepository>.value(value: authRepository),
        RepositoryProvider<INoteRepository>.value(value: noteRepository),
        RepositoryProvider<ITaskRepository>.value(value: taskRepository),
        RepositoryProvider<IProfileRepository>.value(value: profileRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AppNotificationCubit()),
          BlocProvider(create: (_) => AuthCubit(authRepository)),
          BlocProvider(create: (_) => NotesCubit(noteRepository)),
          BlocProvider(create: (_) => TasksCubit(taskRepository, profileRepository)),
          BlocProvider(
            create: (_) => ProfileCubit(profileRepository, authRepository),
          ),
        ],
        child: AppNotificationListener(
          child: MaterialApp(
            title: 'Writdle App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(centerTitle: true),
            ),
            initialRoute: '/splash',
            routes: {
              '/splash': (_) => const SplashScreen(),
              '/home': (_) => const HomePage(),
              '/login': (_) => const LoginPage(),
              '/register': (_) => const RegisterPage(),
              '/activity': (_) => const ActivityPage(),
              '/notes': (_) => const NotesPage(),
              '/games': (_) => const WordlePage(),
              '/calendar': (_) => TasksPage(selectedDay: DateTime.now()),
            },
          ),
        ),
      ),
    );
  }
}
