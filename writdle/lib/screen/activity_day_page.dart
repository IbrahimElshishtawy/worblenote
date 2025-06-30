import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('مهمة جديدة'),
        content: CupertinoTextField(
          controller: _taskController,
          placeholder: 'اكتب المهمة هنا...',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('إلغاء'),
            onPressed: () {
              _taskController.clear();
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
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
            child: const Text('إضافة'),
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

  Widget _buildProgressButton(BuildContext context) {
    double percent = _total == 0 ? 0 : _completed / _total;
    final theme = CupertinoTheme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) =>
                TasksPage(selectedDay: _selectedDay, filter: _filter),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? CupertinoColors.systemGrey.withOpacity(0.3)
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 4,
                    backgroundColor: CupertinoColors.systemGrey4,
                    valueColor: AlwaysStoppedAnimation(
                      percent == 1.0 ? Colors.green : Colors.deepPurple,
                    ),
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
            Expanded(
              child: Text(
                percent == 1.0 ? '🎉 أحسنت! اكتملت المهام' : 'عرض مهام اليوم',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('نشاطك اليومي')),
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          const SizedBox(height: 12),
          TableCalendar(
            locale: 'ar_EG',
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
              selectedDecoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.deepPurple.shade200,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.redAccent),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
              weekendStyle: TextStyle(color: Colors.redAccent),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: _buildQuery().snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final tasks = snapshot.data!.docs;
                _total = tasks.length;
                _completed = tasks.where((doc) => doc['isDone'] == true).length;
              }
              return _buildProgressButton(context);
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: CupertinoButton.filled(
              borderRadius: BorderRadius.circular(30),
              child: const Icon(CupertinoIcons.add),
              onPressed: _showAddTaskDialog,
            ),
          ),
        ],
      ),
    );
  }
}
