import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'register_success_page.dart';
import 'register_step1_page.dart'; // for kPrimary + shared widgets

class RegisterStep2Page extends StatefulWidget {
  final String nama;
  final String noWa;
  final String nik;

  const RegisterStep2Page({
    super.key,
    required this.nama,
    required this.noWa,
    required this.nik,
  });

  @override
  State<RegisterStep2Page> createState() => _RegisterStep2PageState();
}

class _RegisterStep2PageState extends State<RegisterStep2Page>
    with SingleTickerProviderStateMixin {
  XFile? ktpImage;
  XFile? selfieImage;
  Uint8List? ktpBytes;
  Uint8List? selfieBytes;
  bool agree = false;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(bool isKtp) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        if (isKtp) {
          ktpImage = pickedFile;
          ktpBytes = bytes;
        } else {
          selfieImage = pickedFile;
          selfieBytes = bytes;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Back button ───────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: kPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 16),

              // ── Title ─────────────────────────────────────────────────────
              const Center(
                child: Text(
                  'KoopCare',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // STEP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [Text("Steps"), Text("2/2")],
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: 1,
                minHeight: 6,
                color: kPrimary,
                backgroundColor: Colors.grey,
              ),

              const SizedBox(height: 30),

              buildUploadBox("FOTO e-KTP ASLI", true),
              buildUploadBox("FOTO SELFIE DENGAN e-KTP", false),

              const SizedBox(height: 10),

              Row(
                children: [
                  Checkbox(
                    value: agree,
                    onChanged: (value) {
                      setState(() {
                        agree = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text("Saya menyetujui Syarat & Ketentuan"),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: agree
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterSuccessPage(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  child: const Text("VERIFIKASI"),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUploadBox(String title, bool isKtp) {
    final image = isKtp ? ktpImage : selfieImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => pickImage(isKtp),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: kPrimary, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      isKtp ? ktpBytes! : selfieBytes!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Center(child: Icon(Icons.person_outline, size: 40)),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
