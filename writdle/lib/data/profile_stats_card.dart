// lib/widget/profile_stats_card.dart
import 'package:flutter/material.dart';

class ProfileStatsCard extends StatelessWidget {
  final int rating;
  final int completedTasks;
  final int totalTasks;
  final int totalGames;
  final int losses;
  final double progress;
  final double winRate;

  const ProfileStatsCard({
    super.key,
    required this.rating,
    required this.completedTasks,
    required this.totalTasks,
    required this.totalGames,
    required this.losses,
    required this.progress,
    required this.winRate,
  });

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
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                buildRow("✅ Completed", completedTasks.toString()),
                buildRow("📝 Total Tasks", totalTasks.toString()),
                buildRow(
                  "📈 Progress",
                  "${(progress * 100).toStringAsFixed(0)}%",
                ),
                buildRow("🎮 Games Played", totalGames.toString()),
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
    );
  }
}
