import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool completed;
  final String date;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.completed,
    required this.date,
  });

  factory TaskModel.fromMap(Map<String, dynamic> data, String id) {
    return TaskModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      completed: data['completed'] ?? false,
      date: data['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'completed': completed,
      'date': date,
    };
  }
}
