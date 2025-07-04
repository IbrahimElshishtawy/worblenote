import 'package:flutter/material.dart';
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

  final List<Widget> _pages = [
    const ActivityPage(),
    const NotesPage(),
    const WordlePage(),
    const Center(child: Text('قريبًا: حسابك', style: TextStyle(fontSize: 18))),
  ];

  final List<BottomNavigationBarItem> _tabs = const [
    BottomNavigationBarItem(icon: Icon(Icons.today), label: 'النشاط'),
    BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'ملاحظات'),
    BottomNavigationBarItem(icon: Icon(Icons.videogame_asset), label: 'Wordle'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
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
