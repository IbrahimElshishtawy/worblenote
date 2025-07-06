// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:writdle/data/profile_stats_card.dart';
import 'package:writdle/models/profile_logic.dart';
import 'package:writdle/data/user_stats.dart'; // علشان UserStats

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final logic = ProfileLogic();

  String userName = '';
  String email = '';
  String currentDateTime = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initProfile();

    logic.startClock((time) {
      if (!mounted) return;
      setState(() => currentDateTime = time);
    });
  }

  Future<void> _initProfile() async {
    setState(() => isLoading = true);

    print('📦 Loading data from Firestore...');
    await UserStats.loadFromFirestore();

    print('📦 Loaded from Firestore:');
    print('UserStats.completedTasks = ${UserStats.completedTasks}');
    print('UserStats.completedTaskTitles = ${UserStats.completedTaskTitles}');

    logic.fetchUserData((name, mail, _) {
      if (!mounted) return;
      setState(() {
        userName = name;
        email = mail;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    logic.disposeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalWins =
        UserStats.winsFirstTry +
        UserStats.winsSecondTry +
        UserStats.winsThirdTry +
        UserStats.winsFourthTry;

    final winRate = logic.calculateWinRate(totalWins, UserStats.totalGames);
    final progress = logic.calculateProgress(
      UserStats.completedTasks,
      UserStats.completedTasks,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("My Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logic.signOut(context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _initProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      currentDateTime,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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
                          "assets/icon/w-logo-image_332120.jpg",
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(email, style: const TextStyle(color: Colors.white70)),

                    /// 🧠 الإحصائيات بدون rating و totalGames
                    ProfileStatsCard(
                      completedTasks: UserStats.completedTasks,
                      totalTasks: UserStats.completedTasks,
                      losses: UserStats.losses,
                      progress: progress,
                      winRate: winRate,
                    ),

                    const SizedBox(height: 24),

                    /// ✅ المهام المكتملة
                    if (UserStats.completedTaskTitles.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "✅ Completed Tasks Today",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...UserStats.completedTaskTitles.map(
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
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        "No completed tasks yet today.",
                        style: TextStyle(color: Colors.white60),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
