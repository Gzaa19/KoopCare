import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koopcare/core/app_colors.dart';

class LoanInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final String hint;
  final bool isNumeric;
  final String? prefixText;
  final ValueChanged<String>? onChanged;

  /// Custom input formatters. Jika disediakan, akan menggantikan default
  /// [FilteringTextInputFormatter.digitsOnly] saat [isNumeric] = true.
  final List<TextInputFormatter>? inputFormatters;

  const LoanInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    this.hint = '',
    this.isNumeric = false,
    this.prefixText,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final prefix = prefixText;

    // Gunakan formatter kustom jika ada, otherwise fallback ke digitsOnly
    final effectiveFormatters = inputFormatters ??
        (isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
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
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFocused ? kHijauTua : const Color(0xFFE8F0D8),
              width: isFocused ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isFocused
                    ? kHijauTua.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (prefix != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    prefix,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType:
                      isNumeric ? TextInputType.number : TextInputType.text,
                  inputFormatters: effectiveFormatters,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 14,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
