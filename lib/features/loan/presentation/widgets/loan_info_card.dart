import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/features/loan/data/models/loan_model.dart';

/// A premium info card displaying loan details (amount, monthly payment, remaining duration)
/// originally extracted from `pembayaran_detail_page.dart`.
class LoanInfoCard extends StatelessWidget {
  final LoanModel? loan;
  final int paidIndicesCount;

  const LoanInfoCard({
    super.key,
    required this.loan,
    required this.paidIndicesCount,
  });

  @override
  Widget build(BuildContext context) {
    final String reqNum = loan?.requestNumber ?? '#AKD100';
    final String typeLabel = loan?.type == 'QARDHUL_HASAN'
        ? 'Qardhul Hasan - Kebajikan'
        : 'Murabahah - Jual Beli';
    final int totalTenor = loan?.approvedTenor ?? loan?.tenor ?? 6;
    final double totalAmount = loan?.approvedAmount ?? loan?.amount ?? 1080000;
    final double monthlyAmount = totalTenor > 0
        ? (totalAmount / totalTenor)
        : 0;

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final formattedTotal = formatter.format(totalAmount);
    final formattedMonthly = formatter.format(monthlyAmount);

    final int remainingCicilan = totalTenor - paidIndicesCount;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kPutih,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nomor Pembiayaan',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF888888),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            reqNum,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2E14),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            typeLabel,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
          Text(
            '$totalTenor Bulan Cicilan',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          _infoRow(
            'Total Pembiayaan',
            formattedTotal,
            valueColor: kHijauTua,
            valueBold: true,
          ),
          const SizedBox(height: 10),
          _infoRow(
            'Cicilan per Bulan',
            formattedMonthly,
            valueColor: const Color(0xFF1A1A1A),
          ),
          const SizedBox(height: 10),
          _infoRow(
            'Sisa Cicilan',
            '$remainingCicilan Bulan',
            valueColor: const Color(0xFFE07B00),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    required Color valueColor,
    bool valueBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: valueBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
