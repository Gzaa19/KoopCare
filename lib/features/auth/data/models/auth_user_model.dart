import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    required super.status,
    super.balance,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      status: json['status'] as String? ?? 'INACTIVE',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
    );
  }

  factory AuthUserModel.fromProfileJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as int,
      name: json['full_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      status: json['status'] as String? ?? 'INACTIVE',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    if (email != null) 'email': email,
    'status': status,
    'balance': balance,
  };
}
