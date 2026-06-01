import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/widgets/dashed_border_painter.dart';

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
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF1D2E14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              Container(
                height: 155,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kPutih,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: bytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(bytes!, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kHijauTua.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 30,
                                color: kHijauTua,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Ambil / Pilih Foto',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: kHijauTua,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              if (bytes == null)
                Positioned.fill(
                  child: CustomPaint(
                    painter: DashedBorderPainter(
                      color: const Color(0xFFB5C0A4),
                      radius: 20,
                      dashWidth: 6,
                      dashSpace: 4,
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
