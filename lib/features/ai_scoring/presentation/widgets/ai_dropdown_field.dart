import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';

/// Numbered dropdown row used by the AI scoring step pages.
class AiDropdownField extends StatelessWidget {
  final int number;
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const AiDropdownField({
    super.key,
    required this.number,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasVal = value != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '$number. ${label.toUpperCase()}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2E14),
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasVal ? kHijauTua : const Color(0xFFE8F0D8),
              width: hasVal ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: hasVal
                    ? kHijauTua.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.01),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: const Text(
                'Pilih jawaban',
                style: TextStyle(color: Color(0xFF888888), fontSize: 13),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF888888),
                size: 22,
              ),
              items: options
                  .map(
                    (o) => DropdownMenuItem(
                      value: o,
                      child: Text(
                        o,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
