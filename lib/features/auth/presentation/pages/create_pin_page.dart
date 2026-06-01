import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/di/service_locator.dart';
import 'package:koopcare/core/widgets/app_widgets.dart';
import '../../../../core/router/route_args.dart';
import '../../../../core/router/route_names.dart';
import '../bloc/register/register_bloc.dart';
import '../bloc/register/register_event.dart';
import '../bloc/register/register_state.dart';
import '../widgets/register/pin_input_row.dart';

class CreatePinPage extends StatelessWidget {
  final String fullName;
  final String noWa;
  final String nik;
  final String ktpFilePath;
  final String selfieFilePath;

  const CreatePinPage({
    super.key,
    required this.fullName,
    required this.noWa,
    required this.nik,
    required this.ktpFilePath,
    required this.selfieFilePath,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterBloc>(
      create: (_) => getIt<RegisterBloc>(),
      child: _CreatePinView(
        fullName: fullName,
        noWa: noWa,
        nik: nik,
        ktpFilePath: ktpFilePath,
        selfieFilePath: selfieFilePath,
      ),
    );
  }
}

class _CreatePinView extends StatefulWidget {
  final String fullName;
  final String noWa;
  final String nik;
  final String ktpFilePath;
  final String selfieFilePath;

  const _CreatePinView({
    required this.fullName,
    required this.noWa,
    required this.nik,
    required this.ktpFilePath,
    required this.selfieFilePath,
  });

  @override
  State<_CreatePinView> createState() => _CreatePinViewState();
}

class _CreatePinViewState extends State<_CreatePinView> {
  final List<TextEditingController> _pinCtrls = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _confirmCtrls = List.generate(
    6,
    (_) => TextEditingController(),
  );

  String? _localError;

  @override
  void dispose() {
    for (final c in [..._pinCtrls, ..._confirmCtrls]) {
      c.dispose();
    }
    super.dispose();
  }

  String _read(List<TextEditingController> list) =>
      list.map((c) => c.text).join();

  void _onSubmit() {
    final pinValue = _read(_pinCtrls);
    final confirmValue = _read(_confirmCtrls);

    if (pinValue.length != 6 || confirmValue.length != 6) {
      setState(() => _localError = 'PIN harus 6 digit');
      return;
    }
    if (pinValue != confirmValue) {
      setState(() => _localError = 'PIN tidak sama');
      return;
    }
    setState(() => _localError = null);

    context.read<RegisterBloc>().add(
          RegisterSubmitted(
            fullName: widget.fullName,
            phone: widget.noWa,
            nik: widget.nik,
            pin: pinValue,
          ),
        );
  }

  void _onStateChanged(BuildContext context, RegisterState state) {
    if (state.status == RegisterStatus.success) {
      Navigator.pushReplacementNamed(
        context,
        RouteNames.pinSuccess,
        arguments: PinSuccessArgs(
          ktpFilePath: widget.ktpFilePath,
          selfieFilePath: widget.selfieFilePath,
        ),
      );
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
            child: BlocConsumer<RegisterBloc, RegisterState>(
              listenWhen: (a, b) => a.status != b.status,
              listener: _onStateChanged,
              builder: (context, state) {
                final isLoading = state.status == RegisterStatus.submitting;
                final errorText = isLoading
                    ? null
                    : (_localError ??
                        (state.status == RegisterStatus.error
                            ? state.errorMessage
                            : null));

                return SingleChildScrollView(
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
                          const Text(
                            'Buat PIN Keamanan',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D2E14),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Pilih 6 digit angka untuk mengamankan akun KoopCare Anda. Jangan gunakan angka berurutan atau yang mudah ditebak.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(
                          'Masukkan PIN Baru',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1D2E14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PinInputRow(controllers: _pinCtrls),
                      const SizedBox(height: 28),
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(
                          'Konfirmasi PIN Baru',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1D2E14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PinInputRow(controllers: _confirmCtrls),
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
                      const SizedBox(height: 40),
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
                            onPressed: isLoading ? null : _onSubmit,
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
                                : const Text(
                                    'Simpan & Lanjut',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
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
