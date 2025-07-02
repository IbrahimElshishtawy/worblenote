import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClanderWidget extends StatefulWidget {
  final DateTime selectedDay;
  const ClanderWidget({super.key, required this.selectedDay});

  @override
  State<ClanderWidget> createState() => _ClanderWidgetState();
}

class _ClanderWidgetState extends State<ClanderWidget> {
  late DateTime _selectedDay;
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay;
  }

  Stream<QuerySnapshot> _getTasksForDay() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDay);
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('date', isEqualTo: dateStr)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final textStyle = theme.textTheme.textStyle.copyWith(
      color: CupertinoColors.white,
      fontSize: 16,
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: Text(
          'مهام اليوم',
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              "📅 التاريخ: ${DateFormat('yyyy-MM-dd').format(_selectedDay)}",
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
                        '😴 لا توجد مهام لهذا اليوم',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 16,
                        ),
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
                        '🚫 لا توجد نتائج مطابقة',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
}
