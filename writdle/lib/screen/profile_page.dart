import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:writdle/data/game_stats.dart';

class ProfilePage extends StatefulWidget {
  final int? totalTasks;
  final int? completedTasks;
  final List<String>? completedTaskTitles;

  const ProfilePage({
    super.key,
    this.totalTasks,
    this.completedTasks,
    this.completedTaskTitles,
    required int winsFirstTry,
    required int totalGames,
    required int winsSecondTry,
    required int winsThirdTry,
    required int winsFourthTry,
    required int losses,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = '';
  String email = '';
  int rating = 0;
  bool isLoading = true;
  late Timer _timer;
  String currentDateTime = '';

  int totalTasks = 0;
  int completedTasks = 0;
  List<String> completedTaskTitles = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => updateTime());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      totalTasks = args['totalTasks'] ?? widget.totalTasks ?? 0;
      completedTasks = args['completedTasks'] ?? widget.completedTasks ?? 0;
      completedTaskTitles = List<String>.from(
        args['completedTaskTitles'] ?? widget.completedTaskTitles ?? [],
      );
    } else {
      totalTasks = widget.totalTasks ?? 0;
      completedTasks = widget.completedTasks ?? 0;
      completedTaskTitles = widget.completedTaskTitles ?? [];
    }

    print('=== ProfilePage Data ===');
    print('Total Tasks: $totalTasks');
    print('Completed Tasks: $completedTasks');
    print('Completed Titles: $completedTaskTitles');
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
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  TableRow buildRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildStatsTable() {
    final percentage = totalTasks == 0
        ? 0
        : ((completedTasks / totalTasks) * 100).toInt();
    final totalWins = UserStats.totalWins;
    final totalGames = UserStats.totalGames;
    final winRate = (UserStats.winRate * 100).toStringAsFixed(1);

    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
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
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              children: [
                buildRow("⭐ Rating", rating.toString()),
                buildRow("📅 Today", currentDateTime),
                buildRow("✅ Completed", completedTasks.toString()),
                buildRow("📝 Total Tasks", totalTasks.toString()),
                buildRow("📈 Progress", "$percentage%"),
                buildRow("🎮 Games Played", "$totalGames"),
                buildRow("🏆 Total Wins", "$totalWins"),
                buildRow("🥇 Win Rate", "$winRate%"),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: totalTasks == 0 ? 0 : completedTasks / totalTasks,
                minHeight: 14,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCompletedTaskList() {
    if (completedTaskTitles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 24),
        child: Text(
          "No completed tasks yet today.",
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
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
          ...completedTaskTitles.map(
            (title) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("My Profile"),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signOut,
            tooltip: "Logout",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
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
                  Text(
                    email,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  buildStatsTable(),
                  buildCompletedTaskList(),
                ],
              ),
            ),
    );
  }
}
