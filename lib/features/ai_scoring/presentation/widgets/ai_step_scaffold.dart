import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import 'ai_step_header.dart';

/// Common scaffold used by AI scoring steps 1–3:
/// back button, header, scrollable grey field container, fixed CTA button.
class AiStepScaffold extends StatelessWidget {
  final String title;
  final int currentStep;
  final int totalSteps;
  final List<Widget> fields;
  final VoidCallback? onNext;
  final bool canNext;

  const AiStepScaffold({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    required this.fields,
    required this.onNext,
    this.canNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AiStepHeader(
                      title: title,
                      currentStep: currentStep,
                      totalSteps: totalSteps,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: fields
                            .expand((f) => [f, const SizedBox(height: 16)])
                            .toList()
                          ..removeLast(),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canNext ? onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kHijauTua,
                    disabledBackgroundColor: const Color(0xFFB8C8A0),
                    foregroundColor: kPutih,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Selanjutnya',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
