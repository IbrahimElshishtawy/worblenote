// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:writdle/widget/task_card.dart';

class TasksPage extends StatefulWidget {
  final DateTime selectedDay;
  const TasksPage({super.key, required this.selectedDay});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  List<DocumentSnapshot> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<void> _loadTasks() async {
    final dayKey = _formatDate(widget.selectedDay);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: uid) // ✅ تم التعديل هنا
          .where('date', isEqualTo: dayKey)
          .get();

      final docs = snap.docs;
      docs.sort((a, b) {
        final ta = (a['timestamp'] as Timestamp).toDate();
        final tb = (b['timestamp'] as Timestamp).toDate();
        return ta.compareTo(tb);
      });

      setState(() => _tasks = docs);
      debugPrint('📥 Loaded ${docs.length} task(s) for $dayKey');
    } catch (e) {
      debugPrint('❌ loadTasks ERROR: $e');
    }
  }

  Future<void> _showAddEditDialog({DocumentSnapshot? doc}) async {
    if (doc != null) {
      _titleController.text = doc['title'];
      _descController.text = doc['description'];
    } else {
      _titleController.clear();
      _descController.clear();
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(doc != null ? 'Edit Task' : 'Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description (opt)'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(doc != null ? 'Save' : 'Add'),
            onPressed: () async {
              final title = _titleController.text.trim();
              if (title.isEmpty) return;
              final desc = _descController.text.trim();
              final dayKey = _formatDate(widget.selectedDay);
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;

              try {
                final col = FirebaseFirestore.instance.collection('tasks');
                if (doc != null) {
                  await col.doc(doc.id).update({
                    'title': title,
                    'description': desc,
                    'timestamp': DateTime.now(),
                  });
                  debugPrint('✏️ Task updated: $title');
                } else {
                  await col.add({
                    'userId': uid, // ✅ تم التعديل هنا
                    'title': title,
                    'description': desc,
                    'completed': false,
                    'date': dayKey,
                    'timestamp': DateTime.now(),
                  });
                  debugPrint('🆕 Task added: $title');
                }
                Navigator.pop(context);
                await _loadTasks();
              } catch (e) {
                debugPrint('❌ add/edit ERROR: $e');
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todo = _tasks.where((t) => t['completed'] == false).toList();
    final done = _tasks.where((t) => t['completed'] == true).toList();
    final remaining = todo.length;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Tasks – Remaining: $remaining')),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (todo.isNotEmpty) ...[
              const Text(
                'Current Tasks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...todo.map(
                (t) => TaskCard(
                  task: t,
                  onToggle: _loadTasks,
                  onEdit: () => _showAddEditDialog(doc: t),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (done.isNotEmpty) ...[
              const Text(
                'Completed Tasks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...done.map(
                (t) => TaskCard(
                  task: t,
                  onToggle: _loadTasks,
                  onEdit: () => _showAddEditDialog(doc: t),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddEditDialog(),
      ),
    );
  }
}
