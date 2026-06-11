import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_colors.dart';
import '../../../loan/domain/entities/loan.dart';

class FinStatsCard extends StatelessWidget {
  final Loan? activeLoan;

  const FinStatsCard({super.key, required this.activeLoan});

  @override
  Widget build(BuildContext context) {
    final loanAmount = activeLoan != null && activeLoan!.status != 'PENDING'
        ? (activeLoan!.totalRemaining ?? activeLoan!.approvedAmount ?? activeLoan!.amount)
        : 0.0;

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return _StatBox(
      icon: Icons.assignment_late_outlined,
      iconBgColor: const Color(0xFFF9EAE8),
      iconColor: const Color(0xFFCC4444),
      label: 'Tagihan Aktif',
      value: formatter.format(loanAmount),
      valueColor: const Color(0xFFCC4444),
      borderColor: const Color(0xFFF9EAE8),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;
  final Color borderColor;

  const _StatBox({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kPutih,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 12),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
