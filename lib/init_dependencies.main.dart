part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await dotenv.load(fileName: ".env");
  usePathUrlStrategy();
  _initAuth();
  _initTask();

  // Initialize Supabase
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
    debug: true,
  );

  String hivePath;
  if (kIsWeb) {
    hivePath = '.'; // Use current directory for web
  } else {
    final appDocDir = await getApplicationDocumentsDirectory();
    hivePath = appDocDir.path;
  }

  // Initialize Hive
  Hive.init(hivePath);

  // Register Supabase client
  serviceLocator.registerLazySingleton(() => supabase.client);

  // Register other services
  serviceLocator.registerFactory(() => InternetConnection());

  // Open necessary Hive boxes

  // Ensure Hive boxes are registered in serviceLocator
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerLazySingleton(() => ThemeCubit());
  serviceLocator.registerFactory<ConnectionChecker>(
      () => ConnectionCheckerImpl(serviceLocator()));
}

void _initAuth() {
  // Datasource
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator(), serviceLocator()),
    )
    // Usecases
    ..registerFactory(() => UserSignUp(serviceLocator()))
    ..registerFactory(() => UserLogin(serviceLocator()))
    ..registerFactory(() => CurrentUser(serviceLocator()))
    ..registerFactory(() => UserLogout(serviceLocator()))
    ..registerFactory(() => UpdateUser(serviceLocator()))
    ..registerFactory(() => ResendVerificationEmail(serviceLocator()))
    ..registerFactory(() => CheckEmailVerified(serviceLocator()))
    ..registerFactory(() => SendPasswordReset(serviceLocator()))
    ..registerFactory(() => ResetPassword(serviceLocator()))
    ..registerFactory(() => UpdateProfilePicture(serviceLocator()))
    ..registerFactory(() => SearchUsers(serviceLocator()))
    ..registerFactory(() => UserGoogleSignin(serviceLocator()))
    ..registerFactory(() => ChangePassword(serviceLocator()))
    // Bloc
    ..registerLazySingleton(() => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
        userLogout: serviceLocator(),
        updateUser: serviceLocator(),
        resendVerificationEmail: serviceLocator(),
        checkEmailVerified: serviceLocator(),
        updateProfilePicture: serviceLocator(),
        resetPassword: serviceLocator(),
        searchUsers: serviceLocator(),
        userGoogleSignin: serviceLocator(),
        changePassword: serviceLocator(),
        sendPasswordReset: serviceLocator()));
}

void _initTask() {
  //  Datasource
  serviceLocator
    ..registerFactory<TaskRemoteDataSource>(
      () => TaskRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<TaskRepository>(
      () => TaskRepositoryImpl(serviceLocator(), serviceLocator()),
    )
    ..registerFactory(() => UploadTask(serviceLocator()))
    ..registerFactory(() => UpdateTask(serviceLocator()))
    ..registerFactory(() => DeleteTask(serviceLocator()))
    ..registerFactory(() => GetUserTasks(serviceLocator()))
    ..registerFactory(() => GetAllTaskTopics(serviceLocator()))

    // cubit
    ..registerLazySingleton(() => TaskOperationCubit(
        uploadTask: serviceLocator(),
        deleteTask: serviceLocator(),
        updateTask: serviceLocator(),
        getAllTaskTopics: serviceLocator(),
        getUserTasks: serviceLocator()));
}
