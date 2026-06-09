import 'package:flutter/material.dart';
import 'package:koopcare/core/app_colors.dart';

class PinDisplayRow extends StatelessWidget {
  final int length;
  final int currentIndex;
  final List<String> pin;
  final bool isObscured;

  const PinDisplayRow({
    super.key,
    this.length = 6,
    required this.currentIndex,
    required this.pin,
    required this.isObscured,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(length, (i) {
        final isFilled = i < currentIndex;
        final isActive = i == currentIndex;
        final digit = i < pin.length ? pin[i] : '';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 46,
          height: 52,
          decoration: BoxDecoration(
            color: isFilled
                ? const Color(0xFFF0F5E8)
                : kPutih,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? kHijauTua
                  : isFilled
                      ? kHijauMuda
                      : const Color(0xFFCCCCCC),
              width: isActive ? 2 : 1.5,
            ),
          ),
          child: Center(
            child: isFilled
                ? Text(
                    isObscured ? '•' : digit,
                    style: TextStyle(
                      fontSize: isObscured ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      color: kHijauTua,
                    ),
                  )
                : null,
          ),
        );
      }),
    );
  }
}
