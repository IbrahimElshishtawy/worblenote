import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/app_localizations.dart';
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
    final l10n = context.l10n;
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
                          userName: profileState.profile?.name ?? l10n.t('writer'),
                          onProfileTap: widget.onOpenProfile,
                        ),
                        const SizedBox(height: 22),
                        SectionTitle(
                          title: l10n.t('quick_focus'),
                          subtitle: l10n.t('quick_focus_subtitle'),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            QuickActionCard(
                              title: l10n.t('play_wordle'),
                              subtitle: l10n.t('play_wordle_subtitle'),
                              icon: Icons.auto_awesome,
                              accent: const Color(0xFF0F766E),
                              onTap: widget.onOpenWordle,
                            ),
                            QuickActionCard(
                              title: l10n.t('open_notes'),
                              subtitle: l10n.t('open_notes_subtitle'),
                              icon: Icons.edit_note_rounded,
                              accent: const Color(0xFF7C3AED),
                              onTap: widget.onOpenNotes,
                            ),
                            QuickActionCard(
                              title: l10n.t('view_activity'),
                              subtitle: l10n.t('view_activity_subtitle'),
                              icon: Icons.insights_rounded,
                              accent: const Color(0xFFEA580C),
                              onTap: widget.onOpenActivity,
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        SectionTitle(
                          title: l10n.t('today_snapshot'),
                          subtitle: l10n.t('today_snapshot_subtitle'),
                        ),
                        const SizedBox(height: 14),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 760 ? 3 : 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio:
                              MediaQuery.of(context).size.width > 760 ? 1.08 : 0.96,
                          children: [
                            StatCard(
                              label: l10n.t('completed'),
                              value: '$completedTasks',
                              helper: l10n.t('tasks_done_today'),
                              icon: Icons.check_circle,
                              color: const Color(0xFF15803D),
                            ),
                            StatCard(
                              label: l10n.t('remaining'),
                              value: '$remainingTasks',
                              helper: l10n.t('tasks_still_open'),
                              icon: Icons.schedule,
                              color: const Color(0xFFEA580C),
                            ),
                            StatCard(
                              label: l10n.t('win_rate'),
                              value: '$winRate%',
                              helper: l10n.t('game_performance'),
                              icon: Icons.bar_chart_rounded,
                              color: const Color(0xFF2563EB),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        SectionTitle(
                          title: l10n.t('recent_wins'),
                          subtitle: l10n.t('recent_wins_subtitle'),
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
