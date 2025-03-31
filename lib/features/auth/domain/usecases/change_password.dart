import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class ChangePassword implements UseCase<void, ChangePasswordParams> {
  final AuthRepository authRepository;

  ChangePassword(this.authRepository);

  @override
  Future<Either<Failures, void>> call(ChangePasswordParams params) async {
    return await authRepository.changePassword(
        oldPassword: params.oldPassword, newPassword: params.newPassword);
  }
}

class ChangePasswordParams {
  final String oldPassword;
  final String newPassword;

  ChangePasswordParams({required this.oldPassword, required this.newPassword});
}
