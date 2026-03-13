import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/presentation/bloc/profile_cubit.dart';
import 'package:writdle/presentation/screens/activity_page.dart';
import 'package:writdle/presentation/screens/games_page.dart';
import 'package:writdle/presentation/screens/home_dashboard_page.dart';
import 'package:writdle/presentation/screens/note_page.dart';
import 'package:writdle/presentation/screens/profile_page.dart';
import 'package:writdle/presentation/widgets/home/home_bottom_nav.dart';
import 'package:writdle/presentation/widgets/home/home_tab_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<HomeTabItem> _tabs = const [
    HomeTabItem(
      icon: Icons.dashboard_rounded,
      label: 'Home',
    ),
    HomeTabItem(
      icon: Icons.auto_awesome,
      label: 'Wordle',
    ),
    HomeTabItem(
      icon: Icons.edit_note_rounded,
      label: 'Notes',
    ),
    HomeTabItem(
      icon: Icons.insights_rounded,
      label: 'Activity',
    ),
    HomeTabItem(
      icon: Icons.person_outline,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeDashboardPage(
        onOpenWordle: () => setState(() => _currentIndex = 1),
        onOpenNotes: () => setState(() => _currentIndex = 2),
        onOpenActivity: () => setState(() => _currentIndex = 3),
        onOpenProfile: () => setState(() => _currentIndex = 4),
      ),
      WordlePage(
        onGameFinished: () {
          context.read<ProfileCubit>().loadProfile();
        },
      ),
      const NotesPage(),
      const ActivityPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: HomeBottomNav(
        tabs: _tabs,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
