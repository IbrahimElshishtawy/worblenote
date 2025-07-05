import 'package:flutter/material.dart';
import 'package:writdle/screen/profile_page.dart';
import 'activity_page.dart';
import 'note_page.dart';
import 'games_page.dart';
import 'package:writdle/data/game_stats.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  int totalTasks = 0;
  int completedTasks = 0;
  List<String> completedTaskTitles = [];

  int totalGames = 0;
  int winsFirstTry = 0;
  int winsSecondTry = 0;
  int winsThirdTry = 0;
  int winsFourthTry = 0;
  int losses = 0;

  final List<BottomNavigationBarItem> _tabs = const [
    BottomNavigationBarItem(icon: Icon(Icons.videogame_asset), label: 'Wordle'),
    BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'ملاحظات'),
    BottomNavigationBarItem(icon: Icon(Icons.today), label: 'النشاط'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
  ];

  void updateGameStatsFromGlobal() {
    setState(() {
      totalGames = UserStats.totalGames;
      winsFirstTry = UserStats.winsFirstTry;
      winsSecondTry = UserStats.winsSecondTry;
      winsThirdTry = UserStats.winsThirdTry;
      winsFourthTry = UserStats.winsFourthTry;
      losses = UserStats.losses;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateGameStatsFromGlobal();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (_currentIndex) {
      case 0:
        currentPage = WordlePage(
          onGameFinished: () {
            updateGameStatsFromGlobal();
          },
        );
        break;
      case 1:
        currentPage = const NotesPage();
        break;
      case 2:
        currentPage = ActivityPage(
          onStatsUpdated: (total, completed, titles) {
            setState(() {
              totalTasks = total;
              completedTasks = completed;
              completedTaskTitles = titles;

              // ✅ تحديث البيانات في UserStats
              UserStats.updateStats(
                total: totalGames,
                first: winsFirstTry,
                second: winsSecondTry,
                third: winsThirdTry,
                fourth: winsFourthTry,
                loss: losses,
                completed: completed,
                titles: titles,
              );
            });
          },
        );
        break;
      case 3:
        currentPage = ProfilePage(
          totalTasks: totalTasks,
          completedTasks: completedTasks,
          completedTaskTitles: completedTaskTitles,
          totalGames: totalGames,
          winsFirstTry: winsFirstTry,
          winsSecondTry: winsSecondTry,
          winsThirdTry: winsThirdTry,
          winsFourthTry: winsFourthTry,
          losses: losses,
        );
        break;
      default:
        currentPage = ActivityPage(
          onStatsUpdated: (total, completed, titles) {},
        );
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
