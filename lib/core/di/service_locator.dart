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
import '../../features/loan/data/repositories/loan_repository.dart';
import '../../features/loan/presentation/bloc/loan_bloc.dart';
import '../../features/notification/data/datasources/notification_remote_datasource.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/wallet/data/datasources/topup_remote_datasource.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/usecases/create_topup_usecase.dart';
import '../../features/wallet/domain/usecases/get_topup_status_usecase.dart';
import '../../features/wallet/presentation/bloc/topup_bloc.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../notifications/notification_service.dart';
import '../../features/loan/presentation/bloc/installment/installment_bloc.dart';
import '../../features/riwayat/data/repositories/transaction_repository.dart';
import '../../features/riwayat/presentation/bloc/transaction_bloc.dart';

/// Global service locator. Use [getIt] anywhere a dependency is needed.
final GetIt getIt = GetIt.instance;

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
  _registerNotification();
  _registerFinancial();
  _registerRiwayat();
  _registerProfile();
  _registerWallet();
}

// ── Core ────────────────────────────────────────────────────────────────

Future<void> _registerCore() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  // Default Dio = koperasi backend (auth-protected).
  getIt.registerLazySingleton<Dio>(DioClient.create);
  getIt.registerLazySingleton<NetworkInfo>(
    () => const AlwaysOnlineNetworkInfo(),
  );
  // Local notification service (singleton — initialized in main).
  getIt.registerSingleton<NotificationService>(NotificationService());
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
    () => AuthBloc(
      loginUseCase: getIt(),
      logoutUseCase: getIt(),
      authRepository: getIt(),
    ),
  );
  getIt.registerFactory(() => RegisterBloc(registerUseCase: getIt()));
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

  // Uses the main auth-protected Dio (same BE as profile/loans endpoints).
  getIt.registerLazySingleton<AiScoringRemoteDataSource>(
    () => AiScoringRemoteDataSourceImpl(getIt<Dio>(), getIt()),
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

// ── Notification feature ────────────────────────────────────────────────

void _registerNotification() {
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Singleton so polling state persists across the whole app session.
  getIt.registerLazySingleton(
    () => NotificationBloc(repository: getIt(), notificationService: getIt()),
  );
}

// ── Financial feature ────────────────────────────────────────────────────────

void _registerFinancial() {
  getIt.registerLazySingleton<LoanRepository>(
    () => LoanRepository(dio: getIt()),
  );
  getIt.registerFactory<LoanBloc>(() => LoanBloc(repository: getIt()));
  getIt.registerFactory<InstallmentBloc>(
    () => InstallmentBloc(repository: getIt()),
  );
}

void _registerRiwayat() {
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepository(dio: getIt()),
  );
  getIt.registerFactory<TransactionBloc>(
    () => TransactionBloc(repository: getIt()),
  );
}

// ── Profile feature ───────────────────────────────────────────────────────

void _registerProfile() {
  // Data source — uses the main auth-protected Dio (same BE as /profile).
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(getIt()),
  );

  // Repository
  getIt.registerLazySingleton<ProfileRepository>(
    () =>
        ProfileRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  // Use case
  getIt.registerLazySingleton(() => GetProfileUseCase(getIt()));

  // BLoC — factory so each page gets a fresh instance.
  getIt.registerFactory(() => ProfileBloc(getProfileUseCase: getIt()));
}

// ── Wallet feature ─────────────────────────────────────────────────────────
void _registerWallet() {
  getIt.registerLazySingleton<TopupRemoteDataSource>(
    () => TopupRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  getIt.registerLazySingleton(() => CreateTopupUseCase(getIt()));
  getIt.registerLazySingleton(() => GetTopupStatusUseCase(getIt()));

  getIt.registerFactory(
    () => TopupBloc(createTopup: getIt(), getStatus: getIt()),
  );

// ── Riwayat feature ──────────────────────────────────────────────────────
void _registerRiwayat() {
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepository(dio: getIt()),
  );
  getIt.registerFactory<TransactionBloc>(
    () => TransactionBloc(repository: getIt()),
  );
}
}
