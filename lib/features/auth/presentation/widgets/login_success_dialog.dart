import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';

/// Modal shown after a successful login.
///
/// Pure presentation — the caller wires `onContinue` to the post-login route.
class LoginSuccessDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const LoginSuccessDialog({super.key, required this.onContinue});

  /// Convenience to present the dialog with the same animation the legacy
  /// page used (scale + fade, ease-out-back).
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onContinue,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Login Berhasil',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, animation, _, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
      pageBuilder: (ctx, _, _) => LoginSuccessDialog(onContinue: onContinue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: kHijauTua,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: kPutih, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              'Login Berhasil!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selamat datang kembali\ndi KoopCare',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kHijauTua,
                  foregroundColor: kPutih,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Lanjutkan',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
