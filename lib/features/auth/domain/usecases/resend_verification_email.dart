import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class ResendVerificationEmail
    implements UseCase<void, ResendVerificationEmailParams> {
  final AuthRepository authRepository;

  ResendVerificationEmail(this.authRepository);
  @override
  Future<Either<Failures, void>> call(
      ResendVerificationEmailParams params) async {
    return await authRepository.resendVerificationEmail(email: params.email);
  }
}

class ResendVerificationEmailParams {
  final String email;

  ResendVerificationEmailParams({required this.email});
}
