import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class SendPasswordReset implements UseCase<void, SendPasswordResetParams> {
  final AuthRepository authRepository;

  SendPasswordReset(this.authRepository);
  @override
  Future<Either<Failures, void>> call(SendPasswordResetParams params) async {
    return await authRepository.sendPasswordResetEmail(email: params.email);
  }
}

class SendPasswordResetParams {
  final String email;

  SendPasswordResetParams({required this.email});
}
