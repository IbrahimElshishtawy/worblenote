import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/presentation/bloc/app_settings_cubit.dart';
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
  int _previousIndex = 0;

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
    final reduceMotion = context.select<AppSettingsCubit, bool>(
      (cubit) => cubit.state.reduceMotion,
    );

    final pages = [
      HomeDashboardPage(
        onOpenWordle: () => _changeTab(1),
        onOpenNotes: () => _changeTab(2),
        onOpenActivity: () => _changeTab(3),
        onOpenProfile: () => _changeTab(4),
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
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 420),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final isForward = _currentIndex >= _previousIndex;
          final beginOffset = reduceMotion
              ? Offset.zero
              : Offset(isForward ? 0.08 : -0.08, 0);
          final offsetAnimation = Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        tabs: _tabs,
        currentIndex: _currentIndex,
        onTap: _changeTab,
      ),
    );
  }

  void _changeTab(int index) {
    if (index == _currentIndex) {
      return;
    }
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }
}
