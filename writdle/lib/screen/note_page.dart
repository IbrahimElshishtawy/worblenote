import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:writdle/widget/clander_widget.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  DateTime _selectedDay = DateTime.now();

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TableCalendar(
        locale: 'ar_EG',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _selectedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: CupertinoColors.activeBlue,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: CupertinoColors.systemPurple,
            shape: BoxShape.circle,
          ),
          defaultTextStyle: TextStyle(color: CupertinoColors.white),
          weekendTextStyle: TextStyle(color: CupertinoColors.inactiveGray),
        ),
        headerStyle: const HeaderStyle(
          titleTextStyle: TextStyle(color: CupertinoColors.white),
          formatButtonVisible: false,
          titleCentered: true,
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: CupertinoColors.systemGrey),
          weekendStyle: TextStyle(color: CupertinoColors.systemGrey),
        ),
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: const CupertinoNavigationBar(middle: Text('صفحة التقويم')),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildCalendar(),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              child: const Text('عرض المهام لهذا اليوم'),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) =>
                        ClanderWidget(selectedDay: _selectedDay),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
