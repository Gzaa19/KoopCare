import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koopcare/core/app_colors.dart';

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
        const SizedBox(height: 18),
        _PinField(
          label: 'Konfirmasi PIN Baru',
          controller: confirmPinController,
        ),
      ],
    );
  }
}

class _PinField extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const _PinField({required this.label, required this.controller});

  @override
  State<_PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<_PinField> {
  final _focusNode = FocusNode();
  bool _isFocused = false;
  bool _obscure = true;

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
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            widget.label,
            style: const TextStyle(
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
            obscureText: _obscure,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF1A1A1A),
              letterSpacing: 3,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              counterText: '',
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: kHijauTua,
                size: 20,
              ),
              hintText: '••••••',
              hintStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Color(0xFFAAAAAA),
                fontSize: 14,
                letterSpacing: 3,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: kHijauTua,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
