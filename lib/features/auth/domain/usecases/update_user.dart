import 'package:fpdart/fpdart.dart';

import '../../../../core/entities/user.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class UpdateUser implements UseCase<User, UpdateUserParams> {
  final AuthRepository authRepository;

  UpdateUser(this.authRepository);
  @override
  Future<Either<Failures, User>> call(UpdateUserParams params) async {
    return await authRepository.updateUser(
        name: params.name, email: params.email, password: params.password);
  }
}

class UpdateUserParams {
  final String? name;
  final String? email;
  final String? password;

  UpdateUserParams(
      {required this.name, required this.email, required this.password});
}
