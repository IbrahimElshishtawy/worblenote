// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:writdle/data/profile_stats_card.dart';
import 'package:writdle/models/profile_logic.dart';

class ProfilePage extends StatefulWidget {
  final int completedTasks;
  final List<String> completedTaskTitles;
  final int winsFirstTry;
  final int winsSecondTry;
  final int winsThirdTry;
  final int winsFourthTry;
  final int losses;
  final int weeklyWordsCompleted;

  const ProfilePage({
    super.key,
    required this.completedTasks,
    required this.completedTaskTitles,
    required this.winsFirstTry,
    required this.winsSecondTry,
    required this.winsThirdTry,
    required this.winsFourthTry,
    required this.losses,
    required this.weeklyWordsCompleted,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final logic = ProfileLogic();

  String userName = '';
  String email = '';
  int rating = 0;
  String currentDateTime = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // ✅ طباعة البيانات المستلمة من HomePage
    print('=== Received Data in ProfilePage ===');
    print('completedTasks: ${widget.completedTasks}');
    print('completedTaskTitles: ${widget.completedTaskTitles}');
    print('winsFirstTry: ${widget.winsFirstTry}');
    print('winsSecondTry: ${widget.winsSecondTry}');
    print('winsThirdTry: ${widget.winsThirdTry}');
    print('winsFourthTry: ${widget.winsFourthTry}');
    print('losses: ${widget.losses}');
    print('weeklyWordsCompleted: ${widget.weeklyWordsCompleted}');
    print('====================================');

    _loadUserData();

    logic.startClock((time) {
      if (!mounted) return;
      setState(() => currentDateTime = time);
    });
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    print('⏳ Fetching user data...');
    logic.fetchUserData((name, mail, _) {
      if (!mounted) return;
      print('✅ User data loaded:');
      print('Name: $name, Email: $mail');

      setState(() {
        userName = name;
        email = mail;
        rating = _calculateRating();
        isLoading = false;
      });
    });
  }

  int _calculateRating() {
    final rating = (widget.weeklyWordsCompleted / 500).clamp(0, 5).round();
    print('⭐ Calculated rating: $rating');
    return rating;
  }

  @override
  void dispose() {
    logic.disposeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalGames =
        widget.winsFirstTry +
        widget.winsSecondTry +
        widget.winsThirdTry +
        widget.winsFourthTry +
        widget.losses;

    final totalWins =
        widget.winsFirstTry +
        widget.winsSecondTry +
        widget.winsThirdTry +
        widget.winsFourthTry;

    final winRate = logic.calculateWinRate(totalWins, totalGames);
    final progress = logic.calculateProgress(
      widget.completedTasks,
      widget.completedTasks,
    );

    print('📊 Win Rate: $winRate%, Progress: $progress%');

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
              onRefresh: _loadUserData,
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

                    /// 🧠 الإحصائيات
                    ProfileStatsCard(
                      rating: rating,
                      completedTasks: widget.completedTasks,
                      totalTasks: widget.completedTasks,
                      totalGames: totalGames,
                      losses: widget.losses,
                      progress: progress,
                      winRate: winRate,
                    ),

                    const SizedBox(height: 24),

                    /// ✅ المهام المكتملة
                    if (widget.completedTaskTitles.isNotEmpty)
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
                          ...widget.completedTaskTitles.map(
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
