import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.fullName,
    required super.nik,
    required super.phone,
    required super.status,
    super.email,
    super.balance,
    super.monthlyIncome,
    super.birthDate,
    super.education,
    super.occupation,
    super.codeGender,
    super.familyStatus,
    super.ownCar,
    super.ownRealty,
    super.childrenCount,
    super.familyMembers,
    super.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String? ?? '',
      nik: json['nik'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      monthlyIncome: (json['monthly_income'] as num?)?.toDouble(),
      birthDate: _parseDate(json['birth_date']),
      education: json['education'] as String?,
      occupation: json['occupation'] as String?,
      codeGender: json['code_gender'] as String?,
      familyStatus: json['family_status'] as String?,
      ownCar: json['own_car'] as bool? ?? false,
      ownRealty: json['own_realty'] as bool? ?? false,
      childrenCount: (json['children_count'] as num?)?.toInt(),
      familyMembers: (json['family_members'] as num?)?.toInt(),
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
