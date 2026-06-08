class InstallmentModel {
  final int id;
  final int loanId;
  final int installmentNumber;
  final double amount;
  final DateTime dueDate;
  final String status; // PENDING | PAID
  final DateTime? paidAt;

  InstallmentModel({
    required this.id,
    required this.loanId,
    required this.installmentNumber,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidAt,
  });

  bool get isPaid => status == 'PAID';

  factory InstallmentModel.fromJson(Map<String, dynamic> json) {
    return InstallmentModel(
      id: json['id'],
      loanId: json['loan_id'],
      installmentNumber: json['installment_number'],
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'] ?? 'PENDING',
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'].toString())
          : null,
    );
  }
}