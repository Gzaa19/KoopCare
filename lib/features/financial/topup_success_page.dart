import 'package:flutter/material.dart';
import '../home/beranda_page.dart';

class TopUpSuccessPage extends StatefulWidget {
  const TopUpSuccessPage({super.key});

  @override
  State<TopUpSuccessPage> createState() => _TopUpSuccessPageState();
}

class _TopUpSuccessPageState extends State<TopUpSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _illustFade;
  late final Animation<double> _illustScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _illustFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    _illustScale = Tween<double>(begin: 0.7, end: 1).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
    ));
    _contentFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
    ));
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // ── Wallet illustration ──────────────────────────────────────
              FadeTransition(
                opacity: _illustFade,
                child: ScaleTransition(
                  scale: _illustScale,
                  child: _buildWalletIllustration(),
                ),
              ),

              const SizedBox(height: 32),

              // ── Title + subtitle + summary card ──────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    children: [
                      const Text(
                        'Saldo Top Up Anda Telah\nBertambah',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Top Up Dana Rp. 1.000.000 ke Saldo\nTop Up Berhasil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Summary card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: kPutih,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFFE5E5E5), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Summary',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Divider(
                                height: 1, color: Color(0xFFEEEEEE)),
                            const SizedBox(height: 10),
                            _summaryRow(
                              'Saldo Top Up Anda',
                              'Rp. 3.500.000',
                            ),
                            const SizedBox(height: 8),
                            _summaryRow(
                              'Cicilan Bulan Depan',
                              'Rp. 180.000',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ── CTA button ────────────────────────────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate back to home
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kHijauTua,
                        foregroundColor: kPutih,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ke Beranda (Halaman Utama)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Wallet illustration built with Flutter widgets ────────────────────────
  Widget _buildWalletIllustration() {
    return SizedBox(
      width: 180,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Wallet body
          Positioned(
            bottom: 0,
            child: Container(
              width: 140,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF4A5E2A),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          // Wallet flap
          Positioned(
            bottom: 60,
            child: Container(
              width: 140,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7F3F),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
            ),
          ),
          // Wallet clasp circle
          Positioned(
            bottom: 56,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF8FA84A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6B7F3F), width: 3),
              ),
            ),
          ),
          // Coin 1 — top right
          Positioned(
            top: 10,
            right: 20,
            child: _coin(36, const Color(0xFFF5C542)),
          ),
          // Coin 2 — top left (smaller)
          Positioned(
            top: 28,
            left: 22,
            child: _coin(26, const Color(0xFFE8B830)),
          ),
          // Coin 3 — middle right (smallest)
          Positioned(
            top: 52,
            right: 10,
            child: _coin(20, const Color(0xFFF5C542)),
          ),
        ],
      ),
    );
  }

  Widget _coin(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '\$',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.45,
          ),
        ),
      ),
    );
  }

  // ── Summary row helper ────────────────────────────────────────────────────
  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF666666),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}