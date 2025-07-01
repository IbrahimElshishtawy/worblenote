import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    final textStyle = theme.textTheme.textStyle.copyWith(
      color: CupertinoColors.white,
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
            const SizedBox(height: 12),
            Text(
              "التاريخ: ${_selectedDay.year}-${_selectedDay.month}-${_selectedDay.day}",
              style: const TextStyle(color: CupertinoColors.white),
            ),
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
}
