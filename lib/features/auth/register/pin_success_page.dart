import 'package:flutter/material.dart';
import 'register_success_page.dart';

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
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ICON
              Center(
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE3CF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF6B7F3F),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    size: 60,
                    color: Color(0xFF6B7F3F),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // TITLE
              const Text(
                "Pembuatan Pin berhasil",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const Spacer(),

              // FOOTER TEXT
              const Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Text(
                  "Ketuk untuk selanjutnya",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
