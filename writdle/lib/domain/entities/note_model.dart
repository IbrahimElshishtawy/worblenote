import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory NoteModel.fromMap(Map<String, dynamic> data, String id) {
    final rawDate = data['createdAt'] ?? data['timestamp'];
    return NoteModel(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? data['description'] ?? '',
      createdAt: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'content': content, 'createdAt': createdAt};
  }
}
