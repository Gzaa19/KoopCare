import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Stage 3: enter the new PIN twice (set + confirm).
class NewPinStep extends StatelessWidget {
  final TextEditingController newPinController;
  final TextEditingController confirmPinController;

  const NewPinStep({
    super.key,
    required this.newPinController,
    required this.confirmPinController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PinField(label: 'PIN Baru', controller: newPinController),
        const SizedBox(height: 16),
        _PinField(label: 'Konfirmasi PIN Baru', controller: confirmPinController),
      ],
    );
  }
}

class _PinField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _PinField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
              icon: Icon(Icons.lock_outline),
            ),
          ),
        ),
      ],
    );
  }
}
