import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clander_widget.dart';

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

  // هذه الخريطة تحوي عدد المهام غير المكتملة في كل يوم
  final Map<DateTime, int> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMonthEvents(_focusedDay);
    _fetchTasksForDay(_selectedDay!);
  }

  // جلب بيانات كل المهام للشهر الحالي لتلوين الأيام
  Future<void> _loadMonthEvents(DateTime month) async {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('date', isGreaterThanOrEqualTo: _formatDate(first))
        .where('date', isLessThanOrEqualTo: _formatDate(last))
        .get();

    final Map<DateTime, int> map = {};
    for (var doc in snapshot.docs) {
      if (doc['completed'] == false) {
        final parts = (doc['date'] as String).split('-');
        final day = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        map[day] = (map[day] ?? 0) + 1;
      }
    }
    setState(() {
      _events.clear();
      _events.addAll(map);
    });
  }

  Future<void> _fetchTasksForDay(DateTime day) async {
    final formatted = _formatDate(day);
    final snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('date', isEqualTo: formatted)
        .get();

    final docs = snapshot.docs;
    final total = docs.length;
    final completed = docs.where((d) => d['completed'] == true).length;

    setState(() {
      totalTasks = total;
      completedTasks = completed;
    });
  }

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final double progress = totalTasks == 0
        ? 0
        : (completedTasks / totalTasks).clamp(0, 1);
    final int remaining = totalTasks - completedTasks;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'نشاطك اليومي',
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (sel, foc) async {
                  setState(() {
                    _selectedDay = sel;
                    _focusedDay = foc;
                  });
                  await _fetchTasksForDay(sel);
                },
                onPageChanged: (newFocused) {
                  _loadMonthEvents(newFocused);
                  _focusedDay = newFocused;
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: CupertinoColors.systemPurple,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                eventLoader: (day) => List.filled(
                  _events[DateTime(day.year, day.month, day.day)] ?? 0,
                  '●',
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: CupertinoColors.systemRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'تقدمك اليوم:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              CupertinoProgressBar(value: progress),
              const SizedBox(height: 8),
              Text(
                'أنجزت $completedTasks من $totalTasks. تبقى $remaining.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                child: const Text('عرض المهام'),
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => ClanderWidget(selectedDay: _selectedDay!),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CupertinoProgressBar extends StatelessWidget {
  final double value;
  const CupertinoProgressBar({super.key, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemPurple,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
