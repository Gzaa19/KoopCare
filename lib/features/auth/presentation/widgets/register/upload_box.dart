import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../../core/app_colors.dart';

/// Tappable framed box for KYC photo uploads. Shows a placeholder icon when
/// no image is selected; otherwise renders [bytes] cropped via [Image.memory].
class UploadBox extends StatelessWidget {
  final String title;
  final Uint8List? bytes;
  final VoidCallback onTap;

  const UploadBox({
    super.key,
    required this.title,
    required this.bytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          onTap: onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: kPrimary, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: bytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(bytes!, fit: BoxFit.cover),
                  )
                : const Center(
                    child: Icon(Icons.add_photo_alternate_outlined, size: 40),
                  ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
