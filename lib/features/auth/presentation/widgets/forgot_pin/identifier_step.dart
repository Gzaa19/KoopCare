import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Stage 1: enter the WhatsApp number / NIK.
class IdentifierStep extends StatelessWidget {
  final TextEditingController controller;

  const IdentifierStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.phone_outlined),
          hintText: 'Nomor WhatsApp / NIK',
        ),
      ),
    );
  }
}
