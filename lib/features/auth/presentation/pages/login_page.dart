import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../home/main_shell.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';
import '../widgets/login_success_dialog.dart';
import 'forgot_pin_page.dart';
import 'register_step1_page.dart';

/// Login screen. Pulls `AuthBloc` from the service locator, renders the form,
/// reacts to `AuthState` transitions for navigation and the success dialog.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state.status == AuthStatus.authenticated) {
      LoginSuccessDialog.show(
        context,
        onContinue: () {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, a, _) => const MainShell(),
              transitionsBuilder: (_, a, _, child) =>
                  FadeTransition(opacity: a, child: child),
              transitionDuration: const Duration(milliseconds: 250),
            ),
            (_) => false,
          );
        },
      );
    }
    // Errors are surfaced inline by the form via BlocBuilder; nothing to do.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (a, b) => a.status != b.status,
          listener: _onAuthStateChanged,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B7F3F),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.home_outlined,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Selamat Datang Kembali',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  LoginForm(
                    onForgotPin: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPinPage(),
                      ),
                    ),
                    onRegister: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterStep1Page(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
