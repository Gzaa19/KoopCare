import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/widgets/app_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class TopUpSuccessPage extends StatefulWidget {
  final int amount;
  const TopUpSuccessPage({super.key, this.amount = 1000000});

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

  String _formatRupiah(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp. ${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final double currentBalance = authState.user?.balance ?? 0.0;
        final formattedAmount = _formatRupiah(widget.amount);
        final formattedBalance = _formatRupiah(currentBalance.toInt());

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
                          child: _buildWalletIllustration(),
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
                                'Saldo Top Up Anda Telah\nBertambah',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D2E14),
                                  height: 1.4,
                                  letterSpacing: 0.1,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                'Top Up Dana $formattedAmount ke Saldo\nTop Up Berhasil',
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
                                    _summaryRow(
                                      'Jumlah Top Up',
                                      formattedAmount,
                                    ),
                                    const SizedBox(height: 10),
                                    _summaryRow(
                                      'Saldo Top Up Anda',
                                      formattedBalance,
                                    ),
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
                                onTap: () {
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                },
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
      },
    );
  }

  Widget _buildWalletIllustration() {
    return SizedBox(
      width: 180,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 140,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF556B2F), Color(0xFF3B4D22)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            child: Container(
              width: 140,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kHijauMuda, Color(0xFF556B2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 56,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF8FA84A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF556B2F), width: 3),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 20,
            child: _coin(36, const Color(0xFFF5C542)),
          ),
          Positioned(
            top: 28,
            left: 22,
            child: _coin(26, const Color(0xFFE8B830)),
          ),
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
