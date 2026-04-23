import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 
// ─── Colour tokens ────────────────────────────────────────────────────────────
const Color kHijauTua    = Color(0xFF4A5E2A);
const Color kCardGreen   = Color(0xFF556B2F);
const Color kUserCardTop = Color(0xFFDDE5C8); // light sage green top section
const Color kAbuAbu      = Color(0xFF9E9E9E);
const Color kPutih       = Color(0xFFFFFFFF);
const Color kScaffold    = Color(0xFFFFFFFF);

// ─── Beranda Page ─────────────────────────────────────────────────────────────
class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});
  @override
  State<BerandaPage> createState() => _BerandaPageState();
}
 
class _BerandaPageState extends State<BerandaPage> {
  int _selectedIndex = 0;
  bool _balanceVisible = true;
 
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
              _buildAppBar(),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildUserCard(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildPembiayaanCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
 
  // ── App Bar ───────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: kHijauTua,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home_rounded, color: kPutih, size: 22),
          ),
          const SizedBox(width: 10),
          const Text(
            'KoopCare',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kHijauTua,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined, color: kHijauTua, size: 28),
              Positioned(
                top: 0,
                right: 1,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: kScaffold, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
 
  // ── User + Balance Card ───────────────────────────────────────────────────────
  Widget _buildUserCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          // Light sage-green top
          Container(
            color: kUserCardTop,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2C2C2C),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: kPutih, size: 32),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beri Mesyanti',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Anggota Aktif',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
 
          // Olive-green balance section
          Container(
            color: kCardGreen,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Saldo Top Up',
                        style: TextStyle(
                          color: Color(0xFFCEDF9A),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _balanceVisible
                            ? 'Rp 3.500.000 (updated)'
                            : 'Rp ••••••••',
                        style: const TextStyle(
                          color: kPutih,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      setState(() => _balanceVisible = !_balanceVisible),
                  child: Icon(
                    _balanceVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: kPutih,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  // ── Quick Actions ─────────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.arrow_upward_rounded, 'label': 'Top Up'},
      {'icon': Icons.description_outlined, 'label': 'Ajukan\nPinjaman'},
      {'icon': Icons.swap_horiz_rounded,   'label': 'Transfer'},
      {'icon': Icons.history_rounded,      'label': 'Riwayat'},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions
          .map((a) => _ActionButton(
                icon: a['icon'] as IconData,
                label: a['label'] as String,
              ))
          .toList(),
    );
  }
 
  // ── Pembiayaan Aktif Card — dashed border via LayoutBuilder + CustomPaint ──────
  Widget _buildPembiayaanCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // We measure the inner content first, then overlay the dashed border
        return Stack(
          children: [
            // White card content
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: kPutih,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pembiayaan Aktif',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Pembiayaan # Rp #IK0100',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF555555), height: 1.4),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Produk : Murabahah - JAK0100',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF555555), height: 1.4),
                  ),
                  const SizedBox(height: 16),
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
 
            // Dashed border overlay — Positioned.fill so it always matches the card size
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
      },
    );
  }
 
  // ── Bottom Navigation ─────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded,                    'label': 'Beranda'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Simpanan'},
      {'icon': Icons.receipt_long_outlined,           'label': 'Cicilan'},
      {'icon': Icons.person_outline_rounded,          'label': 'Akun'},
    ];
 
    return Container(
      decoration: BoxDecoration(
        color: kPutih,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == _selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 3,
                        width: active ? 36 : 0,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: kHijauTua,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Icon(
                        items[i]['icon'] as IconData,
                        color: active ? kHijauTua : kAbuAbu,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: active ? kHijauTua : kAbuAbu,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
 
// ─── Quick Action Button ──────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionButton({required this.icon, required this.label});
 
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD4DBC8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: kHijauTua, size: 28),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF333333),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
 
// ─── Dashed Border Painter ────────────────────────────────────────────────────
// Uses Positioned.fill so canvas size always equals the card size exactly
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
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
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