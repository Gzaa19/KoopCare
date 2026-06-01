import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koopcare/core/app_colors.dart';

class PinInputRow extends StatelessWidget {
  final List<TextEditingController> controllers;

  const PinInputRow({super.key, required this.controllers})
      : assert(
          controllers.length == 6,
          'PinInputRow needs exactly 6 controllers',
        );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (i) => _PinBox(controllers: controllers, index: i),
      ),
    );
  }
}

class _PinBox extends StatefulWidget {
  final List<TextEditingController> controllers;
  final int index;

  const _PinBox({required this.controllers, required this.index});

  @override
  State<_PinBox> createState() => _PinBoxState();
}

class _PinBoxState extends State<_PinBox> {
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
        controller: widget.controllers[widget.index],
        focusNode: _focusNode,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        maxLength: 1,
        obscureText: true,
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
