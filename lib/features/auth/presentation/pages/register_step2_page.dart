import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/app_colors.dart';
import '../widgets/register/upload_box.dart';
import 'create_pin_page.dart';

/// Step 2 of registration: KYC photo capture + terms agreement.
///
/// The photos are kept in memory only — they are NOT sent to the backend at
/// this point. KYC submission to `/mobile/kyc/submit` happens after login,
/// because that endpoint needs an auth token. Refactoring KYC into the
/// data/domain layers will be done when that endpoint is wired up.
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
  final ImagePicker _picker = ImagePicker();

  Uint8List? _ktpBytes;
  Uint8List? _selfieBytes;
  bool _agree = false;

  Future<void> _pickImage({required bool isKtp}) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    final bytes = await pickedFile.readAsBytes();
    setState(() {
      if (isKtp) {
        _ktpBytes = bytes;
      } else {
        _selfieBytes = bytes;
      }
    });
  }

  void _onContinue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePinPage(
          fullName: widget.nama,
          noWa: widget.noWa,
          nik: widget.nik,
        ),
      ),
    );
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: kPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 16),
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Steps'), Text('2/2')],
              ),
              const SizedBox(height: 8),
              const LinearProgressIndicator(
                value: 1,
                minHeight: 6,
                color: kPrimary,
                backgroundColor: Colors.grey,
              ),
              const SizedBox(height: 12),
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
              UploadBox(
                title: 'FOTO e-KTP ASLI',
                bytes: _ktpBytes,
                onTap: () => _pickImage(isKtp: true),
              ),
              UploadBox(
                title: 'FOTO SELFIE DENGAN e-KTP',
                bytes: _selfieBytes,
                onTap: () => _pickImage(isKtp: false),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _agree,
                    activeColor: kPrimary,
                    onChanged: (value) =>
                        setState(() => _agree = value ?? false),
                  ),
                  const Expanded(
                    child: Text('Saya menyetujui Syarat & Ketentuan'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _agree ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'VERIFIKASI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
}
