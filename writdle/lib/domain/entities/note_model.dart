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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
