import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Contract for a single business action.
///
/// `T` is the success payload, `Params` is the input.
/// Use [NoParams] when the use case doesn't need input.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Sentinel for use cases without parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
