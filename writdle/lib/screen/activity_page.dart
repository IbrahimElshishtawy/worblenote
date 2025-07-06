// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:writdle/data/user_stats.dart';
import 'task_page.dart';

class ActivityPage extends StatefulWidget {
  final void Function(int total, int completed, List<String> titles)?
  onStatsUpdated;

  const ActivityPage({super.key, this.onStatsUpdated});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int completedTasks = 0;
  int totalTasks = 0;
  List<DocumentSnapshot> _uncompletedTasks = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    print('📅 Initial day selected: $_selectedDay');
    _fetchTasksForDay(_selectedDay!);
  }

  Future<void> _fetchTasksForDay(DateTime day) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('❌ No user logged in');
      return;
    }

    final formattedDate = _formatDate(day);
    print('📤 Fetching tasks for date: $formattedDate');

    final snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: formattedDate)
        .get();

    final docs = snapshot.docs;
    final completed = docs.where((d) => d['completed'] == true).toList();
    final uncompleted = docs.where((d) => d['completed'] == false).toList();

    print('📥 Total tasks: ${docs.length}');
    print('✅ Completed: ${completed.length}');
    print('❗ Uncompleted: ${uncompleted.length}');

    if (!mounted) return;

    setState(() {
      totalTasks = docs.length;
      completedTasks = completed.length;
      _uncompletedTasks = uncompleted;
    });

    final completedTitles = completed
        .map((doc) => doc['title'] as String)
        .toList();
    print('🎯 Completed Task Titles: $completedTitles');

    // Update global stats
    UserStats.completedTasks = completedTasks;
    UserStats.completedTaskTitles = completedTitles;

    // Send data to HomePage
    widget.onStatsUpdated?.call(totalTasks, completedTasks, completedTitles);
  }

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    final remaining = totalTasks - completedTasks;

    print(
      '📊 Rendering UI - progress: ${(progress * 100).toStringAsFixed(1)}%',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Daily Activity'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedDay != null) {
            await _fetchTasksForDay(_selectedDay!);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.utc(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) async {
                  print('📆 Day selected: $selectedDay');
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  await _fetchTasksForDay(selectedDay);
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your progress today: $completedTasks / $totalTasks',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                color: Colors.deepPurple,
                minHeight: 8,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.task),
                    label: const Text('Tasks'),
                    onPressed: () {
                      print('📥 Navigating to TasksPage for $_selectedDay');
                      if (_selectedDay != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TasksPage(selectedDay: _selectedDay!),
                          ),
                        );
                      }
                    },
                  ),
                  Text('Remaining: $remaining'),
                ],
              ),
              const SizedBox(height: 24),
              if (_uncompletedTasks.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📌 Remaining tasks:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._uncompletedTasks.map((task) {
                      print('📋 Remaining Task: ${task['title']}');
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(task['title']),
                          subtitle:
                              (task['description'] as String).trim().isNotEmpty
                              ? Text(task['description'])
                              : null,
                        ),
                      );
                    }),
                  ],
                )
              else
                const Center(
                  child: Text('🎉 There are no tasks left for today!'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
