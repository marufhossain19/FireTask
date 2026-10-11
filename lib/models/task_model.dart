import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { low, medium, high }

extension TaskPriorityExtension on TaskPriority {
  String get name {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  static TaskPriority fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String courseBucket;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final String? userId;

  String get category => courseBucket;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.courseBucket = 'Educational',
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    DateTime? createdAt,
    this.userId,
  }) : createdAt = createdAt ?? DateTime.now();

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? courseBucket,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      courseBucket: courseBucket ?? this.courseBucket,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'courseBucket': courseBucket,
      'category': courseBucket,
      'priority': priority.name.toLowerCase(),
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  Map<String, dynamic> toJsonMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'courseBucket': courseBucket,
      'category': courseBucket,
      'priority': priority.name.toLowerCase(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return TaskModel(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: parseDate(map['dueDate']),
      courseBucket: map['category'] ?? map['courseBucket'] ?? 'Educational',
      priority: TaskPriorityExtension.fromString(map['priority']),
      isCompleted: map['isCompleted'] ?? false,
      createdAt: parseDate(map['createdAt']),
      userId: map['userId'],
    );
  }
}
