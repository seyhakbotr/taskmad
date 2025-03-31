import 'package:taskmanage/features/task/domain/entities/topic.dart';

class Task {
  final String? id;
  final String title;
  final String? description;
  final String? projectId;
  final String creatorId;
  final String? status; // Enum: 'todo', 'in_progress', 'done', etc.
  final String? priority; // Enum: 'low', 'medium', 'high'
  final DateTime? dueDate;
  final List<String>? topics;
  final double? estimatedHours;
  final String? imageUrl;
  final bool? isRecurring;
  final String? recurringPattern;
  final String? parentTaskId;
  final DateTime updatedAt;

  Task({
    this.id,
    required this.title,
    this.description,
    this.projectId,
    required this.creatorId,
    this.status = 'todo',
    this.priority = 'medium',
    required this.dueDate,
    this.estimatedHours,
    this.topics,
    this.imageUrl,
    this.isRecurring = false,
    this.recurringPattern,
    this.parentTaskId,
    required this.updatedAt,
  });
  //Task copyWith({
  //  String? priority,
  //  String? status,
  //  List<Topic>? topics,
  //  String? title,
  //  String? description,
  //  String? projectId,
  //  String? creatorId,
  //  DateTime? dueDate,
  //  double? estimatedHours,
  //  String? imageUrl,
  //  bool? isRecurring,
  //  String? recurringPattern,
  //  String? parentTaskId,
  //  DateTime? updatedAt,
  //}) {
  //  return Task(
  //    id: id,
  //    title: title ?? this.title,
  //    description: description ?? this.description,
  //    projectId: projectId ?? this.projectId,
  //    creatorId: creatorId ?? this.creatorId,
  //    status: status ?? this.status,
  //    priority: priority ?? this.priority,
  //    dueDate: dueDate ?? this.dueDate,
  //    estimatedHours: estimatedHours ?? this.estimatedHours,
  //    topics: topics ?? this.topics,
  //    imageUrl: imageUrl ?? this.imageUrl,
  //    isRecurring: isRecurring ?? this.isRecurring,
  //    recurringPattern: recurringPattern ?? this.recurringPattern,
  //    parentTaskId: parentTaskId ?? this.parentTaskId,
  //    updatedAt: updatedAt ?? this.updatedAt,
  //  );
  //}
}
