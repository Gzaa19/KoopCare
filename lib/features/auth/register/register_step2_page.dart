import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'register_success_page.dart';

class RegisterStep2Page extends StatefulWidget {
  const RegisterStep2Page({super.key});

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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

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
      resizeToAvoidBottomInset: true,
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
                    fontSize: 24,
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

              LinearProgressIndicator(
                value: 1,
                minHeight: 6,
                color: primary,
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

              const SizedBox(height: 20),

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
                  style: ElevatedButton.styleFrom(backgroundColor: primary),
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
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        GestureDetector(
          onTap: () => pickImage(isKtp),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: primary, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(image, fit: BoxFit.cover),
                  )
                : const Center(child: Icon(Icons.person_outline, size: 40)),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
