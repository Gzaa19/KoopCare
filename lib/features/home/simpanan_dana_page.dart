import 'package:flutter/material.dart';
import 'beranda_page.dart';
import '../financial/topup_page.dart';
import '../financial/tarik_tunai_page.dart' show TransferPage;

// ─── Simpanan Dana Page ───────────────────────────────────────────────────────
class SimpananDanaPage extends StatefulWidget {
  const SimpananDanaPage({super.key});

  @override
  State<SimpananDanaPage> createState() => _SimpananDanaPageState();
}

class _SimpananDanaPageState extends State<SimpananDanaPage>
    with SingleTickerProviderStateMixin {
  // Entrance animation
  late final AnimationController _entranceCtrl;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _pemFade;
  late final Animation<Offset> _pemSlide;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)));

    _pemFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.3, 0.9, curve: Curves.easeOut)),
    );
    _pemSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic)));

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _entranceCtrl.forward());
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // User identity row
                    _buildUserRow(),
                    const SizedBox(height: 16),

                    // Approval + balance card (staggered entrance)
                    FadeTransition(
                      opacity: _cardFade,
                      child: SlideTransition(
                        position: _cardSlide,
                        child: _buildApprovalCard(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Peminjaman Aktif card
                    FadeTransition(
                      opacity: _pemFade,
                      child: SlideTransition(
                        position: _pemSlide,
                        child: _buildPeminjamanCard(),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: const Text(
        'Simpanan',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: kHijauTua,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // ── User identity row ─────────────────────────────────────────────────────────
  Widget _buildUserRow() {
    return Row(
      children: [
        // Dark avatar circle
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFF2C2C2C),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: kPutih, size: 30),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Beri Mesyanti',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Anggota Aktif',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Approval + balance card ───────────────────────────────────────────────────
  Widget _buildApprovalCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kCardGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status line — mixed normal + bold
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 14, color: kPutih),
              children: [
                TextSpan(text: 'Pengajuan peminjaman '),
                TextSpan(
                  text: 'Disetujui!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          const Text(
            'Total Pembiayaan',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFCEDF9A),
            ),
          ),

          const SizedBox(height: 8),

          // Big amount
          const Text(
            'Rp 1.000.000',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kPutih,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 20),

          // Top Up + Tarik buttons
          Row(
            children: [
              // Top Up — filled olive-green (slightly lighter than card)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 350),
                      pageBuilder: (_, _, _) => const TopUpPage(),
                      transitionsBuilder: (_, anim, _, child) =>
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 16, color: kPutih),
                  label: const Text(
                    'Top Up',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: kPutih,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kHijauTua,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Tarik — outlined white
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 350),
                      pageBuilder: (ctx, a1, a2) => const TransferPage(),
                      transitionsBuilder: (ctx, anim, a1, child) =>
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_up_rounded,
                      size: 18, color: kPutih),
                  label: const Text(
                    'Tarik',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: kPutih,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kPutih, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Peminjaman Aktif card (dashed border) ─────────────────────────────────────
  Widget _buildPeminjamanCard() {
    return Stack(
      children: [
        // White content
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Peminjaman Aktif',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1A1A1A),
                ),
              ),

              const SizedBox(height: 8),

              // Product line
              const Text(
                'Produk : Murabahah - JAK0100',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 6),

              // Warning / info text in red-orange
              const Text(
                'Tagihan Berlangsung 1 bulan setelah peminjaman disetujui',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFCC4444),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // CTA button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kHijauTua,
                    foregroundColor: kPutih,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Jadwal & Bayar # AKD100',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Dashed border overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _DashedBorderPainter(
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

// ─── Dashed Border Painter ────────────────────────────────────────────────────
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.dashWidth,
    required this.dashSpace,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
          size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color ||
      old.dashWidth != dashWidth ||
      old.dashSpace != dashSpace ||
      old.radius != radius;
}
