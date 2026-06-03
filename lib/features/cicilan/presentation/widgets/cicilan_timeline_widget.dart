import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/features/loan/data/models/loan_model.dart';

/// Timeline showing installment schedule for an active/approved loan,
/// or a pending notice if the loan is still awaiting approval.
class CicilanTimelineWidget extends StatelessWidget {
  final LoanModel loan;

  const CicilanTimelineWidget({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    if (loan.status == 'PENDING') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFE0B2), width: 1),
        ),
        child: const Row(
          children: [
            Icon(Icons.hourglass_empty_rounded, color: Color(0xFFEF6C00)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Pembiayaan sedang diproses. Jadwal cicilan akan aktif setelah disetujui admin.",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE65100),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final monthlyAmount =
        loan.approvedAmount != null &&
            loan.approvedTenor != null &&
            loan.approvedTenor! > 0
        ? loan.approvedAmount! / loan.approvedTenor!
        : 0.0;
    
    final formattedAmount = formatter.format(monthlyAmount);
    final tenor = loan.approvedTenor ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Jadwal Pembayaran Cicilan",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(tenor, (index) {
          final monthNum = index + 1;
          final dueDate = loan.createdAt.add(Duration(days: 30 * monthNum));
          final formattedDate = DateFormat('dd MMM yyyy').format(dueDate);
          final status = monthNum == 1 ? "Pending" : "Due";
          final isCurrent = monthNum == 1;

          return _buildTimelineItem(
            monthNum,
            formattedDate,
            formattedAmount,
            status,
            isCurrent,
            index == tenor - 1,
          );
        }),
      ],
    );
  }

  Widget _buildTimelineItem(int index, String dueDate, String amount, String status, bool isCurrent, bool isLast) {
    final statusColor = switch (status) {
      'Pending' => const Color(0xFFEF6C00),
      'Due' => const Color(0xFF666666),
      _ => const Color(0xFF2E7D32),
    };

    final statusBgColor = switch (status) {
      'Pending' => const Color(0xFFFFF3E0),
      'Due' => const Color(0xFFF5F5F5),
      _ => const Color(0xFFE8F5E9),
    };

    final statusLabel = switch (status) {
      'Pending' => 'Tagihan Aktif',
      'Due' => 'Akan Datang',
      _ => 'Lunas',
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCurrent ? kHijauTua : const Color(0xFFE8F0D8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCurrent ? kPutih : kHijauTua,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: const Color(0xFFE8F0D8),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: kPutih,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent
                    ? kHijauTua.withValues(alpha: 0.25)
                    : const Color(0xFFE8F0D8).withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jatuh Tempo: $dueDate',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 0,
                  child: Text(
                    amount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? kHijauTua : const Color(0xFF444444),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
