import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.completed,
    required this.date,
    this.reminderAt,
    this.priority = TaskPriority.medium,
    this.category = 'General',
    this.notificationId,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool completed;
  final String date;
  final DateTime? reminderAt;
  final TaskPriority priority;
  final String category;
  final int? notificationId;

  bool get hasReminder => reminderAt != null;

  factory TaskModel.fromMap(Map<String, dynamic> data, String id) {
    final createdAtRaw = data['createdAt'];
    final reminderRaw = data['reminderAt'];
    return TaskModel(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.now(),
      completed: data['completed'] as bool? ?? false,
      date: data['date'] as String? ?? '',
      reminderAt: reminderRaw is Timestamp ? reminderRaw.toDate() : null,
      priority: TaskPriorityX.fromName(data['priority'] as String?),
      category: data['category'] as String? ?? 'General',
      notificationId: data['notificationId'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'completed': completed,
      'date': date,
      'reminderAt': reminderAt != null ? Timestamp.fromDate(reminderAt!) : null,
      'priority': priority.name,
      'category': category,
      'notificationId': notificationId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'completed': completed,
      'date': date,
      'reminderAt': reminderAt?.toIso8601String(),
      'priority': priority.name,
      'category': category,
      'notificationId': notificationId,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      completed: json['completed'] as bool? ?? false,
      date: json['date'] as String? ?? '',
      reminderAt: json['reminderAt'] == null
          ? null
          : DateTime.tryParse(json['reminderAt'] as String),
      priority: TaskPriorityX.fromName(json['priority'] as String?),
      category: json['category'] as String? ?? 'General',
      notificationId: json['notificationId'] as int?,
    );
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? completed,
    String? date,
    DateTime? reminderAt,
    bool clearReminder = false,
    TaskPriority? priority,
    String? category,
    int? notificationId,
    bool clearNotificationId = false,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      completed: completed ?? this.completed,
      date: date ?? this.date,
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      priority: priority ?? this.priority,
      category: category ?? this.category,
      notificationId: clearNotificationId
          ? null
          : (notificationId ?? this.notificationId),
    );
  }
}

enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  static TaskPriority fromName(String? value) {
    switch (value) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      default:
        return TaskPriority.medium;
    }
  }
}
