import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:writdle/screen/task_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final TextEditingController _taskController = TextEditingController();
  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  DateTime _selectedDay = DateTime.now();
  String _filter = 'all';

  int _total = 0;
  int _completed = 0;

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Task'),
        content: TextField(
          controller: _taskController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter your task...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _taskController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final task = _taskController.text.trim();
              if (task.isNotEmpty) {
                await FirebaseFirestore.instance.collection('tasks').add({
                  'title': task,
                  'isDone': false,
                  'timestamp': Timestamp.now(),
                  'userId': userId,
                });
              }
              _taskController.clear();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Query _buildQuery() {
    DateTime start = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    DateTime end = start.add(const Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThan: end)
        .orderBy('timestamp', descending: true);
  }

  Widget _buildProgressButton() {
    double percent = _total == 0 ? 0 : _completed / _total;
    Color color = Color.lerp(Colors.red, Colors.green, percent)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: percent == 1.0 ? Colors.green : Colors.deepPurple.shade100,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TasksPage(selectedDay: _selectedDay, filter: _filter),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (percent < 1.0) ...[
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 4,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              const Text(
                "View Today's Tasks",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ] else ...[
              const Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 10),
              const Text(
                '🎉 Great Job! You did it!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.8,
        centerTitle: true,
        title: const Text(
          'Daily Activity',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          TableCalendar(
            locale: 'en_US',
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, _) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple.shade400,
                shape: BoxShape.circle,
              ),
              todayDecoration: const BoxDecoration(
                color: Colors.deepPurpleAccent,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.redAccent),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
              weekendStyle: TextStyle(color: Colors.redAccent),
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: _buildQuery().snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final tasks = snapshot.data!.docs;
                _total = tasks.length;
                _completed = tasks.where((doc) => doc['isDone'] == true).length;
              }
              return _buildProgressButton();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
