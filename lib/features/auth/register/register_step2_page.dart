import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'create_pin_page.dart';
import '../../../core/app_colors.dart';

// ─── Register Step 2 ─────────────────────────────────────────────────────────
// Upload foto KTP + selfie, lalu lanjut ke CreatePinPage.
// Foto ini hanya tersimpan lokal di sini — tidak dikirim ke backend sekarang.
// Pengiriman foto ke POST /mobile/kyc/submit dilakukan setelah user login
// (karena endpoint KYC memerlukan JWT token).
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

class _RegisterStep2PageState extends State<RegisterStep2Page> {
  XFile? ktpImage;
  XFile? selfieImage;
  Uint8List? ktpBytes;
  Uint8List? selfieBytes;
  bool agree = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(bool isKtp) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        if (isKtp) { ktpImage = pickedFile; ktpBytes = bytes; }
        else { selfieImage = pickedFile; selfieBytes = bytes; }
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

              Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12)),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: kPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 16),

              const Center(
                child: Text('KoopCare',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kPrimary)),
              ),

              const SizedBox(height: 20),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [Text('Steps'), Text('2/2')]),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 1,
                minHeight: 6,
                color: kPrimary,
                backgroundColor: Colors.grey,
              ),

              const SizedBox(height: 12),

              // Info KYC
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7EBD9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: kPrimary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Foto KTP & selfie digunakan untuk verifikasi KYC. Akun langsung aktif setelah daftar.',
                        style: TextStyle(fontSize: 12, color: kPrimary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              buildUploadBox('FOTO e-KTP ASLI', true),
              buildUploadBox('FOTO SELFIE DENGAN e-KTP', false),

              const SizedBox(height: 10),

              Row(
                children: [
                  Checkbox(
                    value: agree,
                    activeColor: kPrimary,
                    onChanged: (value) => setState(() => agree = value ?? false),
                  ),
                  const Expanded(
                    child: Text('Saya menyetujui Syarat & Ketentuan'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  // Lanjut ke CreatePinPage, teruskan data user
                  onPressed: agree
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreatePinPage(
                                fullName: widget.nama,
                                noWa: widget.noWa,
                                nik: widget.nik,
                              ),
                            ),
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('VERIFIKASI',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final bytes = isKtp ? ktpBytes : selfieBytes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF333333))),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => pickImage(isKtp),
          child: Container(
            height: 150, width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: kPrimary, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: bytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(bytes, fit: BoxFit.cover),
                  )
                : const Center(child: Icon(Icons.add_photo_alternate_outlined, size: 40)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
