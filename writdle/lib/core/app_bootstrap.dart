import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:writdle/core/app_root.dart';
import 'package:writdle/core/notifications/local_notification_service.dart';
import 'package:writdle/data/repositories/auth_repository_impl.dart';
import 'package:writdle/data/repositories/note_repository_impl.dart';
import 'package:writdle/data/repositories/profile_repository_impl.dart';
import 'package:writdle/data/repositories/task_repository_impl.dart';
import 'package:writdle/firebase_options.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService.instance.initialize();

  final authRepository = AuthRepositoryImpl();
  final noteRepository = NoteRepositoryImpl();
  final taskRepository = TaskRepositoryImpl();
  final profileRepository = ProfileRepositoryImpl();

  runApp(
    WritdleApp(
      authRepository: authRepository,
      noteRepository: noteRepository,
      taskRepository: taskRepository,
      profileRepository: profileRepository,
    ),
  );
}
