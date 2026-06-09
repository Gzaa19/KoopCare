import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/di/service_locator.dart';
import 'package:koopcare/core/router/route_names.dart';
import 'package:koopcare/core/widgets/app_widgets.dart';
import 'package:koopcare/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:koopcare/features/auth/presentation/bloc/auth_state.dart';
import 'package:koopcare/features/auth/presentation/widgets/login_form.dart';
import 'package:koopcare/features/auth/presentation/widgets/login_success_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _formFade;
  late final Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
      ),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>(),
      child: Scaffold(
        backgroundColor: kScaffold,
        resizeToAvoidBottomInset: true,
        body: _LoginView(
          logoFade: _logoFade,
          logoSlide: _logoSlide,
          formFade: _formFade,
          formSlide: _formSlide,
        ),
      ),
    );
  }
}

class _LoginView extends StatelessWidget {
  final Animation<double> logoFade;
  final Animation<Offset> logoSlide;
  final Animation<double> formFade;
  final Animation<Offset> formSlide;

  const _LoginView({
    required this.logoFade,
    required this.logoSlide,
    required this.formFade,
    required this.formSlide,
  });

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state.status == AuthStatus.authenticated) {
      LoginSuccessDialog.show(
        context,
        onContinue: () {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context).pushNamedAndRemoveUntil(
            RouteNames.home,
            (_) => false,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AmbientOrbBackground(),

        SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listenWhen: (a, b) => a.status != b.status,
            listener: _onAuthStateChanged,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),

                        FadeTransition(
                          opacity: logoFade,
                          child: SlideTransition(
                            position: logoSlide,
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/koopcare.png',
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Selamat Datang Kembali',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1D2E14),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Akses amanah pembiayaan Syariah dan tabungan Koperasi Anda',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        FadeTransition(
                          opacity: formFade,
                          child: SlideTransition(
                            position: formSlide,
                            child: LoginForm(
                              onForgotPin: () => Navigator.pushNamed(
                                context,
                                RouteNames.forgotPin,
                              ),
                              onRegister: () => Navigator.pushNamed(
                                context,
                                RouteNames.register1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
