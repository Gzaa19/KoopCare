import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koopcare/core/app_colors.dart';

class IdentifierStep extends StatefulWidget {
  final TextEditingController controller;

  const IdentifierStep({super.key, required this.controller});

  @override
  State<IdentifierStep> createState() => _IdentifierStepState();
}

class _IdentifierStepState extends State<IdentifierStep> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Nomor WhatsApp / NIK Terdaftar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF1D2E14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused ? kHijauTua : const Color(0xFFE8F0D8),
              width: _isFocused ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? kHijauTua.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF1A1A1A),
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.phone_iphone_rounded,
                color: kHijauTua,
                size: 20,
              ),
              hintText: 'Contoh: 08123456789 atau NIK',
              hintStyle: TextStyle(
                fontWeight: FontWeight.normal,
                color: Color(0xFFAAAAAA),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
