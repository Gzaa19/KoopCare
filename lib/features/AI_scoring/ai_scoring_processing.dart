import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'ai_scoring_service.dart';

// ─── AI Processing Page ────────────────────────────────────────────────────────
// Receives all 12 form fields, calls Railway ML API on load,
// then shows the real LAYAK / TIDAK_LAYAK result.
class AiScoringProcessingPage extends StatefulWidget {
  // All data from Steps 1–3
  final String jenisKelamin;
  final String tanggalLahir;
  final String pendidikan;
  final String statusNikah;
  final String statusTempat;
  final String transportasi;
  final String pekerjaan;
  final String sumberPenghasilan;
  final String aset;
  final String tanggungan;
  final String pendapatan;
  final String jumlahPinjaman;

  const AiScoringProcessingPage({
    super.key,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.pendidikan,
    required this.statusNikah,
    required this.statusTempat,
    required this.transportasi,
    required this.pekerjaan,
    required this.sumberPenghasilan,
    required this.aset,
    required this.tanggungan,
    required this.pendapatan,
    required this.jumlahPinjaman,
  });

  @override
  State<AiScoringProcessingPage> createState() =>
      _AiScoringProcessingPageState();
}

class _AiScoringProcessingPageState extends State<AiScoringProcessingPage>
    with TickerProviderStateMixin {

  // ── API state ──────────────────────────────────────────────────────────────
  AiScoringResult? _result;
  String? _errorMessage;
  bool _apiDone = false;

  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;
  late final AnimationController _spinCtrl;
  late final Animation<double> _spinAnim;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceCtrl.forward();
      _callMlApi(); // start API call immediately
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _spinCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  // ── Call ML API ────────────────────────────────────────────────────────────

  Future<void> _callMlApi() async {
    try {
      final result = await AiScoringService.predict(
        jenisKelamin:      widget.jenisKelamin,
        tanggalLahir:      widget.tanggalLahir,
        pendidikan:        widget.pendidikan,
        statusNikah:       widget.statusNikah,
        statusTempat:      widget.statusTempat,
        transportasi:      widget.transportasi,
        pekerjaan:         widget.pekerjaan,
        sumberPenghasilan: widget.sumberPenghasilan,
        aset:              widget.aset,
        tanggungan:        widget.tanggungan,
        pendapatan:        widget.pendapatan,
        jumlahPinjaman:    widget.jumlahPinjaman,
      );
      if (!mounted) return;
      setState(() {
        _result  = result;
        _apiDone = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal menghubungi sistem AI.\nSilakan coba lagi.';
        _apiDone = true;
      });
    }
  }

  // ── Show result dialog ─────────────────────────────────────────────────────

  void _showResult() {
    if (_errorMessage != null) {
      _showErrorDialog();
      return;
    }
    if (_result == null) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (_, anim, __, child) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
            scale: curved,
            child: FadeTransition(opacity: anim, child: child));
      },
      pageBuilder: (ctx, _, __) => _ResultDialog(result: _result!),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Gagal'),
        content: Text(_errorMessage!),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() { _apiDone = false; _errorMessage = null; });
              _callMlApi();
            },
            child: const Text('Coba Lagi'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                        // Robot
                        AnimatedBuilder(
                          animation: _bounceAnim,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(0, _bounceAnim.value),
                            child: child,
                          ),
                          child: _buildRobotIllustration(),
                        ),

                        const SizedBox(height: 40),

                        // Status text
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: _apiDone
                              ? _errorMessage != null
                                  ? Text(
                                      _errorMessage!,
                                      key: const ValueKey('error'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.redAccent,
                                          height: 1.6),
                                    )
                                  : Text(
                                      _result!.isApproved
                                          ? 'Analisis selesai!\nSistem AI telah mengevaluasi profil kredit Anda.'
                                          : 'Analisis selesai.\nKami telah mengevaluasi profil kredit Anda.',
                                      key: const ValueKey('done'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF555555),
                                          height: 1.6),
                                    )
                              : const Text(
                                  'Mohon waktunya sebentar, Tim AI Kami sedang menghitung skor kelayakan kredit Anda.',
                                  key: ValueKey('loading'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF555555),
                                      height: 1.6),
                                ),
                        ),

                        // Loading indicator while waiting
                        if (!_apiDone) ...[
                          const SizedBox(height: 20),
                          const SizedBox(
                            width: 28, height: 28,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: kHijauTua),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Progress bar
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

            // Button — disabled while loading, shows result when done
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _apiDone ? _showResult : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kHijauTua,
                    disabledBackgroundColor: const Color(0xFFB8C8A0),
                    foregroundColor: kPutih,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _apiDone ? 'Lihat Hasil' : 'Menghitung...',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Robot illustration (unchanged) ─────────────────────────────────────────

  Widget _buildRobotIllustration() {
    return SizedBox(
      width: 200,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 90, height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCCCCCC), width: 2),
              ),
            ),
          ),
          Positioned(
            top: 10,
            child: Container(
              width: 80, height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCCCCCC), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_robotEye(), const SizedBox(width: 14), _robotEye()],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 30, height: 6,
                    decoration: BoxDecoration(
                      color: kHijauTua,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Column(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                      color: kHijauTua, shape: BoxShape.circle),
                ),
                Container(width: 3, height: 12, color: const Color(0xFFCCCCCC)),
              ],
            ),
          ),
          Positioned(
            bottom: 20, left: 10,
            child: _robotArm(),
          ),
          Positioned(
            bottom: 20, right: 10,
            child: _robotArm(),
          ),
          Positioned(
            top: 20, right: 20,
            child: AnimatedBuilder(
              animation: _spinAnim,
              builder: (_, __) => Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(_spinAnim.value * 3.14159 * 2),
                child: Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF5C542), shape: BoxShape.circle),
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
          Positioned(
            bottom: 10, right: 16,
            child: Icon(Icons.settings_outlined,
                color: const Color(0xFF888888), size: 22),
          ),
        ],
      ),
    );
  }

  Widget _robotEye() => Container(
        width: 14, height: 14,
        decoration: BoxDecoration(
          color: kHijauTua,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF333333), width: 1),
        ),
      );

  Widget _robotArm() => Container(
        width: 16, height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFDDDDDD),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
        ),
      );
}

// ─── Result Dialog ─────────────────────────────────────────────────────────────

class _ResultDialog extends StatelessWidget {
  final AiScoringResult result;
  const _ResultDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    final approved     = result.isApproved;
    final scoreColor   = approved ? kHijauTua : Colors.redAccent;
    final riskLabel    = result.riskLevel == 'low'
        ? 'Rendah'
        : result.riskLevel == 'medium'
            ? 'Sedang'
            : 'Tinggi';
    final defaultPct   = (result.probDefault * 100).toStringAsFixed(1);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.82,
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: scoreColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  approved ? Icons.check_rounded : Icons.close_rounded,
                  color: kPutih, size: 36,
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                approved ? 'SELAMAT!' : 'MOHON MAAF',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                approved
                    ? 'Pengajuan pembiayaan Anda\nDISETUJUI oleh sistem AI.'
                    : 'Pengajuan pembiayaan Anda\nbelum dapat disetujui saat ini.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              // Score details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _scoreRow('Skor AI', '${result.aiScore}/100'),
                    const SizedBox(height: 6),
                    _scoreRow('Risiko Gagal Bayar', '$defaultPct%'),
                    const SizedBox(height: 6),
                    _scoreRow('Level Risiko', riskLabel),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Button
              SizedBox(
                width: double.infinity, height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kHijauTua,
                    foregroundColor: kPutih,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('LANJUT',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF666666))),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A))),
        ],
      );
}
