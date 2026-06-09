import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String status;

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
