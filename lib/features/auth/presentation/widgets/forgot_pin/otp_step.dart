import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koopcare/core/app_colors.dart';

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
          children: List.generate(
            6,
            (i) => _OtpBox(controller: controllers[i], index: i),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 16,
              color: countdown > 0 ? kHijauTua : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              countdown > 0
                  ? 'Kirim ulang OTP dalam 0:${countdown.toString().padLeft(2, '0')}'
                  : 'Tidak menerima kode OTP?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: countdown > 0 ? kHijauTua : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        if (countdown == 0) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onResend,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Kirim Ulang Kode OTP',
              style: TextStyle(
                color: kHijauTua,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final int index;

  const _OtpBox({required this.controller, required this.index});

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 52,
      decoration: BoxDecoration(
        color: kPutih,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? kHijauTua.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1D2E14),
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8F0D8), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kHijauTua, width: 1.8),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && widget.index < 5) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && widget.index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }
}
