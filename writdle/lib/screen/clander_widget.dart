// ignore_for_file: sort_child_properties_last, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ClanderWidget extends StatefulWidget {
  final DateTime selectedDay;
  const ClanderWidget({super.key, required this.selectedDay});

  @override
  State<ClanderWidget> createState() => _ClanderWidgetState();
}

class _ClanderWidgetState extends State<ClanderWidget> {
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
    print('[ClanderWidget] Loading tasks for $dayKey');
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tasks')
          .where('date', isEqualTo: dayKey)
          .orderBy('completed')
          .orderBy('timestamp', descending: false)
          .get();
      setState(() => _tasks = snap.docs);
      print('[ClanderWidget] Fetched ${_tasks.length} tasks');
    } catch (e) {
      print('[ClanderWidget] loadTasks ERROR: $e');
    }
  }

  Future<void> _addTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final desc = _descController.text.trim();
    final dayKey = _formatDate(widget.selectedDay);

    try {
      await FirebaseFirestore.instance.collection('tasks').add({
        'title': title,
        'description': desc,
        'completed': false,
        'date': dayKey,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('[ClanderWidget] Task added');
      _titleController.clear();
      _descController.clear();
      if (mounted) Navigator.pop(context, true);
      await _loadTasks();
    } catch (e) {
      print('[ClanderWidget] addTask ERROR: $e');
    }
  }

  Future<void> _toggleTask(DocumentSnapshot doc) async {
    final current = doc['completed'] as bool;
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(doc.id).update({
        'completed': !current,
      });
      print('[ClanderWidget] Toggled task ${doc.id} to ${!current}');
      await _loadTasks();
    } catch (e) {
      print('[ClanderWidget] toggleTask ERROR: $e');
    }
  }

  void _showAddTaskDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('إضافة مهمة'),
        content: SizedBox(
          height: 150,
          child: Column(
            children: [
              CupertinoTextField(
                controller: _titleController,
                placeholder: 'عنوان المهمة',
                autofocus: true,
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: _descController,
                placeholder: 'وصف (اختياري)',
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('إضافة'),
            isDefaultAction: true,
            onPressed: _addTask,
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

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('مهام اليوم - المتبقي: $remaining'),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (todo.isNotEmpty) ...[
                  const Text(
                    'المهام الحالية:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...todo.map(_buildTaskItem),
                  const SizedBox(height: 24),
                ],
                if (done.isNotEmpty) ...[
                  const Text(
                    'المهام المنجزة:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...done.map(_buildTaskItem),
                ],
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: CupertinoButton(
              padding: const EdgeInsets.all(16),
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(30),
              child: const Icon(CupertinoIcons.add),
              onPressed: _showAddTaskDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(DocumentSnapshot task) {
    final title = task['title'] as String;
    final desc = task['description'] as String;
    final completed = task['completed'] as bool;

    return GestureDetector(
      onTap: () => _toggleTask(task),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: completed
              ? CupertinoColors.systemGreen.withOpacity(0.3)
              : CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                decoration: completed ? TextDecoration.lineThrough : null,
                color: CupertinoColors.white,
              ),
            ),
            if (desc.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.inactiveGray,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
