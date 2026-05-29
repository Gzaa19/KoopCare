import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pill-shaped labeled field used on Register Step 1.
class RegisterTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isNumeric;
  final String? Function(String?)? validator;

  const RegisterTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isNumeric = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEDED),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType:
                isNumeric ? TextInputType.number : TextInputType.text,
            inputFormatters: isNumeric
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            validator: validator,
            decoration: const InputDecoration(
              border: InputBorder.none,
              errorStyle: TextStyle(height: 0),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
