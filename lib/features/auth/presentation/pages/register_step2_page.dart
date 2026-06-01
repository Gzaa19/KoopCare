import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/widgets/app_widgets.dart';
import '../widgets/register/upload_box.dart';
import '../../../../core/router/route_args.dart';
import '../../../../core/router/route_names.dart';

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

  XFile? _ktpFile;
  XFile? _selfieFile;

  Uint8List? _ktpPreview;
  Uint8List? _selfiePreview;

  bool _agree = false;

  Future<void> _pickImage({required bool isKtp}) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    final preview = await picked.readAsBytes();
    setState(() {
      if (isKtp) {
        _ktpFile = picked;
        _ktpPreview = preview;
      } else {
        _selfieFile = picked;
        _selfiePreview = preview;
      }
    });
  }

  void _onContinue() {
    if (_ktpFile == null || _selfieFile == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mohon unggah foto e-KTP dan Selfie!'),
          backgroundColor: kHijauTua,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      RouteNames.createPin,
      arguments: CreatePinArgs(
        fullName: widget.nama,
        noWa: widget.noWa,
        nik: widget.nik,
        ktpFilePath: _ktpFile!.path,
        selfieFilePath: _selfieFile!.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      body: Stack(
        children: [
          const AmbientOrbBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: kPutih,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE8F0D8), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: kHijauTua),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Verifikasi KYC',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2E14),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Langkah',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF888888),
                        ),
                      ),
                      Text(
                        '2 dari 2',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2E14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(
                    value: 1,
                    minHeight: 6,
                    color: kHijauTua,
                    backgroundColor: Color(0xFFE8F0D8),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kHijauTua.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kHijauTua.withValues(alpha: 0.1), width: 1),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 20, color: kHijauTua),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Foto e-KTP & selfie digunakan untuk proses verifikasi KYC demi keamanan transaksi Syariah.',
                            style: TextStyle(
                              fontSize: 12,
                              color: kHijauTua,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  UploadBox(
                    title: 'Foto e-KTP Asli',
                    bytes: _ktpPreview,
                    onTap: () => _pickImage(isKtp: true),
                  ),
                  UploadBox(
                    title: 'Foto Selfie dengan e-KTP',
                    bytes: _selfiePreview,
                    onTap: () => _pickImage(isKtp: false),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agree,
                          activeColor: kHijauTua,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          onChanged: (v) => setState(() => _agree = v ?? false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Saya menyatakan setuju dengan seluruh Syarat dan Ketentuan serta Kebijakan Privasi KoopCare.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF555555),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _agree
                                ? kHijauTua.withValues(alpha: 0.25)
                                : Colors.transparent,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _agree ? _onContinue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kHijauTua,
                          foregroundColor: kPutih,
                          disabledBackgroundColor: kHijauTua.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Mulai Verifikasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
