import 'package:flutter/material.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/features/faq/data/faq_data.dart';
import 'package:koopcare/features/faq/presentation/widgets/faq_tile.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  // Only one item open at a time (null = all collapsed)
  int? _openIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App bar ───────────────────────────────────────────────────
            _buildAppBar(context),

            // ── Scrollable FAQ list ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page title
                    const Center(
                      child: Text(
                        'FAQ',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FAQ accordion list
                    Container(
                      decoration: BoxDecoration(
                        color: kPutih,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        children: List.generate(kFaqData.length, (i) {
                          return FaqTile(
                            item: kFaqData[i],
                            isOpen: _openIndex == i,
                            isLast: i == kFaqData.length - 1,
                            onTap: () => setState(() {
                              _openIndex = _openIndex == i ? null : i;
                            }),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Kembali button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.maybePop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kHijauTua,
                          foregroundColor: kPutih,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Kembali',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          // KoopCare logo
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2C),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home_rounded, color: kPutih, size: 16),
          ),
          const SizedBox(width: 8),
          const Text(
            'KoopCare',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
