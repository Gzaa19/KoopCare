import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/topup.dart';

abstract class WalletRepository {
  Future<Either<Failure, TopupSession>> createTopup(int amount);

  Future<Either<Failure, TopupStatus>> getTopupStatus(String orderId);
}
