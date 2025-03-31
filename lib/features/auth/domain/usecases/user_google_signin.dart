import 'package:fpdart/fpdart.dart';

import '../../../../core/entities/user.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class UserGoogleSignin implements UseCase<User, NoParams> {
  final AuthRepository authRepository;

  UserGoogleSignin(this.authRepository);
  @override
  Future<Either<Failures, User>> call(NoParams params) async {
    return await authRepository.signInWithGoogle();
  }
}
