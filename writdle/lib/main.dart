import 'package:flutter/material.dart';
import 'package:writdle/screen/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wordle & Note App',
      theme: ThemeData(primarySwatch: Colors.teal),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        //  '/wordle': (context) => const WordlePage(),
        // '/notes': (context) => const NotePage(),
      },
    );
  }
}
