import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:writdle/screen/activity_day_page.dart';
import 'package:writdle/screen/note_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        height: 60,
        backgroundColor: const Color(0xFF1C1C1E),
        activeColor: CupertinoColors.systemPurple,
        inactiveColor: CupertinoColors.systemGrey2,
        border: const Border(top: BorderSide(color: Colors.transparent)),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.sparkles, size: 28),
            label: 'نشاطك',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_list, size: 26),
            label: 'ملاحظات',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return const ActivityPage();
              case 1:
                return const NotePage();
              default:
                return const Center(child: Text('صفحة غير موجودة'));
            }
          },
        );
      },
    );
  }
}
