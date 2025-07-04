// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsPage extends StatelessWidget {
  final int resultAttempt; // 1, 2, 3, 4 or 0 if failed

  const StatsPage({super.key, required this.resultAttempt});

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
      ),
      body: FutureBuilder<List<int>>(
        future: _loadStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final values = snapshot.data!;
          final total = values.fold(0, (sum, val) => sum + val);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Results:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
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
                      value: total == 0 ? 0 : values[i] / total,
                      minHeight: 18,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        values[i] > 0 ? colors[i] : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                const Spacer(),
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
