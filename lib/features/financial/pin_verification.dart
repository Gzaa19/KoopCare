import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/app_colors.dart';

class PinVerificationPage extends StatefulWidget {
  const PinVerificationPage({super.key});

  @override
  State<PinVerificationPage> createState() => _PinVerificationPageState();
}

class _PinVerificationPageState extends State<PinVerificationPage>
    with TickerProviderStateMixin {
  static const int _pinLength = 6;

  final List<String> _pin = List.filled(_pinLength, '');
  int _currentIndex = 0;
  bool _isObscured = true;

  // ── Entrance animation ────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final Animation<double>  _illustFade;
  late final Animation<double>  _illustScale;
  late final Animation<double>  _formFade;
  late final Animation<Offset>  _formSlide;

  // ── Shake animation (wrong PIN) ───────────────────────────────────────────
  late final AnimationController _shakeCtrl;
  late final Animation<double>   _shakeAnim;

  // ── Shield pulse ──────────────────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Entrance
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _illustFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _illustScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)));
    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.4, 0.9, curve: Curves.easeOut)));
    _formSlide = Tween<Offset>(
        begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic)));

    // Shake (wrong PIN)
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));

    // Shield pulse (idle)
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _shakeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── PIN input logic ───────────────────────────────────────────────────────
  void _onKeyPress(String digit) {
    if (_currentIndex >= _pinLength) return;
    setState(() {
      _pin[_currentIndex] = digit;
      _currentIndex++;
    });
  }

  void _onDelete() {
    if (_currentIndex <= 0) return;
    setState(() {
      _currentIndex--;
      _pin[_currentIndex] = '';
    });
  }

  void _onClear() {
    setState(() {
      for (int i = 0; i < _pinLength; i++) _pin[i] = '';
      _currentIndex = 0;
    });
  }

  bool get _isComplete => _currentIndex == _pinLength;

  void _onLanjut() {
    if (!_isComplete) return;

    // Demo: "000000" is correct, anything else shakes
    final entered = _pin.join();
    if (entered == '000000') {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      // Shake + clear
      _shakeCtrl.forward(from: 0).then((_) {
        _onClear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PIN salah. Silakan coba lagi.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Shield illustration ─────────────────────────────────────
              FadeTransition(
                opacity: _illustFade,
                child: ScaleTransition(
                  scale: _illustScale,
                  child: ScaleTransition(
                    scale: _pulseAnim,
                    child: _ShieldIllustration(),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Title + PIN boxes + toggle ──────────────────────────────
              FadeTransition(
                opacity: _formFade,
                child: SlideTransition(
                  position: _formSlide,
                  child: Column(
                    children: [
                      const Text(
                        'Silahkan Isi Pin Anda',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // PIN boxes with shake
                      AnimatedBuilder(
                        animation: _shakeAnim,
                        builder: (_, child) {
                          final offset = math.sin(
                                  _shakeAnim.value * math.pi * 6) *
                              12;
                          return Transform.translate(
                            offset: Offset(offset, 0),
                            child: child,
                          );
                        },
                        child: _buildPinBoxes(),
                      ),

                      const SizedBox(height: 16),

                      // Show/hide toggle
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isObscured = !_isObscured),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isObscured
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 16,
                              color: const Color(0xFF888888),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isObscured
                                  ? 'Tampilkan PIN'
                                  : 'Sembunyikan PIN',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // ── Numpad ─────────────────────────────────────────────────
              FadeTransition(
                opacity: _formFade,
                child: _buildNumpad(),
              ),

              const SizedBox(height: 20),

              // ── Lanjut button ───────────────────────────────────────────
              FadeTransition(
                opacity: _formFade,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isComplete ? _onLanjut : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kHijauTua,
                      disabledBackgroundColor: const Color(0xFFB8C8A0),
                      foregroundColor: kPutih,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Lanjut',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── 6 PIN boxes ───────────────────────────────────────────────────────────
  Widget _buildPinBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_pinLength, (i) {
        final isFilled = i < _currentIndex;
        final isActive = i == _currentIndex;
        final digit    = _pin[i];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 46,
          height: 52,
          decoration: BoxDecoration(
            color: isFilled
                ? const Color(0xFFF0F5E8)
                : kPutih,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? kHijauTua               // active → olive border
                  : isFilled
                      ? kHijauMuda          // filled → lighter olive
                      : const Color(0xFFCCCCCC), // empty → grey
              width: isActive ? 2 : 1.5,
            ),
          ),
          child: Center(
            child: isFilled
                ? Text(
                    _isObscured ? '•' : digit,
                    style: TextStyle(
                      fontSize: _isObscured ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      color: kHijauTua,
                    ),
                  )
                : null,
          ),
        );
      }),
    );
  }

  // ── Custom numpad ─────────────────────────────────────────────────────────
  Widget _buildNumpad() {
    return Column(
      children: [
        _numpadRow(['1', '2', '3']),
        const SizedBox(height: 10),
        _numpadRow(['4', '5', '6']),
        const SizedBox(height: 10),
        _numpadRow(['7', '8', '9']),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Empty left slot
            const SizedBox(width: 72, height: 52),
            _numpadKey('0'),
            // Backspace
            SizedBox(
              width: 72,
              height: 52,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _onDelete,
                child: const Icon(
                  Icons.backspace_outlined,
                  color: Color(0xFF555555),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _numpadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _numpadKey(d)).toList(),
    );
  }

  Widget _numpadKey(String digit) {
    return SizedBox(
      width: 72,
      height: 52,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onKeyPress(digit),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shield Illustration Widget ───────────────────────────────────────────────
class _ShieldIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main shield
          CustomPaint(
            size: const Size(150, 170),
            painter: _ShieldPainter(color: kHijauTua),
          ),

          // Inner shield highlight (slightly lighter)
          Positioned(
            top: 10,
            child: CustomPaint(
              size: const Size(120, 136),
              painter: _ShieldPainter(color: kHijauMuda),
            ),
          ),

          // Padlock body
          Positioned(
            top: 38,
            child: Column(
              children: [
                // Lock shackle (arc)
                Container(
                  width: 36,
                  height: 22,
                  decoration: BoxDecoration(
                    border: Border.all(color: kPutih, width: 5),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
                // Lock body
                Container(
                  width: 52,
                  height: 42,
                  decoration: BoxDecoration(
                    color: kPutih,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: kHijauTua,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Yellow badge padlock (bottom-right)
          Positioned(
            bottom: 14,
            right: 14,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5C542),
                shape: BoxShape.circle,
                border: Border.all(color: kPutih, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: kPutih,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shield CustomPainter ─────────────────────────────────────────────────────
class _ShieldPainter extends CustomPainter {
  final Color color;
  const _ShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w / 2, 0)                        // top center
      ..lineTo(w, h * 0.22)                     // top-right
      ..quadraticBezierTo(w, h * 0.72, w / 2, h) // right curve to bottom
      ..quadraticBezierTo(0, h * 0.72, 0, h * 0.22) // left curve
      ..lineTo(w / 2, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter old) => old.color != color;
}