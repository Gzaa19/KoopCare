import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/di/service_locator.dart';
import 'package:koopcare/core/widgets/app_widgets.dart';
import '../bloc/forgot_pin/forgot_pin_bloc.dart';
import '../bloc/forgot_pin/forgot_pin_event.dart';
import '../bloc/forgot_pin/forgot_pin_state.dart';
import '../widgets/forgot_pin/identifier_step.dart';
import '../widgets/forgot_pin/otp_step.dart';
import '../widgets/forgot_pin/new_pin_step.dart';

class ForgotPinPage extends StatelessWidget {
  const ForgotPinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPinBloc>(
      create: (_) => getIt<ForgotPinBloc>(),
      child: const _ForgotPinView(),
    );
  }
}

class _ForgotPinView extends StatefulWidget {
  const _ForgotPinView();

  @override
  State<_ForgotPinView> createState() => _ForgotPinViewState();
}

class _ForgotPinViewState extends State<_ForgotPinView> with SingleTickerProviderStateMixin {
  static const int _resendSeconds = 59;

  final _identifierCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final _newPinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();

  Timer? _countdownTimer;
  int _countdown = _resendSeconds;
  String? _localError;

  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _identifierCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  String get _otpValue => _otpCtrls.map((c) => c.text).join();

  void _onPrimaryAction(ForgotPinStage stage) {
    final bloc = context.read<ForgotPinBloc>();
    switch (stage) {
      case ForgotPinStage.enterIdentifier:
        final id = _identifierCtrl.text.trim();
        if (id.isEmpty) {
          setState(() => _localError = 'Masukkan nomor WhatsApp atau NIK');
          return;
        }
        setState(() => _localError = null);
        bloc.add(ForgotPinOtpRequested(id));

      case ForgotPinStage.enterOtp:
        if (_otpValue.length != 6) {
          setState(() => _localError = 'Masukkan 6 digit OTP');
          return;
        }
        setState(() => _localError = null);
        bloc.add(
          ForgotPinOtpVerified(
            identifier: _identifierCtrl.text.trim(),
            otp: _otpValue,
          ),
        );

      case ForgotPinStage.enterNewPin:
        final newPin = _newPinCtrl.text.trim();
        if (newPin.length != 6) {
          setState(() => _localError = 'PIN baru harus 6 digit');
          return;
        }
        if (newPin != _confirmPinCtrl.text.trim()) {
          setState(() => _localError = 'Konfirmasi PIN tidak cocok');
          return;
        }
        setState(() => _localError = null);
        bloc.add(
          ForgotPinReset(
            identifier: _identifierCtrl.text.trim(),
            otp: _otpValue,
            newPin: newPin,
          ),
        );

      case ForgotPinStage.completed:
        break;
    }
  }

  void _onStateChanged(BuildContext context, ForgotPinState state) {
    if (state.stage == ForgotPinStage.enterOtp &&
        state.status == ForgotPinStatus.idle) {
      _startCountdown();
    }
    if (state.stage == ForgotPinStage.completed) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PIN berhasil direset. Silakan masuk.'),
          backgroundColor: kHijauTua,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _countdown = _resendSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _countdown--);
    });
  }

  void _resendOtp() {
    context.read<ForgotPinBloc>().add(
          ForgotPinOtpRequested(_identifierCtrl.text.trim()),
        );
  }

  String _titleFor(ForgotPinStage stage) {
    switch (stage) {
      case ForgotPinStage.enterIdentifier:
        return 'Lupa PIN Koperasi';
      case ForgotPinStage.enterOtp:
        return 'Verifikasi OTP';
      case ForgotPinStage.enterNewPin:
      case ForgotPinStage.completed:
        return 'Buat PIN Baru';
    }
  }

  String _subtitleFor(ForgotPinStage stage) {
    switch (stage) {
      case ForgotPinStage.enterIdentifier:
        return 'Masukkan nomor WhatsApp terdaftar Anda untuk mengirim kode OTP';
      case ForgotPinStage.enterOtp:
        return 'Kode verifikasi OTP telah dikirim melalui WhatsApp terdaftar Anda';
      case ForgotPinStage.enterNewPin:
      case ForgotPinStage.completed:
        return 'Buat 6 digit PIN keamanan baru untuk transaksi syariah Anda';
    }
  }

  String _buttonLabelFor(ForgotPinStage stage) {
    switch (stage) {
      case ForgotPinStage.enterIdentifier:
        return 'Kirim Kode OTP';
      case ForgotPinStage.enterOtp:
        return 'Verifikasi & Lanjut';
      case ForgotPinStage.enterNewPin:
      case ForgotPinStage.completed:
        return 'Simpan PIN Baru';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const AmbientOrbBackground(),
          SafeArea(
            child: BlocConsumer<ForgotPinBloc, ForgotPinState>(
              listenWhen: (a, b) => a.stage != b.stage,
              listener: _onStateChanged,
              builder: (context, state) {
                final stage = state.stage;
                final isLoading = state.status == ForgotPinStatus.loading;
                final errorText = isLoading
                    ? null
                    : (_localError ??
                        (state.status == ForgotPinStatus.error
                            ? state.errorMessage
                            : null));

                return FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: kPutih,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE8F0D8), width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_rounded, color: kHijauTua),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              const SizedBox(width: 16),
                               Text(
                                _titleFor(stage),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D2E14),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Center(
                            child: Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                color: kPutih,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFE8F0D8), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: kHijauTua.withValues(alpha: 0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                color: kHijauTua,
                                size: 42,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _subtitleFor(stage),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (stage == ForgotPinStage.enterIdentifier)
                            IdentifierStep(controller: _identifierCtrl),
                          if (stage == ForgotPinStage.enterOtp)
                            OtpStep(
                              controllers: _otpCtrls,
                              countdown: _countdown,
                              onResend: _resendOtp,
                            ),
                          if (stage == ForgotPinStage.enterNewPin ||
                              stage == ForgotPinStage.completed)
                            NewPinStep(
                              newPinController: _newPinCtrl,
                              confirmPinController: _confirmPinCtrl,
                            ),
                          if (errorText != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEECEB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFCD5D2), width: 1.2),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: Color(0xFFD32F2F), size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      errorText,
                                      style: const TextStyle(
                                        color: Color(0xFFD32F2F),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 36),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: kHijauTua.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : () => _onPrimaryAction(stage),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kHijauTua,
                                  foregroundColor: kPutih,
                                  disabledBackgroundColor: kHijauTua.withValues(alpha: 0.5),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _buttonLabelFor(stage),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
