import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import 'register_success_page.dart';

/// "PIN created" interstitial. Tap anywhere to advance to the final
/// `RegisterSuccessPage`.
class PinSuccessPage extends StatelessWidget {
  const PinSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RegisterSuccessPage()),
          );
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
