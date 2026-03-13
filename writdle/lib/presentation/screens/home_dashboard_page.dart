import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/utils/date_formatter.dart';
import 'package:writdle/presentation/bloc/profile_cubit.dart';
import 'package:writdle/presentation/bloc/tasks_cubit.dart';
import 'package:writdle/presentation/widgets/home/dashboard_hero.dart';
import 'package:writdle/presentation/widgets/home/quick_action_card.dart';
import 'package:writdle/presentation/widgets/home/recent_wins_card.dart';
import 'package:writdle/presentation/widgets/home/section_title.dart';
import 'package:writdle/presentation/widgets/home/stat_card.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({
    super.key,
    required this.onOpenWordle,
    required this.onOpenNotes,
    required this.onOpenActivity,
    required this.onOpenProfile,
  });

  final VoidCallback onOpenWordle;
  final VoidCallback onOpenNotes;
  final VoidCallback onOpenActivity;
  final VoidCallback onOpenProfile;

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProfileCubit>().loadProfile();
      await context
          .read<TasksCubit>()
          .fetchTasks(DateFormatter.toDayKey(DateTime.now()));
    });
  }

  Future<void> _refreshDashboard() async {
    await context.read<ProfileCubit>().loadProfile();
    await context
        .read<TasksCubit>()
        .fetchTasks(DateFormatter.toDayKey(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withValues(alpha: 0.14),
              scheme.surface,
              scheme.secondary.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              return BlocBuilder<TasksCubit, TasksState>(
                builder: (context, tasksState) {
                  final completedTasks = tasksState.completedTasks;
                  final totalTasks = tasksState.tasks.length;
                  final remainingTasks = totalTasks - completedTasks;
                  final winRate = profileState.stats.winRate.toStringAsFixed(0);

                  return RefreshIndicator(
                    onRefresh: _refreshDashboard,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      children: [
                        DashboardHero(
                          userName: profileState.profile?.name ?? 'Writer',
                          onProfileTap: widget.onOpenProfile,
                        ),
                        const SizedBox(height: 22),
                        const SectionTitle(
                          title: 'Quick Focus',
                          subtitle: 'Move fast between your core spaces.',
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            QuickActionCard(
                              title: 'Play Wordle',
                              subtitle: 'Warm up your mind with today\'s challenge.',
                              icon: Icons.auto_awesome,
                              accent: const Color(0xFF0F766E),
                              onTap: widget.onOpenWordle,
                            ),
                            QuickActionCard(
                              title: 'Open Notes',
                              subtitle: 'Capture ideas before they fade.',
                              icon: Icons.edit_note_rounded,
                              accent: const Color(0xFF7C3AED),
                              onTap: widget.onOpenNotes,
                            ),
                            QuickActionCard(
                              title: 'View Activity',
                              subtitle: 'Track your progress for today.',
                              icon: Icons.insights_rounded,
                              accent: const Color(0xFFEA580C),
                              onTap: widget.onOpenActivity,
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        const SectionTitle(
                          title: 'Today Snapshot',
                          subtitle: 'A compact pulse on your momentum.',
                        ),
                        const SizedBox(height: 14),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 760 ? 3 : 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.18,
                          children: [
                            StatCard(
                              label: 'Completed',
                              value: '$completedTasks',
                              helper: 'Tasks done today',
                              icon: Icons.check_circle,
                              color: const Color(0xFF15803D),
                            ),
                            StatCard(
                              label: 'Remaining',
                              value: '$remainingTasks',
                              helper: 'Tasks still open',
                              icon: Icons.schedule,
                              color: const Color(0xFFEA580C),
                            ),
                            StatCard(
                              label: 'Win Rate',
                              value: '$winRate%',
                              helper: 'Game performance',
                              icon: Icons.bar_chart_rounded,
                              color: const Color(0xFF2563EB),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        const SectionTitle(
                          title: 'Recent Wins',
                          subtitle: 'Small highlights keep the rhythm going.',
                        ),
                        const SizedBox(height: 14),
                        RecentWinsCard(
                          completedTaskTitles: profileState.stats.completedTaskTitles,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
