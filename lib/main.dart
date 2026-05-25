import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/auth/login/login_page.dart';
import 'features/home/main_shell.dart';
import 'services/auth_service.dart';
import 'core/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: kScaffold,
        colorScheme: ColorScheme.fromSeed(seedColor: kHijauTua),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const _AuthGate(),
    );
  }
}

// Cek token lokal saat app dibuka.
// Ada token → langsung MainShell (tidak perlu login ulang).
// Tidak ada → LoginPage.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: kHijauTua,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        return snapshot.data! ? const MainShell() : const LoginPage();
      },
    );
  }
}
