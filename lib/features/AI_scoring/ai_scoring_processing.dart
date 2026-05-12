import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

// ─── AI Processing Page ────────────────────────────────────────────────────────
class AiScoringProcessingPage extends StatefulWidget {
  const AiScoringProcessingPage({super.key});

  @override
  State<AiScoringProcessingPage> createState() =>
      _AiScoringProcessingPageState();
}

class _AiScoringProcessingPageState extends State<AiScoringProcessingPage>
    with TickerProviderStateMixin {
  // Robot idle bounce animation
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  // Coin spin animation
  late final AnimationController _spinCtrl;
  late final Animation<double> _spinAnim;

  // Entrance
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _spinAnim = Tween<double>(begin: 0, end: 1).animate(_spinCtrl);

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entranceCtrl, curve: Curves.easeOutCubic));

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _spinCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── KoopCare header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2C2C2C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.home_rounded,
                        color: kPutih, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'KoopCare',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Robot illustration ──────────────────────────
                        AnimatedBuilder(
                          animation: _bounceAnim,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(0, _bounceAnim.value),
                            child: child,
                          ),
                          child: _buildRobotIllustration(),
                        ),

                        const SizedBox(height: 40),

                        // ── Processing text ─────────────────────────────
                        const Text(
                          'Mohon waktunya sebentar, Tim AI Kami sedang menghitung skor kelayakan kredit Anda. Proses ini membutuhkan beberapa menit.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF555555),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Steps bar + button ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Steps',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF888888))),
                      Text('4/4',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.75, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      color: kHijauTua,
                      backgroundColor: const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _showResultSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kHijauTua,
                    foregroundColor: kPutih,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Tunggu Sebentar',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            // ── Preview result buttons (demo) ─────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _previewBtn(
                    icon: Icons.check_rounded,
                    color: kHijauTua,
                    onTap: () => _showResultDialog(context, approved: true),
                  ),
                  const SizedBox(width: 16),
                  _previewBtn(
                    icon: Icons.close_rounded,
                    color: Colors.redAccent,
                    onTap: () => _showResultDialog(context, approved: false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Robot illustration ────────────────────────────────────────────────────
  Widget _buildRobotIllustration() {
    return SizedBox(
      width: 200,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Robot body
          Positioned(
            bottom: 0,
            child: Container(
              width: 90,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFCCCCCC), width: 2),
              ),
            ),
          ),
          // Robot head
          Positioned(
            top: 10,
            child: Container(
              width: 80,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFCCCCCC), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Eyes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _robotEye(),
                      const SizedBox(width: 14),
                      _robotEye(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Mouth
                  Container(
                    width: 30,
                    height: 6,
                    decoration: BoxDecoration(
                      color: kHijauTua,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Antenna
          Positioned(
            top: 0,
            child: Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: kHijauTua,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(width: 3, height: 12, color: const Color(0xFFCCCCCC)),
              ],
            ),
          ),
          // Arms
          Positioned(
            bottom: 20,
            left: 10,
            child: _robotArm(isLeft: true),
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: _robotArm(isLeft: false),
          ),
          // Spinning coin
          Positioned(
            top: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _spinAnim,
              builder: (_, __) => Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(_spinAnim.value * 3.14159 * 2),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5C542),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('\$',
                        style: TextStyle(
                            color: kPutih,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ),
              ),
            ),
          ),
          // Gear icon
          Positioned(
            bottom: 10,
            right: 16,
            child: Icon(Icons.settings_outlined,
                color: const Color(0xFF888888), size: 22),
          ),
        ],
      ),
    );
  }

  Widget _robotEye() => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: kHijauTua,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF333333), width: 1),
        ),
      );

  Widget _robotArm({required bool isLeft}) => Container(
        width: 16,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFDDDDDD),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
        ),
      );

  Widget _previewBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  void _showResultSheet(BuildContext context) {
    // In production this would poll API result;
    // for demo, show both options
    _showResultDialog(context, approved: true);
  }

  void _showResultDialog(BuildContext context, {required bool approved}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(
            parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
            scale: curved,
            child: FadeTransition(opacity: anim, child: child));
      },
      pageBuilder: (ctx, _, __) => _ResultDialog(approved: approved),
    );
  }
}

// ─── Result Dialog ────────────────────────────────────────────────────────────
class _ResultDialog extends StatelessWidget {
  final bool approved;
  const _ResultDialog({required this.approved});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.78,
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon circle
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: approved
                      ? kHijauTua
                      : Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  approved ? Icons.check_rounded : Icons.close_rounded,
                  color: kPutih,
                  size: 36,
                ),
              ),

              const SizedBox(height: 18),

              // Title
              Text(
                approved ? 'SELAMAT XXXX' : 'MOHON MAAF',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),

              const SizedBox(height: 10),

              // Body text
              Text(
                approved
                    ? 'Pengajuan pembiayaan anda\n(RP 1.000.000) DI-SETUJUI.'
                    : 'Pengajuan pembiayaan anda\n(RP 1.000.000) TIDAK DI-SETUJUI.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 22),

              // LANJUT button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    // Pop back to Beranda
                    Navigator.of(context)
                        .popUntil((r) => r.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kHijauTua,
                    foregroundColor: kPutih,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'LANJUT',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
