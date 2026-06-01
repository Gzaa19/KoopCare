import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_notification.dart';

/// Contract for the notification feature.
abstract class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications();
  Future<Either<Failure, void>> markAsRead(int id);
  Future<Either<Failure, void>> markAllRead();
  Future<Either<Failure, int>> getUnreadCount();
}
