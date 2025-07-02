import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final DateTime timestamp;
  final bool isDone;

  TaskModel({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.isDone,
  });

  factory TaskModel.fromMap(Map<String, dynamic> data, String id) {
    return TaskModel(
      id: id,
      title: data['title'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isDone: data['isDone'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'timestamp': timestamp, 'isDone': isDone};
  }
}
