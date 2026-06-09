import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase implements UseCase<void, int> {
  final NotificationRepository repository;
  const MarkNotificationReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int id) {
    return repository.markAsRead(id);
  }
}
