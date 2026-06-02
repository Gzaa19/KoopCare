import 'package:equatable/equatable.dart';

/// Pure-Dart representation of an authenticated user.
///
/// Lives in the domain layer, so it has no JSON / Flutter / Dio knowledge.
/// Data-layer models extend or convert into this entity.
class AuthUser extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String status;

  /// Current simpanan balance in Rupiah. Defaults to 0 until a profile
  /// fetch or login response provides the real value.
  final double balance;

  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.status,
    this.balance = 0,
  });

  AuthUser copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? status,
    double? balance,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      balance: balance ?? this.balance,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, email, status, balance];
}
