import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';

/// Contract the auth feature exposes to the rest of the app.
///
/// Implementations live in `data/repositories/`. Use cases depend only on
/// this interface, never on a concrete implementation.
abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> login({
    required String identifier,
    required String pin,
  });

  Future<Either<Failure, AuthUser>> register({
    required String fullName,
    required String phone,
    required String nik,
    required String pin,
    String? email,
    int monthlyIncome = 0,
  });

  Future<Either<Failure, void>> logout();

  Future<bool> isLoggedIn();

  /// Lupa PIN — kirim OTP via WhatsApp.
  Future<Either<Failure, void>> requestOtp(String identifier);

  /// Lupa PIN — verifikasi OTP yang diterima user.
  Future<Either<Failure, void>> verifyOtp({
    required String identifier,
    required String otp,
  });

  /// Lupa PIN — set PIN baru setelah OTP terverifikasi.
  Future<Either<Failure, void>> resetPin({
    required String identifier,
    required String otp,
    required String newPin,
  });
}
