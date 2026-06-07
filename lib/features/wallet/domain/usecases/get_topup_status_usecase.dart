import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/topup.dart';
import '../repositories/wallet_repository.dart';

class GetTopupStatusUseCase implements UseCase<TopupStatus, String> {
  final WalletRepository repository;
  const GetTopupStatusUseCase(this.repository);

  @override
  Future<Either<Failure, TopupStatus>> call(String orderId) {
    return repository.getTopupStatus(orderId);
  }
}
