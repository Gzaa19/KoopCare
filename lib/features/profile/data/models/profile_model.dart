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
    super.incomeType,
    super.codeGender,
    super.familyStatus,
    super.ownCar,
    super.ownRealty,
    super.childrenCount,
    super.familyMembers,
    super.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final ownCarVal = json['own_car'];
    final ownRealtyVal = json['own_realty'];
    return ProfileModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String? ?? '',
      nik: json['nik'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      balance: double.tryParse(json['balance']?.toString() ?? '') ?? 0.0,
      monthlyIncome: double.tryParse(json['monthly_income']?.toString() ?? ''),
      birthDate: _parseDate(json['birth_date']),
      education: json['education'] as String?,
      occupation: json['occupation'] as String?,
      incomeType: json['income_type'] as String?,
      codeGender: json['code_gender'] as String?,
      familyStatus: json['family_status'] as String?,
      ownCar: ownCarVal == true || ownCarVal == 1 || ownCarVal == '1',
      ownRealty: ownRealtyVal == true || ownRealtyVal == 1 || ownRealtyVal == '1',
      childrenCount: int.tryParse(json['children_count']?.toString() ?? ''),
      familyMembers: int.tryParse(json['family_members']?.toString() ?? ''),
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
