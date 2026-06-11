import '../../domain/entities/loan.dart';

class LoanModel {
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

  LoanModel({
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

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'],
      memberId: json['member_id'],
      requestNumber: json['request_number'],
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      tenor: json['tenor'] ?? 0,
      purpose: json['purpose'],
      type: json['type'] ?? 'MURABAHAH',
      status: json['status'] ?? 'PENDING',
      approvedAmount: json['approved_amount'] != null
          ? double.tryParse(json['approved_amount'].toString())
          : null,
      approvedTenor: json['approved_tenor'],
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      totalPaid: json['total_paid'] != null
          ? double.tryParse(json['total_paid'].toString())
          : null,
      totalRemaining: json['total_remaining'] != null
          ? double.tryParse(json['total_remaining'].toString())
          : null,
    );
  }

  Loan toEntity() {
    return Loan(
      id: id,
      memberId: memberId,
      requestNumber: requestNumber,
      amount: amount,
      tenor: tenor,
      purpose: purpose,
      type: type,
      status: status,
      approvedAmount: approvedAmount,
      approvedTenor: approvedTenor,
      rejectionReason: rejectionReason,
      createdAt: createdAt,
      totalPaid: totalPaid,
      totalRemaining: totalRemaining,
    );
  }
}
