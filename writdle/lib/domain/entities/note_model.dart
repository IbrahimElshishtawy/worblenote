import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final int colorValue;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.colorValue = 0xFFFFF8E1,
  });

  static int _resolveColor(dynamic rawColor) {
    if (rawColor is int && rawColor != 0) {
      return rawColor;
    }
    if (rawColor is String) {
      return int.tryParse(rawColor) ?? 0xFFFFF8E1;
    }
    return 0xFFFFF8E1;
  }

  factory NoteModel.fromMap(Map<String, dynamic> data, String id) {
    final rawDate = data['createdAt'] ?? data['timestamp'];
    return NoteModel(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? data['description'] ?? '',
      createdAt: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
      colorValue: _resolveColor(data['colorValue']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'colorValue': colorValue,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'colorValue': colorValue,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      colorValue: _resolveColor(json['colorValue']),
    );
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    int? colorValue,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
