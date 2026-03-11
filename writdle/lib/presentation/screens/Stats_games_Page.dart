// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsPage extends StatefulWidget {
  final int resultAttempt; // 1, 2, 3, 4 or 0 if failed

  const StatsPage({super.key, required this.resultAttempt});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Future<List<int>> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    return [
      prefs.getInt('win1') ?? 0,
      prefs.getInt('win2') ?? 0,
      prefs.getInt('win3') ?? 0,
      prefs.getInt('win4') ?? 0,
      prefs.getInt('fail') ?? 0,
    ];
  }

  Future<void> _resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('win1');
    await prefs.remove('win2');
    await prefs.remove('win3');
    await prefs.remove('win4');
    await prefs.remove('fail');

    setState(() {}); // إعادة تحميل البيانات بعد الحذف
  }

  @override
  Widget build(BuildContext context) {
    final List<String> labels = [
      "1st Attempt",
      "2nd Attempt",
      "3rd Attempt",
      "4th Attempt",
      "Failed",
    ];

    final List<IconData> icons = [
      LucideIcons.star,
      LucideIcons.starHalf,
      LucideIcons.edit2,
      LucideIcons.clock,
      LucideIcons.x,
    ];

    final List<Color> colors = [
      Colors.green,
      Colors.lightGreen,
      Colors.amber,
      Colors.orange,
      Colors.red,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Today's Statistics",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Reset statistics',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: const Text(
                    "Reset Statistics",
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    "Are you sure you want to reset all statistics?",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _resetStats();
                      },
                      child: const Text(
                        "Reset",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<int>>(
        future: _loadStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final values = snapshot.data!;
          final totalGames = values.fold(0, (sum, val) => sum + val);
          final totalWins = values.sublist(0, 4).reduce((a, b) => a + b);
          final totalFails = values[4];
          final winRate = totalGames == 0
              ? 0
              : (totalWins / totalGames * 100).round();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Games Played: $totalGames",
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  "✅ Total Wins: $totalWins",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "❌ Total Failures: $totalFails",
                  style: const TextStyle(fontSize: 18, color: Colors.redAccent),
                ),
                const SizedBox(height: 6),
                Text(
                  "📊 Win Rate: $winRate%",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.lightBlueAccent,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.grey),
                const SizedBox(height: 10),

                for (int i = 0; i < labels.length; i++) ...[
                  Row(
                    children: [
                      Icon(icons[i], color: colors[i], size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "${labels[i]} - ${values[i]} times",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: totalGames == 0 ? 0 : values[i] / totalGames,
                      minHeight: 18,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        values[i] > 0 ? colors[i] : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const SizedBox(height: 16),

                /// ✅ زر العودة
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.calendar_today, color: Colors.white),
                    label: const Text(
                      "Come back tomorrow for a new word",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
