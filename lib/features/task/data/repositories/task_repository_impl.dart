import 'dart:io';

import 'package:fpdart/fpdart.dart' as fp; // Aliased as 'fp'
import 'package:taskmanage/core/error/exceptions.dart';
import 'package:taskmanage/core/error/failures.dart';
import 'package:taskmanage/core/network/connection_checker.dart';
import 'package:taskmanage/features/task/data/datasources/task_remote_data_source.dart';
import 'package:taskmanage/features/task/data/models/task_model.dart';
import 'package:taskmanage/features/task/domain/entities/topic.dart';
import 'package:taskmanage/features/task/domain/repository/task_repository.dart';
import 'package:taskmanage/features/task/domain/entities/task.dart';
import 'package:uuid/uuid.dart'; // Your Task

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource taskRemoteDataSource;
  final ConnectionChecker connectionChecker;

  TaskRepositoryImpl(this.taskRemoteDataSource, this.connectionChecker);

  @override
  Future<fp.Either<Failures, bool>> deleteTask(String taskId) async {
    try {
      await taskRemoteDataSource.deleteTask(taskId);
      return fp.right(true); // Use fp.right
    } on ServerException catch (e) {
      return fp.left(Failures(e.message)); // Use fp.left
    } catch (e) {
      return fp.left(Failures('An unknown error occurred.'));
    }
  }

  @override
  Future<fp.Either<Failures, List<Task>>> getUserTasks(
      {List<String>? topicIds, required String userId}) async {
    try {
      //if (!await (connectionChecker.isConnected)) {
      //  final blogs = blogLocalDataSource.loadBlogs();
      //  return fp.right(blogs);
      //}

      final tasks = await taskRemoteDataSource.getUserTasks(
          userId: userId, topicIds: topicIds);
      print("Task from repos ${tasks}");
      //blogLocalDataSource.uploadLocalBlog(blogs: blogs);
      return fp.right(tasks);
    } on ServerException catch (e) {
      return fp.left(Failures(e.message));
    }
  }

  @override
  Future<fp.Either<Failures, Task>> updateTask({
    required String taskId,
    File? image,
    String? title,
    String? description,
    required creatorId,
    DateTime? dueDate,
    String? priority,
    String? status,
    List<Topic>? topics,
    String? currentImageUrl,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return fp.left(Failures('No Internet Connection!')); // fp.left
      }
      print("Updating task with the following details:");
      print("taskId: $taskId");
      print("image: $image");
      print("title: $title");
      print("description: $description");
      print("creatorId: $creatorId");
      print("dueDate: ${dueDate?.toIso8601String()}");
      print("priority: $priority");
      print("status: $status");
      print("topics: ${topics?.map((topic) => topic.id).join(', ')}");
      print("currentImageUrl: $currentImageUrl");
      TaskModel updatedTask = TaskModel(
        id: taskId,
        creatorId: creatorId,
        title: title ?? '',
        description: description,
        dueDate: dueDate,
        priority: priority,
        status: status,
        imageUrl: currentImageUrl ?? '',
        topics: topics
            ?.map((topic) => topic.id)
            .toList(), // Extract IDs for insertion
        updatedAt: DateTime.now(),
      );
      print("UpdaatedTask ${updatedTask}");
      if (image != null) {
        final imageUrl = await taskRemoteDataSource.uploadTaskImage(
          image: image,
          task: updatedTask,
        );
        updatedTask = updatedTask.copyWith(imageUrl: imageUrl);
      } else if (currentImageUrl != null) {
        updatedTask = updatedTask.copyWith(imageUrl: currentImageUrl);
      }

      final updatedTaskModel =
          await taskRemoteDataSource.updateTask(updatedTask);

      // Handle topic associations
      if (topics != null) {
        await taskRemoteDataSource.updateTaskTopics(taskId, topics);
      }
      return fp.right(updatedTaskModel); // fp.right + convert to Task
    } on ServerException catch (e) {
      return fp.left(Failures(e.message));
    } catch (e) {
      return fp.left(Failures('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<fp.Either<Failures, Task>> uploadTask({
    required File image,
    required String title,
    required String description,
    required String creatorId,
    required String status,
    required DateTime dueDate,
    required String priority,
    required List<Topic> topics,
  }) async {
    try {
      //if (!await connectionChecker.isConnected) {
      //  return fp.left(Failures('No Internet Connection!')); // fp.left
      //}
      TaskModel taskModel = TaskModel(
        id: const Uuid().v1(),
        creatorId: creatorId,
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        status: status,
        imageUrl: '',
        topics: topics
            .map((topic) => topic.id)
            .toList(), // Extract IDs for insertion
        updatedAt: DateTime.now(),
      );
      final imageUrl = await taskRemoteDataSource.uploadTaskImage(
        image: image,
        task: taskModel,
      );
      print("Image URL $imageUrl");
      taskModel = taskModel.copyWith(imageUrl: imageUrl);
      final uploadedTask = await taskRemoteDataSource.uploadTask(taskModel);

      for (var topic in topics) {
        await taskRemoteDataSource.insertTaskTopic(
          taskId: uploadedTask.id ?? '',
          topicId: topic.id,
        );
      }

      return fp.right(uploadedTask); // fp.right + convert to Task
    } on ServerException catch (e) {
      return fp.left(Failures(e.message));
    } catch (e) {
      return fp.left(Failures('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<fp.Either<Failures, List<Topic>>> getAllTaskTopics() async {
    try {
      final topics = await taskRemoteDataSource.getAllTaskTopics();
      return fp.right(topics);
    } on ServerException catch (e) {
      return fp.left(Failures(e.message));
    } catch (e) {
      return fp.left(Failures('An unexpected error occurred: ${e.toString()}'));
    }
  }
}
