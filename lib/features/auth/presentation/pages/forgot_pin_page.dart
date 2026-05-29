import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/forgot_pin/forgot_pin_bloc.dart';
import '../bloc/forgot_pin/forgot_pin_event.dart';
import '../bloc/forgot_pin/forgot_pin_state.dart';
import '../widgets/forgot_pin/identifier_step.dart';
import '../widgets/forgot_pin/new_pin_step.dart';
import '../widgets/forgot_pin/otp_step.dart';

/// Forgot-PIN flow: identifier → OTP → new PIN → completed.
///
/// Backend interactions live in [ForgotPinBloc]. This page only owns:
///   - Form input controllers (text fields)
///   - The OTP resend countdown (UI affordance, not a business state)
///   - Navigation/snackbar reactions to bloc state transitions
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

class _ForgotPinViewState extends State<_ForgotPinView> {
  static const int _resendSeconds = 59;

  final _identifierCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final _newPinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();

  Timer? _countdownTimer;
  int _countdown = _resendSeconds;
  String? _localError;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _identifierCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    super.dispose();
  }

  String get _otpValue => _otpCtrls.map((c) => c.text).join();

  // ── Submit handlers ────────────────────────────────────────────────────

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
        bloc.add(ForgotPinOtpVerified(
          identifier: _identifierCtrl.text.trim(),
          otp: _otpValue,
        ));

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
        bloc.add(ForgotPinReset(
          identifier: _identifierCtrl.text.trim(),
          otp: _otpValue,
          newPin: newPin,
        ));

      case ForgotPinStage.completed:
        // Handled by listener — no submit at this stage.
        break;
    }
  }

  // ── Listener: react to stage transitions ───────────────────────────────

  void _onStateChanged(BuildContext context, ForgotPinState state) {
    if (state.stage == ForgotPinStage.enterOtp && state.status == ForgotPinStatus.idle) {
      // Just transitioned into OTP stage → start the resend countdown.
      _startCountdown();
    }
    if (state.stage == ForgotPinStage.completed) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN berhasil direset. Silakan masuk.')),
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

  // ── UI helpers ─────────────────────────────────────────────────────────

  String _titleFor(ForgotPinStage stage) {
    switch (stage) {
      case ForgotPinStage.enterIdentifier:
        return 'Lupa PIN';
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
        return 'Masukkan nomor WhatsApp terdaftar';
      case ForgotPinStage.enterOtp:
        return 'Kode OTP telah dikirim ke WhatsApp Anda';
      case ForgotPinStage.enterNewPin:
      case ForgotPinStage.completed:
        return 'Masukkan PIN baru 6 digit';
    }
  }

  String _buttonLabelFor(ForgotPinStage stage) {
    switch (stage) {
      case ForgotPinStage.enterIdentifier:
        return 'KIRIM OTP';
      case ForgotPinStage.enterOtp:
        return 'VERIFIKASI';
      case ForgotPinStage.enterNewPin:
      case ForgotPinStage.completed:
        return 'SIMPAN PIN';
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    _titleFor(stage),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _subtitleFor(stage),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

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
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        errorText,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : () => _onPrimaryAction(stage),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
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
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
