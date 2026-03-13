import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/data/profile_stats_card.dart';
import 'package:writdle/presentation/bloc/profile_cubit.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('My Profile'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            onPressed: () async {
              await context.read<ProfileCubit>().logout();
              if (!mounted) {
                return;
              }
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = state.profile;
          final stats = state.stats;
          final progress = stats.completedTasks == 0 ? 0.0 : 1.0;

          return RefreshIndicator(
            onRefresh: () => context.read<ProfileCubit>().loadProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    state.currentDateTime,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.deepPurple, width: 3),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: const CircleAvatar(
                      radius: 55,
                      backgroundImage: AssetImage(
                        'assets/icon/w-logo-image_332120.jpg',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile?.name ?? 'Guest',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profile?.email ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  ProfileStatsCard(
                    completedTasks: stats.completedTasks,
                    totalTasks: stats.completedTasks,
                    losses: stats.losses,
                    progress: progress,
                    winRate: stats.winRate,
                  ),
                  const SizedBox(height: 24),
                  if (stats.completedTaskTitles.isEmpty)
                    const Text(
                      'No completed tasks yet today.',
                      style: TextStyle(color: Colors.white60),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: stats.completedTaskTitles
                          .map(
                            (title) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
