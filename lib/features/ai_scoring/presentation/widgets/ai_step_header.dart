import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';

class AiStepHeader extends StatelessWidget {
  final String title;
  final int currentStep;
  final int totalSteps;
  final String subtitle;

  const AiStepHeader({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    this.subtitle =
        'Mari mulai dengan melengkapi detail identitas Anda. Data ini membantu kami membangun profil risiko awal secara akurat.',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2E14),
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Steps',
              style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
            Text(
              '$currentStep/$totalSteps',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: currentStep / totalSteps),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => LinearProgressIndicator(
            value: v,
            minHeight: 6,
            color: kHijauTua,
            backgroundColor: const Color(0xFFE8F0D8),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF666666),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
