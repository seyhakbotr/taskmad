import 'package:fpdart/fpdart.dart' as fp;
import 'package:taskmanage/core/error/failures.dart';
import 'package:taskmanage/core/usecases/usecase.dart';
import 'package:taskmanage/features/task/domain/entities/task.dart';
import 'package:taskmanage/features/task/domain/repository/task_repository.dart';

class GetUserTasks implements UseCase<List<Task>, GetUserTasksParams> {
  final TaskRepository taskRepository;

  GetUserTasks(this.taskRepository);
  @override
  Future<fp.Either<Failures, List<Task>>> call(params) async {
    return await taskRepository.getUserTasks(
        userId: params.userId, topicIds: params.topicIds);
  }
}

class GetUserTasksParams {
  final String userId;
  final List<String>? topicIds;

  GetUserTasksParams({required this.userId, this.topicIds});
}
