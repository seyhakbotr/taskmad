import 'package:fpdart/fpdart.dart';
import 'package:taskmanage/core/error/failures.dart';
import 'package:taskmanage/core/usecases/usecase.dart';
import 'package:taskmanage/features/task/domain/repository/task_repository.dart';

class DeleteTask implements UseCase<bool, DeleteTaskParams> {
  final TaskRepository taskRepository;

  DeleteTask(this.taskRepository);

  @override
  Future<Either<Failures, bool>> call(DeleteTaskParams params) async {
    return await taskRepository.deleteTask(params.taskId);
  }
}

class DeleteTaskParams {
  final String taskId;

  DeleteTaskParams({required this.taskId});
}
