import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:writdle/providers/user_stats_provider.dart';
import 'package:writdle/screen/profile_page.dart';
import 'activity_page.dart';
import 'note_page.dart';
import 'games_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<BottomNavigationBarItem> _tabs = const [
    BottomNavigationBarItem(icon: Icon(Icons.videogame_asset), label: 'Wordle'),
    BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Notes'),
    BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Activity'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (_currentIndex) {
      case 0:
        currentPage = WordlePage(
          onGameFinished: () {
            context.read<UserStatsProvider>().loadFromFirestore();
          },
        );
        break;
      case 1:
        currentPage = const NotesPage();
        break;
      case 2:
        currentPage = const ActivityPage();
        break;
      case 3:
        currentPage = ProfilePage();
        break;
      default:
        currentPage = const NotesPage();
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: currentPage,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: _tabs,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
