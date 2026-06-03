import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:koopcare/core/app_colors.dart';

class DashboardCardsWidget extends StatefulWidget {
  final double balance;
  final double totalLoan;

  const DashboardCardsWidget({
    super.key,
    required this.balance,
    required this.totalLoan,
  });

  @override
  State<DashboardCardsWidget> createState() => _DashboardCardsWidgetState();
}

class _DashboardCardsWidgetState extends State<DashboardCardsWidget> {
  bool _balanceVisible = true;

  String _formatRp(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 105,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kPutih,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8F0D8), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Saldo Top Up",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF777777),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                      child: Icon(
                        _balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 16,
                        color: kHijauTua,
                      ),
                    ),
                  ],
                ),
                Text(
                  _balanceVisible ? _formatRp(widget.balance.toInt()) : "Rp ••••••",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2E14),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Terhubung DB",
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 105,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kPutih,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8F0D8), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Kewajiban",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF777777),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 16,
                      color: kHijauTua,
                    ),
                  ],
                ),
                Text(
                  _formatRp(widget.totalLoan.toInt()),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2E14),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.totalLoan > 0 ? Colors.orange.withValues(alpha: 0.08) : Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.totalLoan > 0 ? "Kewajiban Aktif" : "Tanpa Tagihan",
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: widget.totalLoan > 0 ? Colors.orange.shade800 : Colors.blue.shade800,
                    ),
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
