import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/route_names.dart';
import '../../domain/repositories/auth_repository.dart';

/// "PIN created" interstitial.
///
/// Jika [ktpFilePath] dan [selfieFilePath] tersedia, KYC di-submit ke BE
/// di background segera setelah halaman ini muncul. Token sudah tersedia
/// karena register berhasil sebelum halaman ini dibuka.
///
/// Tap anywhere → [RegisterSuccessPage].
class PinSuccessPage extends StatefulWidget {
  final String? ktpFilePath;
  final String? selfieFilePath;

  const PinSuccessPage({super.key, this.ktpFilePath, this.selfieFilePath});

  @override
  State<PinSuccessPage> createState() => _PinSuccessPageState();
}

class _PinSuccessPageState extends State<PinSuccessPage> {
  @override
  void initState() {
    super.initState();
    // Submit KYC di background — tidak block UI, gagal pun tidak apa-apa.
    // User bisa submit ulang dari menu profil nanti.
    if (widget.ktpFilePath != null && widget.selfieFilePath != null) {
      _submitKycSilently();
    }
  }

  Future<void> _submitKycSilently() async {
    try {
      await getIt<AuthRepository>().submitKyc(
        ktpFilePath: widget.ktpFilePath!,
        selfieFilePath: widget.selfieFilePath!,
      );
    } catch (_) {
      // Gagal silently — user tetap bisa lanjut, KYC bisa diulang nanti
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, RouteNames.registerDone);
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7EBD9),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      size: 70,
                      color: kPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: kPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Pembuatan Pin berhasil',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('Ketuk untuk selanjutnya'),
            ],
          ),
        ),
      ),
    );
  }
}
