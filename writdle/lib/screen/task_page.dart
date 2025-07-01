// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TasksPage extends StatefulWidget {
  final DateTime selectedDay;
  final String filter;

  const TasksPage({super.key, required this.selectedDay, required this.filter});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  }

  Query _buildQuery() {
    DateTime start = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
    );
    DateTime end = start.add(const Duration(days: 1));

    Query query = FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThan: end);

    if (widget.filter == 'done') {
      query = query.where('isDone', isEqualTo: true);
    } else if (widget.filter == 'undone') {
      query = query.where('isDone', isEqualTo: false);
    }

    return query.orderBy('timestamp', descending: true);
  }

  Future<void> _toggleDone(DocumentSnapshot doc) async {
    final isDone = doc['isDone'] as bool;
    await FirebaseFirestore.instance.collection('tasks').doc(doc.id).update({
      'isDone': !isDone,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Tasks"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _buildQuery().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('Error loading tasks.'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          var tasks = snapshot.data!.docs;

          // ترتيب: غير منجزة أولاً
          tasks.sort((a, b) {
            final aDone = a['isDone'] as bool;
            final bDone = b['isDone'] as bool;
            return aDone == bDone ? 0 : (aDone ? 1 : -1);
          });

          final total = tasks.length;
          final completed = tasks.where((t) => t['isDone'] == true).length;
          final percent = total == 0 ? 0.0 : completed / total;

          return Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 12,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation(
                    percent == 1.0 ? Colors.green : Colors.deepPurple,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Completed: $completed of $total (${(percent * 100).toInt()}%)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: tasks.isEmpty
                    ? const Center(child: Text('No tasks for selected day.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final title = task['title'];
                          final isDone = task['isDone'] as bool;
                          final timestamp = (task['timestamp'] as Timestamp)
                              .toDate();
                          final formattedDate = DateFormat.yMMMd()
                              .add_Hm()
                              .format(timestamp);

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDone
                                    ? [
                                        Colors.green.shade100,
                                        Colors.green.shade200,
                                      ]
                                    : [
                                        Colors.purple.shade50,
                                        Colors.deepPurple.shade100,
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              onTap: () async {
                                await _toggleDone(task);
                                setState(() {}); // لإعادة الترتيب بعد التحديث
                              },
                              leading: Icon(
                                isDone
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isDone ? Colors.green : Colors.redAccent,
                                size: 30,
                              ),
                              title: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Text('Added on: $formattedDate'),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: percent == 1.0 ? null : () {},
                icon: const Icon(Icons.rocket_launch),
                label: Text(
                  percent == 1.0
                      ? ' طول عمرك كفائه يا بطل!'
                      : 'وريني همتك شويه هتعرف تعمليه ولا لا',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: percent == 1.0
                      ? Colors.green
                      : const Color.fromARGB(255, 183, 58, 58),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
