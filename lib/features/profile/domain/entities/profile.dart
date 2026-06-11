import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final int id;
  final String fullName;
  final String nik;
  final String phone;
  final String? email;
  final String status;
  final double balance;

  final double? monthlyIncome;
  final DateTime? birthDate;
  final String? education;
  final String? occupation;
  final String? incomeType;

  final String? codeGender;
  final String? familyStatus;
  final bool ownCar;
  final bool ownRealty;
  final int? childrenCount;
  final int? familyMembers;
  final DateTime? createdAt;

  const Profile({
    required this.id,
    required this.fullName,
    required this.nik,
    required this.phone,
    required this.status,
    this.email,
    this.balance = 0,
    this.monthlyIncome,
    this.birthDate,
    this.education,
    this.occupation,
    this.incomeType,
    this.codeGender,
    this.familyStatus,
    this.ownCar = false,
    this.ownRealty = false,
    this.childrenCount,
    this.familyMembers,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    nik,
    phone,
    email,
    status,
    balance,
    monthlyIncome,
    birthDate,
    education,
    occupation,
    incomeType,
    codeGender,
    familyStatus,
    ownCar,
    ownRealty,
    childrenCount,
    familyMembers,
    createdAt,
  ];
}
