import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../home/beranda_page.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  List<TextEditingController> controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  int seconds = 59;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds == 0) {
        t.cancel();
      } else {
        setState(() {
          seconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: controllers[index],
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6B7F3F)),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  String getOtp() {
    return controllers.map((e) => e.text).join();
  }

  void _showSuccessDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Login Berhasil',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
      pageBuilder: (ctx, _, _) => _SuccessDialog(
        onContinue: () {
          Navigator.of(ctx, rootNavigator: true).pop();
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, a, _) => const BerandaPage(),
              transitionsBuilder: (_, a, _, child) => FadeTransition(
                opacity: a,
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 250),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // LOGO
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B7F3F),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.home_outlined,
                    color: Colors.white,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "OTP Verification",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                // OTP BOX
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) => buildOtpBox(index)),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Kami telah mengirim 6 digit kode ke\nnomor +XX XXXX XXX XXX",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 30),

                // BUTTON VERIFIKASI
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      String otp = getOtp();

                      if (otp.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Masukkan 6 digit OTP!"),
                          ),
                        );
                        return;
                      }

                      _showSuccessDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B7F3F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      "VERIFIKASI",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // TIMER
                Text(
                  "Kirim ulang kode dalam 0:${seconds.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 30),

                if (kDebugMode)
                  TextButton(
                    onPressed: () => _showSuccessDialog(context),
                    child: const Text(
                      'Skip (debug)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Login Success Dialog ─────────────────────────────────────────────────────
class _SuccessDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const _SuccessDialog({required this.onContinue});

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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
