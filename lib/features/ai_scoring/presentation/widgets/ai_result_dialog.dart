import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../domain/entities/ai_scoring_result.dart';

/// Modal showing the AI scoring outcome (LAYAK / TIDAK_LAYAK with details).
class AiResultDialog extends StatelessWidget {
  final AiScoringResult result;

  const AiResultDialog({super.key, required this.result});

  /// Convenience to present the dialog with the same scale + fade animation
  /// the legacy page used.
  static Future<void> show(
    BuildContext context, {
    required AiScoringResult result,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (_, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (_, _, _) => AiResultDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final approved = result.isApproved;
    final scoreColor = approved ? kHijauTua : Colors.redAccent;
    final defaultPct = (result.probDefault * 100).toStringAsFixed(1);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.82,
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: scoreColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  approved ? Icons.check_rounded : Icons.close_rounded,
                  color: kPutih,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                approved ? 'SELAMAT!' : 'MOHON MAAF',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                approved
                    ? 'Pengajuan pembiayaan Anda\nDISETUJUI oleh sistem AI.'
                    : 'Pengajuan pembiayaan Anda\nbelum dapat disetujui saat ini.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _row('Skor AI', '${result.aiScore}/100'),
                    const SizedBox(height: 6),
                    _row('Risiko Gagal Bayar', '$defaultPct%'),
                    const SizedBox(height: 6),
                    _row('Level Risiko', result.riskLevel.label),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kHijauTua,
                    foregroundColor: kPutih,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'LANJUT',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      );
}
