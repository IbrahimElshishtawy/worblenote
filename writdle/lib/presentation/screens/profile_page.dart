import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/app_navigation.dart';
import 'package:writdle/core/app_localizations.dart';
import 'package:writdle/core/notifications/app_notification.dart';
import 'package:writdle/core/notifications/app_notification_cubit.dart';
import 'package:writdle/domain/entities/profile_data.dart';
import 'package:writdle/domain/entities/user_stats_summary.dart';
import 'package:writdle/presentation/bloc/app_settings_cubit.dart';
import 'package:writdle/presentation/bloc/profile_cubit.dart';
import 'package:writdle/presentation/widgets/profile/profile_activity_panel.dart';
import 'package:writdle/presentation/widgets/profile/profile_edit_sheet.dart';
import 'package:writdle/presentation/widgets/profile/profile_highlight_panel.dart';
import 'package:writdle/presentation/widgets/profile/profile_metric_card.dart';
import 'package:writdle/presentation/widgets/profile/profile_overview_card.dart';
import 'package:writdle/presentation/widgets/profile/profile_shell_background.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        title: Text(l10n.t('my_profile')),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) => previous.isSaving && !current.isSaving,
        listener: (context, state) {
          context.read<AppNotificationCubit>().show(
                l10n.t('profile_updated'),
                type: AppNotificationType.success,
              );
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ProfileShellBackground(
            child: RefreshIndicator(
              onRefresh: () => context.read<ProfileCubit>().loadProfile(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding =
                      constraints.maxWidth >= 900 ? 32.0 : 20.0;

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      32,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1080),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _AnimatedSection(
                                index: 0,
                                child: ProfileOverviewCard(
                                  profile: state.profile,
                                  currentDateTime: state.currentDateTime,
                                  onEdit: state.profile == null
                                      ? () {}
                                      : () => _showEditProfileSheet(
                                            context,
                                            state.profile!,
                                          ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _ResponsiveMetricGrid(stats: state.stats),
                              const SizedBox(height: 20),
                              _AnimatedSection(
                                index: 5,
                                child: ProfileHighlightPanel(stats: state.stats),
                              ),
                              const SizedBox(height: 20),
                              _AnimatedSection(
                                index: 6,
                                child: ProfileActivityPanel(
                                  activities: state.stats.completedTaskTitles,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showEditProfileSheet(
    BuildContext context,
    ProfileData profile,
  ) async {
    await AppNavigation.showSheet<void>(
      context,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      builder: (_) => ProfileEditSheet(profile: profile),
    );
  }
}

class _ResponsiveMetricGrid extends StatelessWidget {
  const _ResponsiveMetricGrid({
    required this.stats,
  });

  final UserStatsSummary stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cards = [
      ProfileMetricCard(
        title: 'Total Games',
        value: '${stats.totalGames}',
        caption: 'Daily challenge runs tracked',
        icon: Icons.sports_esports_rounded,
        color: scheme.primary,
      ),
      ProfileMetricCard(
        title: 'Wins',
        value: '${stats.totalWins}',
        caption: 'Completed with success',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFDAA520),
      ),
      ProfileMetricCard(
        title: 'Completed Tasks',
        value: '${stats.completedTasks}',
        caption: 'Productivity wins inside the app',
        icon: Icons.task_alt_rounded,
        color: scheme.tertiary,
      ),
      ProfileMetricCard(
        title: 'Losses',
        value: '${stats.losses}',
        caption: 'Rounds to improve next time',
        icon: Icons.trending_up_rounded,
        color: scheme.error,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 980
            ? 4
            : constraints.maxWidth >= 520
                ? 2
                : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: constraints.maxWidth >= 980
                ? 1.05
                : constraints.maxWidth >= 520
                    ? 1.18
                    : 1.12,
          ),
          itemBuilder: (context, index) {
            return _AnimatedSection(
              index: index + 1,
              child: cards[index],
            );
          },
        );
      },
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  const _AnimatedSection({
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = context.select<AppSettingsCubit, bool>(
      (cubit) => cubit.state.reduceMotion,
    );

    if (reduceMotion) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (index * 110)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}
