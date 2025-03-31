import 'dart:io';

import 'package:fpdart/fpdart.dart' as fp;
import 'package:taskmanage/core/error/failures.dart';
import 'package:taskmanage/features/task/domain/entities/task.dart';
import 'package:taskmanage/features/task/domain/entities/topic.dart';

abstract interface class TaskRepository {
  Future<fp.Either<Failures, Task>> uploadTask({
    required File image,
    required String title,
    required String description,
    required DateTime dueDate,
    required String status,
    required String priority,
    required String creatorId,
    required List<Topic> topics,
  });

  Future<fp.Either<Failures, bool>> deleteTask(String taskId);
  Future<fp.Either<Failures, List<Task>>> getUserTasks(
      {List<String>? topicIds, required String userId});

  Future<fp.Either<Failures, List<Topic>>> getAllTaskTopics();
  Future<fp.Either<Failures, Task>> updateTask({
    required String taskId,
    File? image,
    required String title,
    required DateTime dueDate,
    required String priority,
    required String status,
    required String description,
    required String creatorId,
    required List<Topic> topics,
    String? currentImageUrl,
  });
}
