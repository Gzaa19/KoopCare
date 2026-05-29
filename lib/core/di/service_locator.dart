import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/ai_scoring/data/datasources/ai_scoring_field_mapper.dart';
import '../../features/ai_scoring/data/datasources/ai_scoring_remote_datasource.dart';
import '../../features/ai_scoring/data/repositories/ai_scoring_repository_impl.dart';
import '../../features/ai_scoring/domain/repositories/ai_scoring_repository.dart';
import '../../features/ai_scoring/domain/usecases/predict_ai_score_usecase.dart';
import '../../features/ai_scoring/presentation/bloc/ai_scoring_bloc.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/request_otp_usecase.dart';
import '../../features/auth/domain/usecases/reset_pin_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/forgot_pin/forgot_pin_bloc.dart';
import '../../features/auth/presentation/bloc/register/register_bloc.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';

/// Global service locator. Use [getIt] anywhere a dependency is needed.
final GetIt getIt = GetIt.instance;

/// Named injection tag for the ML-API Dio instance, so we can register two
/// distinct [Dio] singletons (auth-protected vs. ML).
const String mlDioInstanceName = 'mlDio';

/// Wires up the application's dependency graph.
///
/// Call once at app startup, before `runApp`.
///
/// New features should register their data sources, repositories, use cases,
/// and BLoCs here following the same layering pattern as `auth/`.
Future<void> configureDependencies() async {
  await _registerCore();
  _registerAuth();
  _registerAiScoring();
}

// ── Core ────────────────────────────────────────────────────────────────

Future<void> _registerCore() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  // Default Dio = koperasi backend (auth-protected).
  getIt.registerLazySingleton<Dio>(DioClient.create);
  // Standalone Dio for the ML API — registered under a name to disambiguate.
  getIt.registerLazySingleton<Dio>(
    DioClient.createMl,
    instanceName: mlDioInstanceName,
  );
  getIt.registerLazySingleton<NetworkInfo>(() => const AlwaysOnlineNetworkInfo());
}

// ── Auth feature ────────────────────────────────────────────────────────

void _registerAuth() {
  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt()),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => RequestOtpUseCase(getIt()));
  getIt.registerLazySingleton(() => VerifyOtpUseCase(getIt()));
  getIt.registerLazySingleton(() => ResetPinUseCase(getIt()));

  // BLoCs — factory so each page gets a fresh instance
  getIt.registerFactory(
    () => AuthBloc(loginUseCase: getIt(), logoutUseCase: getIt()),
  );
  getIt.registerFactory(
    () => RegisterBloc(registerUseCase: getIt()),
  );
  getIt.registerFactory(
    () => ForgotPinBloc(
      requestOtpUseCase: getIt(),
      verifyOtpUseCase: getIt(),
      resetPinUseCase: getIt(),
    ),
  );
}

// ── AI Scoring feature ──────────────────────────────────────────────────

void _registerAiScoring() {
  getIt.registerLazySingleton(() => const AiScoringFieldMapper());

  getIt.registerLazySingleton<AiScoringRemoteDataSource>(
    () => AiScoringRemoteDataSourceImpl(
      getIt<Dio>(instanceName: mlDioInstanceName),
      getIt(),
    ),
  );

  getIt.registerLazySingleton<AiScoringRepository>(
    () => AiScoringRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton(() => PredictAiScoreUseCase(getIt()));

  getIt.registerFactory(() => AiScoringBloc(predictUseCase: getIt()));
}
