import 'package:flutter/material.dart';
import 'register_step2_page.dart';

class RegisterStep1Page extends StatelessWidget {
  RegisterStep1Page({super.key});

  final Color primary = const Color(0xFF6B7F3F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // BACK BUTTON
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // TITLE
              Text(
                "KoopCare",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),

              const SizedBox(height: 20),

              // STEP TEXT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [Text("Steps"), Text("1/2")],
              ),

              const SizedBox(height: 8),

              // PROGRESS BAR
              LinearProgressIndicator(
                value: 0.5,
                color: primary,
                backgroundColor: Colors.grey[300],
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),

              const SizedBox(height: 30),

              // INPUT FIELD
              buildField("NAMA LENGKAP (SESUAI KTP)"),
              buildField("NOMOR WHATSAPP AKTIF"),
              buildField("NIK (NOMOR INDUK KEPENDUDUKAN)"),

              const Spacer(),

              // BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterStep2Page()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "BERIKUTNYA",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),

        const SizedBox(height: 10),

        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEDED),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const TextField(
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }
}
