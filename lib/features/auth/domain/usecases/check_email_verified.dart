import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class CheckEmailVerified implements UseCase<bool, NoParams> {
  final AuthRepository authRepository;

  CheckEmailVerified(this.authRepository);
  @override
  Future<Either<Failures, bool>> call(NoParams params) async {
    return await authRepository.checkEmailVerified();
  }
}
