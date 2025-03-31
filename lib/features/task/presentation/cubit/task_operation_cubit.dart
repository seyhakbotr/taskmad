// features/task/presentation/cubit/task_operation_cubit.dart
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:taskmanage/core/error/failures.dart';
import 'package:taskmanage/core/usecases/usecase.dart';
import 'package:taskmanage/features/task/domain/entities/task.dart';
import 'package:taskmanage/features/task/domain/entities/topic.dart';
import 'package:taskmanage/features/task/domain/usecases/tasks/delete_task.dart';
import 'package:taskmanage/features/task/domain/usecases/tasks/get_all_task_topics.dart';
import 'package:taskmanage/features/task/domain/usecases/tasks/get_user_tasks.dart';
import 'package:taskmanage/features/task/domain/usecases/tasks/update_task.dart';
import 'package:taskmanage/features/task/domain/usecases/tasks/upload_task.dart';
import 'package:taskmanage/features/task/presentation/cubit/task_operation_state.dart';

class TaskOperationCubit extends Cubit<TaskOperationState> {
  List<Topic> _availableTopics = [];
  List<Topic> get availableTopics => _availableTopics;
  final UploadTask uploadTask;
  final DeleteTask deleteTask;
  final GetUserTasks getUserTasks;
  final UpdateTask updateTask;
  final GetAllTaskTopics getAllTaskTopics;
  TaskOperationCubit({
    required this.uploadTask,
    required this.deleteTask,
    required this.getUserTasks,
    required this.getAllTaskTopics,
    required this.updateTask,
  }) : super(TaskOperationInitial());

  Future<void> uploadNewTask({
    required File image,
    required List<Topic> topics,
    required String title,
    required String description,
    required String status,
    required String creatorId,
    required DateTime dueDate,
    required String priority,
  }) async {
    emit(TaskOperationLoading());

    final result = await uploadTask(UploadTaskParams(
      image,
      topics,
      title: title,
      description: description,
      status: status,
      creatorId: creatorId,
      dueDate: dueDate,
      priority: priority,
    ));

    emit(_handleOperationResult(
      result,
      successMessage: 'Task uploaded successfully',
    ));
  }

  Future<void> fetchAllTaskTopics() async {
    emit(TaskOperationLoadingTopics());

    final result = await getAllTaskTopics(NoParams());

    result.fold(
      (failure) => emit(TaskOperationFailure(failure)),
      (topics) {
        _availableTopics = topics;
        emit(TaskOperationSuccessWithTopics(
          topics: topics,
          message: 'Topics loaded successfully',
        ));
      },
    );
  }

  Future<void> updateExistingTask({
    required String taskId,
    File? image,
    required String title,
    required String description,
    required String creatorId,
    required DateTime dueDate,
    required String priority,
    required String status,
    required List<Topic> topics,
    String? currentImageUrl,
  }) async {
    emit(TaskOperationUpdating());

    final result = await updateTask(UpdateTaskParams(
      taskId: taskId,
      image: image,
      title: title,
      description: description,
      creatorId: creatorId,
      dueDate: dueDate,
      priority: priority,
      status: status,
      topics: topics,
      currentImageUrl: currentImageUrl,
    ));

    emit(_handleOperationResult(
      result,
      successMessage: 'Task updated successfully',
    ));
  }

  Future<void> deleteExistingTask(String taskId) async {
    emit(TaskOperationLoading());

    final result = await deleteTask(DeleteTaskParams(taskId: taskId));

    emit(_handleOperationResult(
      result,
      successMessage: 'Task deleted successfully',
    ));
  }

  Future<void> getUserTasksList({
    required String userId,
    List<String>? topicIds,
  }) async {
    final previousTasks = state is TaskOperationSuccessWithTasks
        ? (state as TaskOperationSuccessWithTasks).tasks
        : null;

    emit(TaskOperationLoading(previousTasks: previousTasks));

    final result = await getUserTasks(GetUserTasksParams(
      userId: userId,
      topicIds: topicIds,
    ));

    emit(result.fold(
      (failure) => TaskOperationFailure(failure),
      (tasks) => TaskOperationSuccessWithTasks(
        tasks: tasks,
        message: 'Tasks retrieved successfully',
      ),
    ));
  }

  TaskOperationState _handleOperationResult(
    fp.Either<Failures, dynamic> result, {
    required String successMessage,
  }) {
    return result.fold(
      (failure) => TaskOperationFailure(failure),
      (successResult) {
        if (successResult is bool && successResult) {
          return TaskOperationSuccess(message: successMessage);
        } else if (successResult is Task) {
          return TaskOperationSuccessWithTask(
            task: successResult,
            message: successMessage,
          );
        } else if (successResult is List<Task>) {
          return TaskOperationSuccessWithTasks(
            tasks: successResult,
            message: successMessage,
          );
        }
        return TaskOperationSuccess(message: successMessage);
      },
    );
  }
}
