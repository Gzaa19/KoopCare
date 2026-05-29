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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number. ${label.toUpperCase()}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF444444),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: kFieldBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: value != null
                  ? kHijauTua.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: const SizedBox.shrink(),
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
