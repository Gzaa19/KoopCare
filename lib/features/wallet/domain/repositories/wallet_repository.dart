import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/topup.dart';

/// Contract the wallet feature exposes. Use cases depend only on this.
abstract class WalletRepository {
  /// Creates a Midtrans Snap transaction for [amount] (whole rupiah).
  Future<Either<Failure, TopupSession>> createTopup(int amount);

  /// Polls the settlement status of a given [orderId].
  Future<Either<Failure, TopupStatus>> getTopupStatus(String orderId);
}
