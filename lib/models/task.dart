// lib/models/task.dart

enum Priority { low, medium, high }

enum TaskStatus { todo, inProgress, done }

// Sentinel déclaré au niveau fichier (hors classe) avec const
const _sentinel = Object();

class Task {
  final String id;
  String title;
  String description;
  Priority priority;
  TaskStatus status;
  String categoryId;
  DateTime createdAt;
  DateTime? dueDate;
  String userId;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = Priority.medium,
    this.status = TaskStatus.todo,
    this.categoryId = '',
    required this.createdAt,
    this.dueDate,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.index,
      'status': status.index,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'userId': userId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      priority: Priority.values[map['priority']],
      status: TaskStatus.values[map['status']],
      categoryId: map['categoryId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      userId: map['userId'],
    );
  }

  Task copyWith({
    String? title,
    String? description,
    Priority? priority,
    TaskStatus? status,
    String? categoryId,
    Object? dueDate = _sentinel,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt,
      dueDate: identical(dueDate, _sentinel)
          ? this.dueDate
          : (dueDate as DateTime?),
      userId: userId,
    );
  }

  String get priorityLabel {
    switch (priority) {
      case Priority.low:    return 'Faible';
      case Priority.medium: return 'Moyenne';
      case Priority.high:   return 'Haute';
    }
  }

  String get statusLabel {
    switch (status) {
      case TaskStatus.todo:       return 'À faire';
      case TaskStatus.inProgress: return 'En cours';
      case TaskStatus.done:       return 'Terminé';
    }
  }

  bool get isDone => status == TaskStatus.done;
  bool get isOverdue =>
      dueDate != null && dueDate!.isBefore(DateTime.now()) && !isDone;
}