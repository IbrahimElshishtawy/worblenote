import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:writdle/models/task_model.dart';

class TasksProvider with ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks(String date) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: date)
          .get();

      _tasks = snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String title, String description, String date) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance.collection('tasks').add({
      'userId': userId,
      'title': title,
      'description': description,
      'completed': false,
      'date': date,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await fetchTasks(date);
  }

  Future<void> toggleTaskCompletion(TaskModel task, String date) async {
    await FirebaseFirestore.instance.collection('tasks').doc(task.id).update({
      'completed': !task.completed,
    });
    await fetchTasks(date);
  }

  Future<void> deleteTask(String id, String date) async {
    await FirebaseFirestore.instance.collection('tasks').doc(id).delete();
    await fetchTasks(date);
  }
}
