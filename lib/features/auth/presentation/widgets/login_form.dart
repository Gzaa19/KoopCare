import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koopcare/core/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

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

  final _identifierFocus = FocusNode();
  final _pinFocus = FocusNode();

  bool _obscurePin = true;
  String? _localError;

  bool _isIdentifierFocused = false;
  bool _isPinFocused = false;

  @override
  void initState() {
    super.initState();
    _identifierFocus.addListener(() {
      setState(() => _isIdentifierFocused = _identifierFocus.hasFocus);
    });
    _pinFocus.addListener(() {
      setState(() => _isPinFocused = _pinFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _pinCtrl.dispose();
    _identifierFocus.dispose();
    _pinFocus.dispose();
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
      buildWhen: (a, b) =>
          a.status != b.status || a.errorMessage != b.errorMessage,
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;
        final errorText = isLoading
            ? null
            : (_localError ??
                  (state.status == AuthStatus.error
                      ? state.errorMessage
                      : null));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  'Nomor WhatsApp / NIK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1D2E14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: kPutih,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isIdentifierFocused
                      ? kHijauTua
                      : const Color(0xFFE8F0D8),
                  width: _isIdentifierFocused ? 1.8 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isIdentifierFocused
                        ? kHijauTua.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _identifierCtrl,
                focusNode: _identifierFocus,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF1A1A1A),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.phone_iphone_rounded,
                    color: kHijauTua,
                    size: 20,
                  ),
                  hintText: '628***********',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Color(0xFFAAAAAA),
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  'PIN Koperasi (6 Digit)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1D2E14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: kPutih,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isPinFocused ? kHijauTua : const Color(0xFFE8F0D8),
                  width: _isPinFocused ? 1.8 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isPinFocused
                        ? kHijauTua.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _pinCtrl,
                focusNode: _pinFocus,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 2,
                ),
                obscureText: _obscurePin,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 6,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: InputBorder.none,
                  counterText: '',
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: kHijauTua,
                    size: 20,
                  ),
                  hintText: '••••••',
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Color(0xFFAAAAAA),
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePin
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: kHijauTua,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePin = !_obscurePin),
                  ),
                ),
              ),
            ),

            if (errorText != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEECEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFCD5D2),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFD32F2F),
                      size: 18,
                    ),
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

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onForgotPin,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lupa PIN Koperasi?',
                  style: TextStyle(
                    color: kHijauTua,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

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
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kHijauTua,
                    foregroundColor: kPutih,
                    disabledBackgroundColor: kHijauTua.withValues(alpha: 0.6),
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
                          'Masuk Ke Akun',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Belum terdaftar anggota? ',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
                ),
                GestureDetector(
                  onTap: widget.onRegister,
                  child: const Text(
                    'Daftar Baru',
                    style: TextStyle(
                      color: kHijauTua,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
