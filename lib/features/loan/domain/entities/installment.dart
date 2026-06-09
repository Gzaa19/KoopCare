import 'package:equatable/equatable.dart';

class Installment extends Equatable {
  final int id;
  final int loanId;
  final int installmentNumber;
  final double amount;
  final DateTime dueDate;
  final String status;
  final DateTime? paidAt;

  const Installment({
    required this.id,
    required this.loanId,
    required this.installmentNumber,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidAt,
  });

  bool get isPaid => status == 'PAID';

  @override
  List<Object?> get props => [
        id,
        loanId,
        installmentNumber,
        amount,
        dueDate,
        status,
        paidAt,
      ];
}
