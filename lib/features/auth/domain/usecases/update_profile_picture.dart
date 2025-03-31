import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/entities/user.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class UpdateProfilePicture
    implements UseCase<User, UpdateProfilePictureParams> {
  final AuthRepository authRepository;

  UpdateProfilePicture(this.authRepository);

  @override
  Future<Either<Failures, User>> call(UpdateProfilePictureParams params) async {
    return await authRepository.updateProfilePicture(
        avatarImage: params.avatarImage);
  }
}

class UpdateProfilePictureParams {
  final File avatarImage;

  UpdateProfilePictureParams({required this.avatarImage});
}
