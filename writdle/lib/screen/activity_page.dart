// lib/screen/activity_page.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

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
    _fetchTasksForDay(_selectedDay!);
  }

  Future<void> _fetchTasksForDay(DateTime day) async {
    final formatted = _formatDate(day);
    final snap = await FirebaseFirestore.instance
        .collection('tasks')
        .where('date', isEqualTo: formatted)
        .get();
    final docs = snap.docs;

    if (!mounted) return;

    setState(() {
      totalTasks = docs.length;
      completedTasks = docs.where((d) => d['completed'] == true).length;
      _uncompletedTasks = docs.where((d) => d['completed'] == false).toList();
    });
  }

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    final remaining = totalTasks - completedTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your daily activity'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (sel, foc) async {
                setState(() {
                  _selectedDay = sel;
                  _focusedDay = foc;
                });
                await _fetchTasksForDay(sel);
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your progress today : $completedTasks / $totalTasks',
              style: const TextStyle(fontSize: 16),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LinearProgressIndicator(value: progress),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.task),
                  label: const Text('tasks'),
                  onPressed: () {
                    if (_selectedDay != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TasksPage(selectedDay: _selectedDay!),
                        ),
                      );
                    }
                  },
                ),
                Text(' residual : $remaining'),
              ],
            ),
            const SizedBox(height: 24),
            if (_uncompletedTasks.isNotEmpty) ...[
              const Text(
                'Remaining tasks :',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._uncompletedTasks.map(
                (task) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(task['title']),
                    subtitle: task['description'] != ''
                        ? Text(task['description'])
                        : null,
                  ),
                ),
              ),
            ] else ...[
              const Center(child: Text('There are no tasks left for today')),
            ],
          ],
        ),
      ),
    );
  }
}
