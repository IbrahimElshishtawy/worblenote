// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:writdle/data/profile_stats_card.dart';
import 'package:writdle/models/profile_logic.dart';

class ProfilePage extends StatefulWidget {
  final int totalTasks;
  final int completedTasks;
  final int totalGames;
  final List<String> completedTaskTitles;
  final int winsSecondTry;
  final int winsFirstTry;
  final int losses;
  final int winsThirdTry;
  final int winsFourthTry;

  const ProfilePage({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalGames,
    required this.completedTaskTitles,
    required this.winsSecondTry,
    required this.winsFirstTry,
    required this.losses,
    required this.winsThirdTry,
    required this.winsFourthTry,
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
    logic.fetchUserData((name, mail, rate) {
      setState(() {
        userName = name;
        email = mail;
        rating = rate;
        isLoading = false;
      });
    });
    logic.startClock((time) {
      setState(() => currentDateTime = time);
    });
  }

  @override
  void dispose() {
    logic.disposeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalTasks = widget.totalTasks;
    final completedTasks = widget.completedTasks;
    final totalGames = widget.totalGames;
    final completedTitles = widget.completedTaskTitles;

    final totalWins =
        widget.winsFirstTry +
        widget.winsSecondTry +
        widget.winsThirdTry +
        widget.winsFourthTry;

    final progress = logic.calculateProgress(completedTasks, totalTasks);
    final winRate = logic.calculateWinRate(totalWins, totalGames);

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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    currentDateTime,
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
                    completedTasks: completedTasks,
                    totalTasks: totalTasks,
                    totalGames: totalGames,
                    winsFirstTry: widget.winsFirstTry,
                    winsSecondTry: widget.winsSecondTry,
                    winsThirdTry: widget.winsThirdTry,
                    winsFourthTry: widget.winsFourthTry,
                    losses: widget.losses,
                    progress: progress,
                    winRate: winRate,
                  ),

                  const SizedBox(height: 24),

                  /// ✅ المهام المكتملة اليوم
                  if (completedTitles.isNotEmpty)
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
                        ...completedTitles.map(
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
    );
  }
}
