// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:writdle/screen/home_page.dart';
import 'package:writdle/screen/activity_page.dart';
import 'package:writdle/screen/note_page.dart';
import 'package:writdle/screen/games_page.dart';
import 'package:writdle/screen/clander_widget.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('ar_EG', null); // دعم التقويم بالعربية

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Writdle App',
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.systemPurple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/activity': (context) => const ActivityPage(),
        '/notes': (context) => const NotePage(),
        '/games': (context) => const GamesPage(),
        '/calendar': (context) => ClanderWidget(selectedDay: DateTime.now()),
      },
    );
  }
}
