import 'package:flutter/cupertino.dart';
import 'activity_page.dart';
import 'note_page.dart';
import 'games_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.today),
            label: 'النشاط',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.pencil),
            label: 'ملاحظات',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.game_controller),
            label: 'Wordle',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const ActivityPage();
          case 1:
            return const NotePage();
          case 2:
            return const GamesPage();
          default:
            return const Center(child: Text('صفحة غير موجودة'));
        }
      },
    );
  }
}
