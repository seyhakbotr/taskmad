import 'package:taskmanage/features/task/domain/entities/task.dart';

class TaskModel extends Task {
  TaskModel({
    required super.id,
    required super.title,
    required super.updatedAt,
    super.dueDate,
    super.description,
    super.status,
    super.priority,
    required super.topics,
    super.imageUrl,
    required super.creatorId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> map) {
    // Handle topics conversion without Topic.fromJson

    return TaskModel(
      id: map['id'] as String?,
      creatorId: map['creator_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      topics: List<String>.from(map['topics'] ?? []),
      status: map['status'] as String? ?? 'todo',
      imageUrl: map['image_url'] as String?,
      priority: map['priority'] as String? ?? 'medium',
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      updatedAt: map['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['updated_at']),
    );
  }
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      imageUrl: task.imageUrl,
      topics: task.topics ?? [],
      creatorId: task.creatorId,
      dueDate: task.dueDate,
      updatedAt: task.updatedAt,
    );
  }
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? imageUrl,
    List<String>? topics,
    String? creatorId,
    DateTime? dueDate,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      topics: topics ?? this.topics,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      creatorId: creatorId ?? this.creatorId,
      imageUrl: imageUrl ?? this.imageUrl,
      dueDate: dueDate ?? this.dueDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'image_url': imageUrl,
      'priority': priority,
      'creator_id': creatorId,
      'due_date': dueDate?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
