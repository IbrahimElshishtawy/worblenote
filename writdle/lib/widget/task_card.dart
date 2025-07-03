import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final DocumentSnapshot task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
  });

  Future<void> _delete() async {
    await FirebaseFirestore.instance.collection('tasks').doc(task.id).delete();
    onToggle();
  }

  Future<void> _toggle() async {
    final current = task['completed'] as bool;
    await FirebaseFirestore.instance.collection('tasks').doc(task.id).update({
      'completed': !current,
    });
    onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final title = task['title'] as String;
    final desc = task['description'] as String;
    final completed = task['completed'] as bool;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: completed
          ? const Color.fromARGB(192, 77, 78, 77)
          : const Color.fromARGB(107, 99, 99, 99),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            color: completed ? Colors.green : Colors.grey,
          ),
          onPressed: _toggle,
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: desc.isNotEmpty ? Text(desc) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _delete,
            ),
          ],
        ),
      ),
    );
  }
}
