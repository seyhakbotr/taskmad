// features/task/presentation/cubit/task_operation_state.dart
import 'package:fpdart/fpdart.dart' as fp;
import 'package:taskmanage/core/error/failures.dart';
import 'package:taskmanage/features/task/domain/entities/task.dart';
import 'package:taskmanage/features/task/domain/entities/topic.dart';

abstract class TaskOperationState {
  const TaskOperationState();
}

class TaskOperationInitial extends TaskOperationState {
  const TaskOperationInitial();
}

class TaskOperationLoading extends TaskOperationState {
  const TaskOperationLoading();
}

class TaskOperationSuccess extends TaskOperationState {
  final String message;

  const TaskOperationSuccess({required this.message});
}

class TaskOperationSuccessWithTask extends TaskOperationState {
  final Task task;
  final String message;

  const TaskOperationSuccessWithTask({
    required this.task,
    required this.message,
  });
}

class TaskOperationSuccessWithTasks extends TaskOperationState {
  final List<Task> tasks;
  final String message;

  const TaskOperationSuccessWithTasks({
    required this.tasks,
    this.message = '',
  });
}

class TaskOperationFailure extends TaskOperationState {
  final Failures failure;

  const TaskOperationFailure(this.failure);
}

class TaskOperationUpdating extends TaskOperationState {
  const TaskOperationUpdating();
}

class TaskOperationLoadingTopics extends TaskOperationState {
  const TaskOperationLoadingTopics();
}

class TaskOperationSuccessWithTopics extends TaskOperationState {
  final List<Topic> topics;
  final String message;

  const TaskOperationSuccessWithTopics({
    required this.topics,
    this.message = '',
  });
}
