import 'package:fpdart/fpdart.dart';

import '../../../../core/entities/user.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class SearchUsers implements UseCase<List<User>, SearchUsersParams> {
  final AuthRepository authRepository;

  SearchUsers(this.authRepository);
  @override
  Future<Either<Failures, List<User>>> call(SearchUsersParams params) async {
    return await authRepository.searchUsers(username: params.username);
  }
}

class SearchUsersParams {
  final String username;

  SearchUsersParams({required this.username});
}
