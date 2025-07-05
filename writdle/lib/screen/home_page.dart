// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:writdle/data/game_stats.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = '';
  String email = '';
  int rating = 0;
  bool isLoading = true;
  String currentDateTime = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => updateTime());
  }

  void updateTime() {
    final now = DateTime.now();
    final formatted = DateFormat('EEEE, MMM d, yyyy – h:mm:ss a').format(now);
    if (formatted != currentDateTime) {
      setState(() {
        currentDateTime = formatted;
      });
    }
  }

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        userName = data['name'] ?? 'No Name';
        email = data['email'] ?? 'No Email';
        rating = data['rating'] ?? 0;
        isLoading = false;
      });

      print('📥 User data loaded: $userName, $email, rating: $rating');
    } else {
      print('⚠️ No user document found');
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
    print('🚪 User signed out');
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
    print('🧹 Timer cancelled');
  }

  TableRow buildRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label, style: const TextStyle(color: Colors.white60)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(value, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedTitles = UserStats.completedTaskTitles;
    final totalTasks = completedTitles.length;
    final completedTasks = UserStats.completedTasks;
    final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    final winRate = (UserStats.winRate * 100).toStringAsFixed(1);

    print('📊 ProfilePage Data:');
    print('⭐ Rating: $rating');
    print('📝 Tasks: $completedTasks / $totalTasks');
    print('🎯 Completed Titles: $completedTitles');
    print('🎮 Games: ${UserStats.totalGames}');
    print('🏆 Wins: ${UserStats.totalWins}');
    print('📈 Win Rate: $winRate%');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("My Profile"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: signOut),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    currentDateTime,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
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

                  // 📊 الإحصائيات
                  Card(
                    color: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(top: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "📊 Your Stats",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(color: Colors.white30, height: 24),
                          Table(
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(3),
                            },
                            children: [
                              buildRow("⭐ Rating", rating.toString()),
                              buildRow(
                                "✅ Completed",
                                completedTasks.toString(),
                              ),
                              buildRow("📝 Total Tasks", totalTasks.toString()),
                              buildRow(
                                "📈 Progress",
                                "${(progress * 100).toStringAsFixed(0)}%",
                              ),
                              buildRow(
                                "🎮 Games Played",
                                "${UserStats.totalGames}",
                              ),
                              buildRow(
                                "🏆 Total Wins",
                                "${UserStats.totalWins}",
                              ),
                              buildRow("🥇 Win Rate", "$winRate%"),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 14,
                              backgroundColor: Colors.grey[800],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ✅ المهام المكتملة
                  const SizedBox(height: 24),
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
