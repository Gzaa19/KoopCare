import 'package:flutter/material.dart';

import '../../../../../core/app_colors.dart';

/// "Steps  N/Total" label + animated progress bar shown atop each register step.
class StepHeader extends StatelessWidget {
  final int current;
  final int total;

  const StepHeader({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Steps',
              style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
            Text(
              '$current/$total',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: current / total),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (_, value, _) => LinearProgressIndicator(
            value: value,
            minHeight: 6,
            color: kPrimary,
            backgroundColor: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}
