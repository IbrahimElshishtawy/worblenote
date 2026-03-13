import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:writdle/domain/entities/task_model.dart';
import 'package:writdle/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<List<TaskModel>> getTasks(String date) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: date)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> addTask(TaskModel task) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('tasks').add({
      'userId': userId,
      'title': task.title,
      'description': task.description,
      'completed': task.completed,
      'date': task.date,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _firestore.collection('tasks').doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'completed': task.completed,
      'date': task.date,
      'createdAt': Timestamp.fromDate(task.createdAt),
    });
  }

  @override
  Future<void> deleteTask(String id, String date) async {
    await _firestore.collection('tasks').doc(id).delete();
  }
}
