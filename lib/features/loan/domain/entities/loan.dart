import 'package:equatable/equatable.dart';

class Loan extends Equatable {
  final int id;
  final int memberId;
  final String requestNumber;
  final double amount;
  final int tenor;
  final String? purpose;
  final String type;
  final String status;
  final double? approvedAmount;
  final int? approvedTenor;
  final String? rejectionReason;
  final DateTime createdAt;
  final double? totalPaid;
  final double? totalRemaining;

  const Loan({
    required this.id,
    required this.memberId,
    required this.requestNumber,
    required this.amount,
    required this.tenor,
    this.purpose,
    required this.type,
    required this.status,
    this.approvedAmount,
    this.approvedTenor,
    this.rejectionReason,
    required this.createdAt,
    this.totalPaid,
    this.totalRemaining,
  });

  @override
  List<Object?> get props => [
        id,
        memberId,
        requestNumber,
        amount,
        tenor,
        purpose,
        type,
        status,
        approvedAmount,
        approvedTenor,
        rejectionReason,
        createdAt,
        totalPaid,
        totalRemaining,
      ];
}
