import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/app_colors.dart';

/// 6 obscured single-character boxes with auto-focus next/previous on input.
///
/// The parent owns [controllers] (length must be 6) so it can read the value
/// when the user submits.
class PinInputRow extends StatelessWidget {
  final List<TextEditingController> controllers;

  const PinInputRow({super.key, required this.controllers})
      : assert(controllers.length == 6, 'PinInputRow needs exactly 6 controllers');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) => _PinBox(controllers: controllers, index: i)),
    );
  }
}

class _PinBox extends StatelessWidget {
  final List<TextEditingController> controllers;
  final int index;

  const _PinBox({required this.controllers, required this.index});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: controllers[index],
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        maxLength: 1,
        obscureText: true,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFE5E5E5),
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
