import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/app_routes.dart';
import 'package:writdle/core/notifications/app_notification_cubit.dart';
import 'package:writdle/core/theme/app_theme.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';
import 'package:writdle/domain/repositories/note_repository.dart';
import 'package:writdle/domain/repositories/profile_repository.dart';
import 'package:writdle/domain/repositories/task_repository.dart';
import 'package:writdle/presentation/bloc/app_settings_cubit.dart';
import 'package:writdle/presentation/bloc/auth_cubit.dart';
import 'package:writdle/presentation/bloc/notes_cubit.dart';
import 'package:writdle/presentation/bloc/profile_cubit.dart';
import 'package:writdle/presentation/bloc/tasks_cubit.dart';
import 'package:writdle/presentation/bloc/theme_cubit.dart';
import 'package:writdle/presentation/widgets/app_notification_listener.dart';

class WritdleApp extends StatelessWidget {
  const WritdleApp({
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

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

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
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => AppSettingsCubit()),
          BlocProvider(create: (_) => AppNotificationCubit()),
          BlocProvider(create: (_) => AuthCubit(authRepository)),
          BlocProvider(create: (_) => NotesCubit(noteRepository)),
          BlocProvider(
            create: (_) => TasksCubit(taskRepository, profileRepository),
          ),
          BlocProvider(
            create: (_) => ProfileCubit(profileRepository, authRepository),
          ),
        ],
        child: AppNotificationListener(
          scaffoldMessengerKey: scaffoldMessengerKey,
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return BlocBuilder<AppSettingsCubit, AppSettingsState>(
                builder: (context, settings) {
                  return MaterialApp(
                    title: 'Writdle App',
                    debugShowCheckedModeBanner: false,
                    scaffoldMessengerKey: scaffoldMessengerKey,
                    theme: AppTheme.light(),
                    darkTheme: AppTheme.dark(),
                    themeMode: themeMode,
                    themeAnimationCurve: Curves.easeInOutCubic,
                    themeAnimationDuration: settings.reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 550),
                    builder: (context, child) {
                      final mediaQuery = MediaQuery.of(context);
                      return MediaQuery(
                        data: mediaQuery.copyWith(
                          textScaler: TextScaler.linear(settings.textScale),
                        ),
                        child: child ?? const SizedBox.shrink(),
                      );
                    },
                    initialRoute: '/splash',
                    routes: AppRoutes.routes(),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
