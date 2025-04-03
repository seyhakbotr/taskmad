import 'dart:io';

import 'package:fpdart/fpdart.dart' as fp;
import 'package:taskmanage/core/error/failures.dart';
import 'package:taskmanage/core/usecases/usecase.dart';
import 'package:taskmanage/features/task/domain/entities/task.dart';
import 'package:taskmanage/features/task/domain/entities/topic.dart';
import 'package:taskmanage/features/task/domain/repository/task_repository.dart';

class UpdateTask implements UseCase<Task, UpdateTaskParams> {
  final TaskRepository taskRepository;

  UpdateTask(this.taskRepository);

  @override
  Future<fp.Either<Failures, Task>> call(UpdateTaskParams params) async {
    return await taskRepository.updateTask(
      taskId: params.taskId,
      image: params.image,
      title: params.title,
      description: params.description,
      creatorId: params.creatorId,
      dueDate: params.dueDate,
      priority: params.priority,
      status: params.status,
      topics: params.topics,
      currentImageUrl: params.currentImageUrl,
    );
  }
}

class UpdateTaskParams {
  final String taskId;
  final File? image;
  final String? title;
  final String? description;
  final String creatorId;
  final DateTime? dueDate;
  final String? priority;
  final String? status;
  final List<Topic>? topics;
  final String? currentImageUrl;

  UpdateTaskParams({
    required this.taskId,
    this.image,
    this.title,
    this.description,
    required this.creatorId,
    this.dueDate,
    this.priority,
    this.status,
    this.topics,
    this.currentImageUrl,
  });
}
