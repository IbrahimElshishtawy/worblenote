import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TasksListPage extends StatelessWidget {
  final DateTime selectedDay;
  const TasksListPage({super.key, required this.selectedDay});

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final dayKey = _formatDate(selectedDay);
    return Scaffold(
      appBar: AppBar(title: const Text('مهام اليوم')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('date', isEqualTo: dayKey)
            .where('completed', isEqualTo: false)
            .snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('لا توجد مهام متبقية'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i];
              return ListTile(
                title: Text(data['title']),
                subtitle: data['description'] != ''
                    ? Text(data['description'])
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
