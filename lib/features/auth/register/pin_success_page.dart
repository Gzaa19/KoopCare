import 'package:flutter/material.dart';
import 'register_success_page.dart'; // for kPrimary + shared widgets

class PinSuccessPage extends StatelessWidget {
  const PinSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF6B7F3F);

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
                    child: Icon(
                      Icons.description_outlined,
                      size: 70,
                      color: primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                "Pembuatan Pin berhasil",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text("Ketuk untuk selanjutnya"),
            ],
          ),
        ),
      ),
    );
  }
}
