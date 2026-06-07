import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/topup.dart';
import '../repositories/wallet_repository.dart';

class CreateTopupUseCase implements UseCase<TopupSession, int> {
  final WalletRepository repository;
  const CreateTopupUseCase(this.repository);

  @override
  Future<Either<Failure, TopupSession>> call(int amount) {
    return repository.createTopup(amount);
  }
}
