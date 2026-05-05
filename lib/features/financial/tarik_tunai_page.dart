import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pin_verification.dart' show PinVerificationPage;

// ─── Colour tokens ────────────────────────────────────────────────────────────
const Color kHijauTua = Color(0xFF4A5E2A);
const Color kPutih    = Color(0xFFFFFFFF);
const Color kScaffold = Color(0xFFFFFFFF);

const List<String> kBankOptions = [
  'Bank Syariah Indonesia',
  'BCA',
  'Mandiri',
  'BNI',
  'BRI',
  'CIMB Niaga',
  'Danamon',
];

// ─── Withdrawable balance (would come from API in production) ─────────────────
const int kSaldoBisaDitarik = 3500000;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TransferPage(),
  ));
}

// ─── Transfer / Tarik Page ────────────────────────────────────────────────────
class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage>
    with SingleTickerProviderStateMixin {
  String? _selectedBank;
  final _rekeningCtrl = TextEditingController();
  final _jumlahCtrl   = TextEditingController();

  // Entrance animations
  late final AnimationController _ctrl;
  late final List<Animation<double>>  _fades;
  late final List<Animation<Offset>>  _slides;

  bool get _canSubmit =>
      _selectedBank != null &&
      _rekeningCtrl.text.trim().isNotEmpty &&
      _jumlahCtrl.text.trim().isNotEmpty;

  // Validate jumlah doesn't exceed balance
  bool get _exceedsBalance {
    final raw = _jumlahCtrl.text.trim();
    if (raw.isEmpty) return false;
    final amount = int.tryParse(raw) ?? 0;
    return amount > kSaldoBisaDitarik;
  }

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    // 4 sections: balance card, bank dropdown, rekening, jumlah+note
    _fades = List.generate(4, (i) {
      final s = i * 0.13;
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _ctrl,
        curve: Interval(s, (s + 0.5).clamp(0, 1.0), curve: Curves.easeOut),
      ));
    });
    _slides = List.generate(4, (i) {
      final s = i * 0.13;
      return Tween<Offset>(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _ctrl,
        curve: Interval(s, (s + 0.5).clamp(0, 1.0),
            curve: Curves.easeOutCubic),
      ));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _rekeningCtrl.dispose();
    _jumlahCtrl.dispose();
    super.dispose();
  }

  Widget _animated(int i, Widget child) => FadeTransition(
        opacity: _fades[i],
        child: SlideTransition(position: _slides[i], child: child),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 0: Saldo Bisa Ditarik card ───────────────────────
                    _animated(0, _buildBalanceCard()),
                    const SizedBox(height: 24),

                    // ── 1: Pilih Bank Tujuan ─────────────────────────────
                    _animated(1, _buildDropdownField()),
                    const SizedBox(height: 20),

                    // ── 2: Nomor Rekening ────────────────────────────────
                    _animated(2,
                      _buildInputField(
                        label: 'Nomor Rekening',
                        controller: _rekeningCtrl,
                        hint: '',
                        isNumeric: true,
                        maxLength: 16,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── 3: Jumlah Transfer + info note ───────────────────
                    _animated(3,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField(
                            label: 'Jumlah Transfer (Rp)',
                            controller: _jumlahCtrl,
                            hint: 'Rp. 1.000.000',
                            isNumeric: true,
                            errorText: _exceedsBalance
                                ? 'Jumlah melebihi saldo yang tersedia'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Info note
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(Icons.info_outline,
                                  color: Color(0xFF4A90D9), size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Verifikasi PIN diperlukan di langkah berikutnya.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF555555),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Fixed CTA button ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_canSubmit && !_exceedsBalance)
                      ? () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 350),
                              pageBuilder: (ctx, a1, a2) =>
                                  const PinVerificationPage(),
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
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kHijauTua,
                    disabledBackgroundColor: const Color(0xFFB0BDA0),
                    foregroundColor: kPutih,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lanjut Ke Verifikasi PIN',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
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
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Color(0xFF333333)),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Transfer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  // ── Saldo Bisa Ditarik card (dashed border) ───────────────────────────────
  Widget _buildBalanceCard() {
    return Stack(
      children: [
        // Card content
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4EE),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            children: const [
              Text(
                'Saldo Bisa Ditarik',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF777777),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Rp 3.500.000',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
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

  // ── Dropdown field ────────────────────────────────────────────────────────
  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Bank Tujuan',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedBank,
              hint: const Text('',
                  style:
                      TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF888888)),
              items: kBankOptions
                  .map((b) => DropdownMenuItem(
                        value: b,
                        child: Text(b,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1A1A1A))),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedBank = v),
            ),
          ),
        ),
      ],
    );
  }

  // ── Text input field ──────────────────────────────────────────────────────
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String hint = '',
    bool isNumeric = false,
    int? maxLength,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333))),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: errorText != null
                  ? Colors.redAccent
                  : const Color(0xFFDDDDDD),
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType:
                isNumeric ? TextInputType.number : TextInputType.text,
            inputFormatters: [
              if (isNumeric) FilteringTextInputFormatter.digitsOnly,
              if (maxLength != null)
                LengthLimitingTextInputFormatter(maxLength),
            ],
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                  color: Color(0xFFAAAAAA), fontSize: 14),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 14),
              const SizedBox(width: 4),
              Text(errorText,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.redAccent)),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Transfer Success Page ────────────────────────────────────────────────────
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // ── Arrow illustration ──────────────────────────────────────
              FadeTransition(
                opacity: _illustFade,
                child: ScaleTransition(
                  scale: _illustScale,
                  child: _buildIllustration(),
                ),
              ),

              const SizedBox(height: 32),

              // ── Title + subtitle + summary ──────────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    children: [
                      const Text(
                        'Transfer Berhasil!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_formatRupiah(widget.amount)} telah berhasil\nditransfer ke ${widget.bank}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Summary',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A))),
                            const SizedBox(height: 10),
                            const Divider(
                                height: 1, color: Color(0xFFEEEEEE)),
                            const SizedBox(height: 10),
                            _summaryRow('Jumlah Transfer',
                                _formatRupiah(widget.amount)),
                            const SizedBox(height: 8),
                            _summaryRow(
                                'Bank Tujuan', widget.bank),
                            const SizedBox(height: 8),
                            _summaryRow('Nomor Rekening',
                                widget.rekening),
                            const SizedBox(height: 8),
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

              // ── CTA ────────────────────────────────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context)
                              .popUntil((r) => r.isFirst),
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
                            fontSize: 15, fontWeight: FontWeight.bold),
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

  // ── Arrow-out illustration ────────────────────────────────────────────────
  Widget _buildIllustration() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0D8),
              shape: BoxShape.circle,
            ),
          ),
          // Inner circle
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFFD0E0B0),
              shape: BoxShape.circle,
            ),
          ),
          // Arrow icon
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: kHijauTua,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: kPutih,
              size: 36,
            ),
          ),
          // Coin decorations
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
              color: Colors.black.withOpacity(0.15),
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
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF666666))),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A))),
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
      double d = 0;
      while (d < metric.length) {
        final end = (d + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color ||
      old.dashWidth != dashWidth ||
      old.dashSpace != dashSpace;
}