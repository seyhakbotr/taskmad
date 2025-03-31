import 'package:fpdart/fpdart.dart';
import 'package:taskmanage/core/error/failures.dart';
import 'package:taskmanage/core/usecases/usecase.dart';
import 'package:taskmanage/features/task/domain/entities/topic.dart';
import 'package:taskmanage/features/task/domain/repository/task_repository.dart';

class GetAllTaskTopics implements UseCase<List<Topic>, NoParams> {
  final TaskRepository taskRepository;

  GetAllTaskTopics(this.taskRepository);
  @override
  Future<Either<Failures, List<Topic>>> call(NoParams params) async {
    return await taskRepository.getAllTaskTopics();
  }
}
