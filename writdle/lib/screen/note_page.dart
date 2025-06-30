import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  DateTime _selectedDay = DateTime.now();
  bool _showCompleted = false;

  Stream<QuerySnapshot> _getTasksForDay() {
    final dateStr =
        "${_selectedDay.year}-${_selectedDay.month}-${_selectedDay.day}";
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('date', isEqualTo: dateStr)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final bgColor = CupertinoColors.black;
    final textStyle = theme.textTheme.textStyle.copyWith(
      color: CupertinoColors.white,
    );

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: Text(
          'نشاطك اليومي',
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildCalendar(),
            const SizedBox(height: 12),
            CupertinoSlidingSegmentedControl<bool>(
              groupValue: _showCompleted,
              backgroundColor: CupertinoColors.darkBackgroundGray,
              thumbColor: CupertinoColors.activeBlue,
              children: const {
                false: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'غير مكتملة',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ),
                true: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'مكتملة',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ),
              },
              onValueChanged: (val) {
                setState(() {
                  _showCompleted = val ?? false;
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getTasksForDay(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد مهام لهذا اليوم',
                        style: TextStyle(color: CupertinoColors.systemGrey),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['completed'] == _showCompleted;
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد نتائج مطابقة',
                        style: TextStyle(color: CupertinoColors.systemGrey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.darkBackgroundGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                data['title'] ?? '',
                                style: textStyle,
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: Icon(
                                _showCompleted
                                    ? CupertinoIcons.check_mark_circled_solid
                                    : CupertinoIcons.check_mark_circled,
                                color: _showCompleted
                                    ? CupertinoColors.activeGreen
                                    : CupertinoColors.inactiveGray,
                              ),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('tasks')
                                    .doc(doc.id)
                                    .update({'completed': !_showCompleted});
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
