import 'package:flutter/material.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/widgets/dashed_border_painter.dart';

/// A card that displays estimated monthly loan payments with high fidelity
/// originally extracted from `pengajuan_pembiayaan_page.dart`.
class CicilanCard extends StatelessWidget {
  final String cicilanEstimasi;

  const CicilanCard({
    super.key,
    required this.cicilanEstimasi,
  });

  @override
  Widget build(BuildContext context) {
    final hasCicilan = cicilanEstimasi != '-';
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cicilan Per Bulan (Estimasi)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF888888),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  cicilanEstimasi,
                  key: ValueKey(cicilanEstimasi),
                  style: TextStyle(
                    fontSize: hasCicilan ? 20 : 15,
                    fontWeight: FontWeight.bold,
                    color: hasCicilan
                        ? kHijauTua
                        : const Color(0xFF888888),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: DashedBorderPainter(
                color: hasCicilan
                    ? kHijauTua.withValues(alpha: 0.4)
                    : const Color(0xFFDDE5C8),
                radius: 16,
                dashWidth: 6,
                dashSpace: 4,
                strokeWidth: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
