import 'package:flutter/material.dart';
import 'package:koopcare/core/app_colors.dart';

class CicilanAutodebetRow extends StatelessWidget {
  const CicilanAutodebetRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kPutih,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8F0D8).withValues(alpha: 0.5), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.payment_outlined, color: kHijauTua, size: 20),
              SizedBox(width: 12),
              Text(
                "Autodebet Saldo Top Up",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: false,
            onChanged: (v) {},
            activeThumbColor: kHijauTua,
          ),
        ],
      ),
    );
  }
}
