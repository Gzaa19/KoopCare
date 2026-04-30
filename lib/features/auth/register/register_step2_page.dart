import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'register_success_page.dart';

class RegisterStep2Page extends StatefulWidget {
  final String nama;
  final String wa;
  final String nik;

  const RegisterStep2Page({
    super.key,
    required this.nama,
    required this.wa,
    required this.nik,
  });

  @override
  State<RegisterStep2Page> createState() => _RegisterStep2PageState();
}

class _RegisterStep2PageState extends State<RegisterStep2Page> {
  final Color primary = const Color(0xFF6B7F3F);

  File? ktpImage;
  File? selfieImage;

  bool agree = false;

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(bool isKtp) async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        if (isKtp) {
          ktpImage = File(pickedFile.path);
        } else {
          selfieImage = File(pickedFile.path);
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

              // TITLE
              Center(
                child: Text(
                  "KoopCare",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primary,
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

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 1,
                  minHeight: 6,
                  color: primary,
                  backgroundColor: Colors.grey[300],
                ),
              ),

              const SizedBox(height: 30),

              //  FOTO KTP
              buildUploadBox(
                "FOTO e-KTP ASLI",
                ktpImage,
                () => pickImage(true),
              ),

              //  FOTO SELFIE
              buildUploadBox(
                "FOTO SELFIE DENGAN e-KTP",
                selfieImage,
                () => pickImage(false),
              ),

              const SizedBox(height: 10),

              // CHECKBOX
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

              const SizedBox(height: 20),

              // BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (agree && ktpImage != null && selfieImage != null)
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterSuccessPage(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "VERIFIKASI",
                    style: TextStyle(color: Colors.white),
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

  //  COMPONENT UPLOAD
  Widget buildUploadBox(String title, File? image, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF9BAA7A),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(image, fit: BoxFit.cover),
                  )
                : const Center(
                    child: Icon(
                      Icons.person_outline,
                      size: 50,
                      color: Color(0xFF9BAA7A),
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
