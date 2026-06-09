import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/app_constants.dart';
import 'package:koopcare/core/router/route_names.dart';
import 'package:koopcare/core/widgets/dashed_border_painter.dart';

class TransferAppBar extends StatelessWidget {
  final VoidCallback onBack;

  const TransferAppBar({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Color(0xFF333333)),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Transfer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class TransferBalanceCard extends StatelessWidget {
  const TransferBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4EE),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: const Column(
            children: [
              Text(
                'Saldo Bisa Ditarik',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF777777),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Rp 3.500.000',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),

        Positioned.fill(
          child: CustomPaint(
            painter: DashedBorderPainter(
              color: const Color(0xFFB0BDA0),
              radius: 14,
              dashWidth: 6,
              dashSpace: 4,
              strokeWidth: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class TransferBankDropdown extends StatelessWidget {
  final String? selectedBank;
  final ValueChanged<String?> onChanged;

  const TransferBankDropdown({
    super.key,
    required this.selectedBank,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Bank Tujuan',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedBank,
              hint: const Text('',
                  style:
                      TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF888888)),
              items: kBankOptions
                  .map((b) => DropdownMenuItem(
                        value: b,
                        child: Text(b,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1A1A1A))),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class TransferInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool isNumeric;
  final int? maxLength;
  final String? errorText;
  final VoidCallback? onChanged;

  const TransferInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = '',
    this.isNumeric = false,
    this.maxLength,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333))),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: errorText != null
                  ? Colors.redAccent
                  : const Color(0xFFDDDDDD),
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType:
                isNumeric ? TextInputType.number : TextInputType.text,
            inputFormatters: [
              if (isNumeric) FilteringTextInputFormatter.digitsOnly,
              if (maxLength != null)
                LengthLimitingTextInputFormatter(maxLength),
            ],
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                  color: Color(0xFFAAAAAA), fontSize: 14),
            ),
            onChanged: (_) => onChanged?.call(),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 14),
              const SizedBox(width: 4),
              Text(errorText!,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.redAccent)),
            ],
          ),
        ],
      ],
    );
  }
}

class TransferCtaButton extends StatelessWidget {
  final bool enabled;

  const TransferCtaButton({super.key, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: enabled
              ? () => Navigator.pushNamed(context, RouteNames.pinVerify)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: kHijauTua,
            disabledBackgroundColor: const Color(0xFFB0BDA0),
            foregroundColor: kPutih,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Lanjut Ke Verifikasi PIN',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
