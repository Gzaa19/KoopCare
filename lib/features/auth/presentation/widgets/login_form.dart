import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Identifier + PIN form. Owns its own input controllers; delegates the
/// actual login to [AuthBloc] via [AuthLoginRequested].
class LoginForm extends StatefulWidget {
  final VoidCallback onForgotPin;
  final VoidCallback onRegister;

  const LoginForm({
    super.key,
    required this.onForgotPin,
    required this.onRegister,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _identifierCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  bool _obscurePin = true;
  String? _localError;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final identifier = _identifierCtrl.text.trim();
    final pin = _pinCtrl.text.trim();

    if (identifier.isEmpty) {
      setState(() => _localError = 'Nomor WhatsApp / NIK wajib diisi');
      return;
    }
    if (pin.length != 6) {
      setState(() => _localError = 'PIN harus 6 digit');
      return;
    }
    setState(() => _localError = null);
    context.read<AuthBloc>().add(
          AuthLoginRequested(identifier: identifier, pin: pin),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (a, b) => a.status != b.status || a.errorMessage != b.errorMessage,
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;
        // Local validation error wins over remote, but a fresh remote error
        // also clears the local one.
        final errorText = isLoading
            ? null
            : (_localError ??
                (state.status == AuthStatus.error ? state.errorMessage : null));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Nomor WA / NIK
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'NOMOR WHATSAPP / NIK',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _identifierCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.person_outline),
                  hintText: 'Masukkan nomor WA atau NIK',
                ),
              ),
            ),

            const SizedBox(height: 20),

            // PIN
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'PIN (6 DIGIT)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _pinCtrl,
                obscureText: _obscurePin,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 6,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  icon: const Icon(Icons.lock_outline),
                  hintText: '••••••',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePin
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePin = !_obscurePin),
                  ),
                ),
              ),
            ),

            // Error
            if (errorText != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  errorText,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ],

            // Lupa PIN
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onForgotPin,
                child: const Text(
                  'Lupa PIN?',
                  style:
                      TextStyle(color: Color(0xFF6B7F3F), fontSize: 13),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Tombol Masuk
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B7F3F),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'MASUK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),

            // Daftar baru
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum jadi anggota? '),
                GestureDetector(
                  onTap: widget.onRegister,
                  child: const Text(
                    'Daftar Baru',
                    style: TextStyle(
                      color: Color(0xFF6B7F3F),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        );
      },
    );
  }
}
