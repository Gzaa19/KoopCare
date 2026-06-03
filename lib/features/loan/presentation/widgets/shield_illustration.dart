import 'package:flutter/material.dart';
import 'package:koopcare/core/app_colors.dart';

/// A premium shield illustration widget with a lock and status badge
/// originally extracted from `pin_verification.dart`.
class ShieldIllustration extends StatelessWidget {
  const ShieldIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main shield
          CustomPaint(
            size: const Size(150, 170),
            painter: ShieldPainter(color: kHijauTua),
          ),

          // Inner shield highlight (slightly lighter)
          Positioned(
            top: 10,
            child: CustomPaint(
              size: const Size(120, 136),
              painter: ShieldPainter(color: kHijauMuda),
            ),
          ),

          // Padlock body
          Positioned(
            top: 38,
            child: Column(
              children: [
                // Lock shackle (arc)
                Container(
                  width: 36,
                  height: 22,
                  decoration: BoxDecoration(
                    border: Border.all(color: kPutih, width: 5),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
                // Lock body
                Container(
                  width: 52,
                  height: 42,
                  decoration: BoxDecoration(
                    color: kPutih,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: kHijauTua,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Yellow badge padlock (bottom-right)
          Positioned(
            bottom: 14,
            right: 14,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5C542),
                shape: BoxShape.circle,
                border: Border.all(color: kPutih, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: kPutih,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShieldPainter extends CustomPainter {
  final Color color;
  const ShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w / 2, 0)                        // top center
      ..lineTo(w, h * 0.22)                     // top-right
      ..quadraticBezierTo(w, h * 0.72, w / 2, h) // right curve to bottom
      ..quadraticBezierTo(0, h * 0.72, 0, h * 0.22) // left curve
      ..lineTo(w / 2, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ShieldPainter old) => old.color != color;
}
