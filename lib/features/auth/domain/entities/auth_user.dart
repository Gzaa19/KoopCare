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

  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });

  @override
  List<Object?> get props => [id, name, phone, email];
}
