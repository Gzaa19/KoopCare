import 'package:equatable/equatable.dart';

/// Pure-Dart representation of a member's personal profile.
///
/// Mirrors the payload returned by `GET /api/v1/mobile/profile`. Lives in the
/// domain layer, so it has no JSON / Flutter / Dio knowledge. The data-layer
/// model converts into this entity.
class Profile extends Equatable {
  final int id;
  final String fullName;
  final String nik;
  final String phone;
  final String? email;
  final String status;
  final double balance;

  // ── Personal / demographic data (all optional on the backend) ──────────
  final double? monthlyIncome;
  final DateTime? birthDate;
  final String? education;
  final String? occupation;

  /// `M` or `F` as stored by the backend. Null until the member fills it in.
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
    codeGender,
    familyStatus,
    ownCar,
    ownRealty,
    childrenCount,
    familyMembers,
    createdAt,
  ];
}
