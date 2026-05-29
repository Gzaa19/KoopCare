import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/app_colors.dart';

/// Stage 2: 6-box OTP input + countdown to allow resend.
class OtpStep extends StatelessWidget {
  final List<TextEditingController> controllers;
  final int countdown;
  final VoidCallback onResend;

  const OtpStep({
    super.key,
    required this.controllers,
    required this.countdown,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _OtpBox(controller: controllers[i], index: i)),
        ),
        const SizedBox(height: 20),
        Text(
          'Kirim ulang kode dalam 0:${countdown.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 14),
        ),
        if (countdown == 0)
          TextButton(
            onPressed: onResend,
            child: const Text(
              'Kirim Ulang OTP',
              style: TextStyle(color: kPrimary),
            ),
          ),
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final int index;

  const _OtpBox({required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimary),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) FocusScope.of(context).nextFocus();
          if (value.isEmpty && index > 0) FocusScope.of(context).previousFocus();
        },
      ),
    );
  }
}
