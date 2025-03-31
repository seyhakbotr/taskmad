import 'dart:io';

import 'package:fpdart/fpdart.dart' as fp;
import 'package:taskmanage/core/error/failures.dart';
import 'package:taskmanage/core/usecases/usecase.dart';
import 'package:taskmanage/features/task/domain/entities/task.dart';
import 'package:taskmanage/features/task/domain/entities/topic.dart';
import 'package:taskmanage/features/task/domain/repository/task_repository.dart';

class UploadTask implements UseCase<Task, UploadTaskParams> {
  final TaskRepository taskRepository;

  UploadTask(this.taskRepository);

  @override
  Future<fp.Either<Failures, Task>> call(UploadTaskParams params) async {
    return await taskRepository.uploadTask(
        image: params.image,
        title: params.title,
        status: params.status,
        description: params.description,
        dueDate: params.dueDate,
        priority: params.priority,
        creatorId: params.creatorId,
        topics: params.topics);
  }
}

class UploadTaskParams {
  final String title;
  final String description;
  final String creatorId;
  final String status;
  final DateTime dueDate;
  final File image;
  final String priority;
  final List<Topic> topics;

  UploadTaskParams(this.image, this.topics,
      {required this.title,
      required this.description,
      required this.creatorId,
      required this.status,
      required this.dueDate,
      required this.priority});
}
