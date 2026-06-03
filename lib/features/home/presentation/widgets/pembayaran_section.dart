import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/router/route_args.dart';
import '../../../../core/router/route_names.dart';
import '../../../loan/data/models/loan_model.dart';

/// Section that shows the active loan / payment card.
/// Returns [SizedBox.shrink] when there is no active loan.
class PembayaranSection extends StatelessWidget {
  final LoanModel? activeLoan;

  /// Callback to switch the shell tab to "Cicilan" (index 2).
  final VoidCallback? onViewAll;

  const PembayaranSection({
    super.key,
    required this.activeLoan,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (activeLoan == null) return const SizedBox.shrink();

    final isPending = activeLoan!.status == 'PENDING';
    final loanAmount = activeLoan!.approvedAmount ?? activeLoan!.amount;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final statusColor = switch (activeLoan!.status) {
      'ACTIVE' => const Color(0xFF2E7D32),
      'APPROVED' => const Color(0xFF1565C0),
      'PENDING' => const Color(0xFFEF6C00),
      _ => const Color(0xFF424242),
    };

    final statusBgColor = switch (activeLoan!.status) {
      'ACTIVE' => const Color(0xFFE8F5E9),
      'APPROVED' => const Color(0xFFE3F2FD),
      'PENDING' => const Color(0xFFFFF3E0),
      _ => const Color(0xFFEEEEEE),
    };

    final statusLabel = switch (activeLoan!.status) {
      'ACTIVE' => 'Aktif',
      'APPROVED' => 'Disetujui',
      'PENDING' => 'Menunggu',
      _ => activeLoan!.status,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tagihan Saya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
                letterSpacing: 0.2,
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: kHijauTua,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Loan card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE8F0D8).withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loan type + status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pinjaman ${activeLoan!.type == 'MURABAHAH' ? 'Murabahah' : 'Qardhul Hasan'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPending
                              ? 'Menunggu persetujuan admin'
                              : 'Tenor: ${activeLoan!.approvedTenor ?? activeLoan!.tenor} bulan',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 14),
              _FinRow(
                label: 'Total Pinjaman',
                value: formatter.format(loanAmount),
                valueColor: const Color(0xFF1A1A1A),
              ),
              if (!isPending) ...[
                const SizedBox(height: 8),
                const _FinRow(
                  label: 'Sudah Dibayar',
                  value: 'Rp 0',
                  valueColor: Color(0xFF1A1A1A),
                ),
                const SizedBox(height: 8),
                _FinRow(
                  label: 'Sisa Pembayaran',
                  value: formatter.format(loanAmount),
                  valueColor: const Color(0xFFCC4444),
                ),
                const SizedBox(height: 16),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 0.0), // 0% paid
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF5F5F5),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        kHijauTua,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Pay button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.pembayaranDetail,
                      arguments: PembayaranDetailArgs(loan: activeLoan!),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kHijauTua,
                      foregroundColor: kPutih,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Bayar Cicilan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Simple label–value row used inside the loan detail card.
class _FinRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _FinRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
