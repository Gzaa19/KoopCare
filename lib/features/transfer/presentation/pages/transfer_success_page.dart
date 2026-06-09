import 'package:flutter/material.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/widgets/app_widgets.dart';
import 'package:koopcare/features/transfer/presentation/pages/transfer_page.dart';

class TransferSuccessPage extends StatefulWidget {
  final int amount;
  final String bank;
  final String rekening;

  const TransferSuccessPage({
    super.key,
    required this.amount,
    required this.bank,
    required this.rekening,
  });

  @override
  State<TransferSuccessPage> createState() => _TransferSuccessPageState();
}

class _TransferSuccessPageState extends State<TransferSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _illustFade;
  late final Animation<double> _illustScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  String _formatRupiah(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp. ${buf.toString()}';
  }

  int get _remainingBalance => kSaldoBisaDitarik - widget.amount;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _illustFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _illustScale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve:
                const Interval(0.0, 0.55, curve: Curves.easeOutBack)));
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.35, 0.85, curve: Curves.easeOut)));
    _contentSlide = Tween<Offset>(
            begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.35, 0.85,
                curve: Curves.easeOutCubic)));

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
      body: Stack(
        children: [
          const AmbientOrbBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  FadeTransition(
                    opacity: _illustFade,
                    child: ScaleTransition(
                      scale: _illustScale,
                      child: _buildIllustration(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        children: [
                          const Text(
                            'Transfer Berhasil',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D2E14),
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${_formatRupiah(widget.amount)} telah berhasil\nditransfer ke ${widget.bank}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF666666),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),

                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: kPutih,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.9),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Summary',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1D2E14),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Divider(
                                    height: 1, color: Color(0xFFEEEEEE)),
                                const SizedBox(height: 12),
                                _summaryRow('Jumlah Transfer',
                                    _formatRupiah(widget.amount)),
                                const SizedBox(height: 10),
                                _summaryRow(
                                    'Bank Tujuan', widget.bank),
                                const SizedBox(height: 10),
                                _summaryRow('Nomor Rekening',
                                    widget.rekening),
                                const SizedBox(height: 10),
                                _summaryRow('Sisa Saldo',
                                    _formatRupiah(_remainingBalance)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  FadeTransition(
                    opacity: _contentFade,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [kHijauMuda, kHijauTua],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: kHijauTua.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () =>
                                Navigator.of(context)
                                    .popUntil((r) => r.isFirst),
                            borderRadius: BorderRadius.circular(16),
                            child: const Center(
                              child: Text(
                                'Ke Beranda (Halaman Utama)',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: kPutih,
                                ),
                              ),
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
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0D8).withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 115,
            height: 115,
            decoration: BoxDecoration(
              color: const Color(0xFFDDE5C8).withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kHijauMuda, kHijauTua],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kHijauTua.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: kPutih,
              size: 38,
            ),
          ),
          Positioned(
            top: 12,
            right: 16,
            child: _coin(28, const Color(0xFFF5C542)),
          ),
          Positioned(
            bottom: 16,
            left: 14,
            child: _coin(22, const Color(0xFFE8B830)),
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
              offset: const Offset(1, 2))
        ],
      ),
      child: Center(
        child: Text(
          '\$',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.42,
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF666666),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2E14),
          ),
        ),
      ],
    );
  }
}
