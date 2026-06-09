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
import '../../features/loan/data/datasources/loan_remote_datasource.dart';
import '../../features/loan/data/repositories/loan_repository_impl.dart';
import '../../features/loan/domain/repositories/loan_repository.dart';
import '../../features/loan/domain/usecases/get_installments_usecase.dart';
import '../../features/loan/domain/usecases/get_loans_usecase.dart';
import '../../features/loan/domain/usecases/get_payment_status_usecase.dart';
import '../../features/loan/domain/usecases/pay_installment_midtrans_usecase.dart';
import '../../features/loan/domain/usecases/pay_installment_usecase.dart';
import '../../features/loan/presentation/bloc/loan_bloc.dart';
import '../../features/notification/data/datasources/notification_remote_datasource.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/notification/domain/usecases/get_notifications_usecase.dart';
import '../../features/notification/domain/usecases/get_unread_count_usecase.dart';
import '../../features/notification/domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../features/notification/domain/usecases/mark_notification_read_usecase.dart';
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
import '../../features/riwayat/data/datasources/transaction_remote_datasource.dart';
import '../../features/riwayat/data/repositories/transaction_repository_impl.dart';
import '../../features/riwayat/domain/repositories/transaction_repository.dart';
import '../../features/riwayat/domain/usecases/get_transactions_usecase.dart';
import '../../features/riwayat/presentation/bloc/transaction_bloc.dart';

final GetIt getIt = GetIt.instance;

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

Future<void> _registerCore() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerLazySingleton<Dio>(DioClient.create);
  getIt.registerLazySingleton<NetworkInfo>(
    () => const AlwaysOnlineNetworkInfo(),
  );
  getIt.registerSingleton<NotificationService>(NotificationService());
}

void _registerAuth() {
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => RequestOtpUseCase(getIt()));
  getIt.registerLazySingleton(() => VerifyOtpUseCase(getIt()));
  getIt.registerLazySingleton(() => ResetPinUseCase(getIt()));

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

void _registerAiScoring() {
  getIt.registerLazySingleton(() => const AiScoringFieldMapper());

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

  getIt.registerLazySingleton(() => GetNotificationsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetUnreadCountUseCase(getIt()));
  getIt.registerLazySingleton(() => MarkNotificationReadUseCase(getIt()));
  getIt.registerLazySingleton(() => MarkAllNotificationsReadUseCase(getIt()));

  getIt.registerLazySingleton(
    () => NotificationBloc(
      getNotifications: getIt(),
      getUnreadCount: getIt(),
      markRead: getIt(),
      markAllRead: getIt(),
      notificationService: getIt(),
    ),
  );
}

void _registerFinancial() {
  getIt.registerLazySingleton<LoanRemoteDataSource>(
    () => LoanRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<LoanRepository>(
    () => LoanRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton(() => GetLoansUseCase(getIt()));
  getIt.registerLazySingleton(() => GetInstallmentsUseCase(getIt()));
  getIt.registerLazySingleton(() => PayInstallmentUseCase(getIt()));
  getIt.registerLazySingleton(() => PayInstallmentMidtransUseCase(getIt()));
  getIt.registerLazySingleton(() => GetPaymentStatusUseCase(getIt()));

  getIt.registerFactory<LoanBloc>(
    () => LoanBloc(getLoans: getIt()),
  );
  getIt.registerFactory<InstallmentBloc>(
    () => InstallmentBloc(
      getInstallments: getIt(),
      payInstallment: getIt(),
      payMidtrans: getIt(),
      getPaymentStatus: getIt(),
    ),
  );
}

void _registerRiwayat() {
  getIt.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetTransactionsUseCase(getIt()),
  );
  getIt.registerFactory<TransactionBloc>(
    () => TransactionBloc(getTransactions: getIt()),
  );
}

void _registerProfile() {
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () =>
        ProfileRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  getIt.registerLazySingleton(() => GetProfileUseCase(getIt()));

  getIt.registerFactory(() => ProfileBloc(getProfileUseCase: getIt()));
}

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
}
