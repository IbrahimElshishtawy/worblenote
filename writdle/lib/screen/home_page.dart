import 'package:flutter/material.dart';
import 'package:writdle/screen/profile_page.dart';
import 'activity_page.dart';
import 'note_page.dart';
import 'games_page.dart';
import 'package:writdle/data/user_stats.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // المهام
  int totalTasks = 0;
  int completedTasks = 0;
  List<String> completedTaskTitles = [];

  // الألعاب
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

      // 🟣 طباعة بيانات الألعاب
      print('🟣 Game Stats Updated From Global:');
      print('  totalGames: $totalGames');
      print('  winsFirstTry: $winsFirstTry');
      print('  winsSecondTry: $winsSecondTry');
      print('  winsThirdTry: $winsThirdTry');
      print('  winsFourthTry: $winsFourthTry');
      print('  losses: $losses');
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

              // 🟢 طباعة بيانات المهام
              print('🟢 Task Stats Updated:');
              print('  totalTasks: $total');
              print('  completedTasks: $completed');
              print('  completedTaskTitles: $titles');

              // تحديث الإحصائيات العامة
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
        // 🔵 طباعة القيم المرسلة إلى صفحة البروفايل
        print('🔵 Navigating to ProfilePage with:');
        print('  completedTasks: $completedTasks');
        print('  completedTaskTitles: $completedTaskTitles');
        print('  winsFirstTry: $winsFirstTry');
        print('  winsSecondTry: $winsSecondTry');
        print('  winsThirdTry: $winsThirdTry');
        print('  winsFourthTry: $winsFourthTry');
        print('  losses: $losses');
        print('  weeklyWordsCompleted: ${completedTasks * 50}');

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
        backgroundColor: const Color(0xFF1C1C1E),
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
