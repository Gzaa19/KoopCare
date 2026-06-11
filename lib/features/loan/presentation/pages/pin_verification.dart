import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/widgets/custom_numpad.dart';
import 'package:koopcare/core/widgets/pin_display_row.dart';
import '../widgets/shield_illustration.dart';
import 'package:koopcare/core/di/service_locator.dart';
import 'package:koopcare/features/auth/domain/repositories/auth_repository.dart';

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

  late final AnimationController _entranceCtrl;
  late final Animation<double>  _illustFade;
  late final Animation<double>  _illustScale;
  late final Animation<double>  _formFade;
  late final Animation<Offset>  _formSlide;

  late final AnimationController _shakeCtrl;
  late final Animation<double>   _shakeAnim;

  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();

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

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));

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
      for (int i = 0; i < _pinLength; i++) {
        _pin[i] = '';
      }
      _currentIndex = 0;
    });
  }

  bool get _isComplete => _currentIndex == _pinLength;

  void _onLanjut() async {
    if (!_isComplete) return;

    final entered = _pin.join();
    final authRepository = getIt<AuthRepository>();
    final cachedPin = await authRepository.getCachedPin();
    if (!mounted) return;
    final targetPin = cachedPin ?? '000000';

    if (entered == targetPin) {
      Navigator.of(context).pop(true);
    } else {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isSmallScreen = constraints.maxHeight < 620;
            final double shieldSize = isSmallScreen ? 120.0 : 180.0;
            final double verticalGap = isSmallScreen ? 16.0 : 32.0;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        FadeTransition(
                          opacity: _illustFade,
                          child: ScaleTransition(
                            scale: _illustScale,
                            child: ScaleTransition(
                              scale: _pulseAnim,
                              child: SizedBox(
                                width: shieldSize,
                                height: shieldSize,
                                child: const FittedBox(
                                  fit: BoxFit.contain,
                                  child: ShieldIllustration(),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: verticalGap),

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

                                SizedBox(height: verticalGap),

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
                                  child: PinDisplayRow(
                                    length: _pinLength,
                                    currentIndex: _currentIndex,
                                    pin: _pin,
                                    isObscured: _isObscured,
                                  ),
                                ),

                                const SizedBox(height: 16),

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

                        FadeTransition(
                          opacity: _formFade,
                          child: CustomNumpad(
                            onKeyPress: _onKeyPress,
                            onDelete: _onDelete,
                            onDone: _isComplete ? _onLanjut : null,
                          ),
                        ),

                        const SizedBox(height: 20),

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
              ),
            );
          }
        ),
      ),
    );
  }

}