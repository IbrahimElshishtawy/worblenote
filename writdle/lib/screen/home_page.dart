import 'package:flutter/material.dart';
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
    BottomNavigationBarItem(icon: Icon(Icons.today), label: 'النشاط'),
    BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'ملاحظات'),
    BottomNavigationBarItem(icon: Icon(Icons.videogame_asset), label: 'Wordle'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (_currentIndex) {
      case 0:
        currentPage = const ActivityPage();
        break;
      case 1:
        currentPage = const NotesPage();
        break;
      case 2:
        currentPage = const WordlePage();
        break;
      case 3:
        currentPage = const ProfilePage(
          totalTasks: 0,
          completedTasks: 0,
          completedTaskTitles: [],
        );
        break;
      default:
        currentPage = const ActivityPage();
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
        backgroundColor: const Color(0xFF1C1C1E),
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
