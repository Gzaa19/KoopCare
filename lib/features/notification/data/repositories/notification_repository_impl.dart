import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() {
    return _guard(() async {
      final models = await remoteDataSource.getNotifications();
      return models.cast<AppNotification>();
    });
  }

  @override
  Future<Either<Failure, void>> markAsRead(int id) {
    return _guard(() => remoteDataSource.markAsRead(id));
  }

  @override
  Future<Either<Failure, void>> markAllRead() {
    return _guard(() => remoteDataSource.markAllRead());
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() {
    return _guard(() => remoteDataSource.getUnreadCount());
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final value = await action();
      return Right(value);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
