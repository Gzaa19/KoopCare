import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/register/register_bloc.dart';
import '../bloc/register/register_event.dart';
import '../bloc/register/register_state.dart';
import '../widgets/register/pin_input_row.dart';
import 'pin_success_page.dart';

/// Final registration step: user picks a 6-digit PIN; we hit `/register`,
/// cache the JWT, and route to [PinSuccessPage].
///
/// The full registration form was assembled across the Step1/Step2 pages and
/// arrives here via constructor parameters. This page owns the PIN inputs
/// and dispatches a single [RegisterSubmitted] event.
class CreatePinPage extends StatelessWidget {
  final String fullName;
  final String noWa;
  final String nik;

  const CreatePinPage({
    super.key,
    required this.fullName,
    required this.noWa,
    required this.nik,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterBloc>(
      create: (_) => getIt<RegisterBloc>(),
      child: _CreatePinView(
        fullName: fullName,
        noWa: noWa,
        nik: nik,
      ),
    );
  }
}

class _CreatePinView extends StatefulWidget {
  final String fullName;
  final String noWa;
  final String nik;

  const _CreatePinView({
    required this.fullName,
    required this.noWa,
    required this.nik,
  });

  @override
  State<_CreatePinView> createState() => _CreatePinViewState();
}

class _CreatePinViewState extends State<_CreatePinView> {
  final List<TextEditingController> _pinCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<TextEditingController> _confirmCtrls =
      List.generate(6, (_) => TextEditingController());

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

    context.read<RegisterBloc>().add(RegisterSubmitted(
          fullName: widget.fullName,
          phone: widget.noWa,
          nik: widget.nik,
          pin: pinValue,
        ));
  }

  void _onStateChanged(BuildContext context, RegisterState state) {
    if (state.status == RegisterStatus.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PinSuccessPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Center(
                      child: Text(
                        'Akun anda sudah aktif!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Buat 6-digit PIN Keamanan.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Buat PIN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    PinInputRow(controllers: _pinCtrls),
                    const SizedBox(height: 30),
                    const Text(
                      'Konfirmasi PIN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    PinInputRow(controllers: _confirmCtrls),
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
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PinSuccessPage(),
                            ),
                          ),
                          child: const Text(
                            'Skip (debug)',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
