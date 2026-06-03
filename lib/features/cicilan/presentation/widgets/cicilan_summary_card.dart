import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/features/loan/data/models/loan_model.dart';

/// Summary card showing loan type, contract number, total amount, tenor, and date.
class CicilanSummaryCard extends StatelessWidget {
  final LoanModel loan;

  const CicilanSummaryCard({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final loanAmount = loan.approvedAmount ?? loan.amount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kPutih,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8F0D8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0D8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  loan.type == 'MURABAHAH' ? 'Murabahah' : 'Qardhul Hasan',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: kHijauTua,
                  ),
                ),
              ),
              Text(
                '# ${loan.requestNumber.substring(0, (loan.requestNumber.length > 12 ? 12 : loan.requestNumber.length))}',
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Total Kewajiban Pembiayaan',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatter.format(loanAmount),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tenor', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
                  const SizedBox(height: 2),
                  Text('${loan.approvedTenor ?? loan.tenor} Bulan', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Tanggal Persetujuan', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMM yyyy').format(loan.createdAt),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
