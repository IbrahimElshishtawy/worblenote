import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/presentation/bloc/profile_cubit.dart';
import 'package:writdle/presentation/screens/activity_page.dart';
import 'package:writdle/presentation/screens/games_page.dart';
import 'package:writdle/presentation/screens/home_dashboard_page.dart';
import 'package:writdle/presentation/screens/note_page.dart';
import 'package:writdle/presentation/screens/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<_HomeTabItem> _tabs = const [
    _HomeTabItem(
      icon: Icons.dashboard_rounded,
      label: 'Home',
    ),
    _HomeTabItem(
      icon: Icons.auto_awesome,
      label: 'Wordle',
    ),
    _HomeTabItem(
      icon: Icons.edit_note_rounded,
      label: 'Notes',
    ),
    _HomeTabItem(
      icon: Icons.insights_rounded,
      label: 'Activity',
    ),
    _HomeTabItem(
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
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                blurRadius: 26,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isSelected = index == _currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _currentIndex = index),
                  borderRadius: BorderRadius.circular(22),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.14)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _HomeTabItem {
  const _HomeTabItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
