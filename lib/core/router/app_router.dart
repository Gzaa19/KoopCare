import 'package:flutter/material.dart';

import '../../features/ai_scoring/presentation/pages/ai_scoring_processing_page.dart';
import '../../features/ai_scoring/presentation/pages/ai_scoring_step1_page.dart';
import '../../features/ai_scoring/presentation/pages/ai_scoring_step2_page.dart';
import '../../features/ai_scoring/presentation/pages/ai_scoring_step3_page.dart';
import '../../features/auth/presentation/pages/create_pin_page.dart';
import '../../features/auth/presentation/pages/forgot_pin_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/pin_success_page.dart';
import '../../features/auth/presentation/pages/register_step1_page.dart';
import '../../features/auth/presentation/pages/register_step2_page.dart';
import '../../features/auth/presentation/pages/register_success_page.dart';
import '../../features/loan/presentation/pages/pembayaran_detail_page.dart';
import '../../features/loan/presentation/pages/pengajuan_pembiayaan_page.dart';
import '../../features/loan/presentation/pages/pin_verification.dart';
import '../../features/transfer/presentation/pages/transfer_page.dart';
import '../../features/topup/presentation/pages/topup_page.dart';
import '../../features/topup/presentation/pages/topup_success_page.dart';
import '../../features/faq/presentation/pages/faq_page.dart';
import '../../features/home/main_shell.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/profile/presentation/pages/general_info_page.dart';
import '../../features/riwayat/presentation/pages/riwayat_page.dart';
import 'route_args.dart';
import 'route_names.dart';


/// Centralized router for the entire app.
///
/// Register all routes here. Pages that need arguments receive them via
/// [RouteSettings.arguments] cast to the appropriate [*Args] class from
/// [route_args.dart].
///
/// Usage in [MaterialApp]:
/// ```dart
/// MaterialApp(
///   onGenerateRoute: AppRouter.onGenerateRoute,
///   initialRoute: RouteNames.login,
/// )
/// ```
abstract class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Auth ───────────────────────────────────────────────────────────────
      case RouteNames.login:
        return _slide(const LoginPage());

      case RouteNames.register1:
        return _slide(const RegisterStep1Page());

      case RouteNames.register2:
        final args = settings.arguments as Register2Args;
        return _slide(RegisterStep2Page(
          nama: args.nama,
          noWa: args.noWa,
          nik: args.nik,
        ));

      case RouteNames.createPin:
        final args = settings.arguments as CreatePinArgs;
        return _slide(CreatePinPage(
          fullName: args.fullName,
          noWa: args.noWa,
          nik: args.nik,
          ktpFilePath: args.ktpFilePath,
          selfieFilePath: args.selfieFilePath,
        ));

      case RouteNames.pinSuccess:
        final args = settings.arguments as PinSuccessArgs?;
        return _slide(PinSuccessPage(
          ktpFilePath: args?.ktpFilePath,
          selfieFilePath: args?.selfieFilePath,
        ));

      case RouteNames.registerDone:
        return _slide(const RegisterSuccessPage());

      case RouteNames.forgotPin:
        return _slide(const ForgotPinPage());

      // ── Shell ──────────────────────────────────────────────────────────────
      case RouteNames.home:
        return _fade(const MainShell());

      // ── Notification ───────────────────────────────────────────────────────
      case RouteNames.notification:
        return _slide(const NotificationPage());

      // ── Financial ──────────────────────────────────────────────────────────
      case RouteNames.pengajuan:
        return _slide(const PengajuanPembiayaanPage());

      case RouteNames.topup:
        return _slide(const TopUpPage());

      case RouteNames.topupSuccess:
        return _fade(const TopUpSuccessPage());

      case RouteNames.transfer:
        return _slide(const TransferPage());

      case RouteNames.pinVerify:
        return _slide(const PinVerificationPage());

      case RouteNames.pembayaranDetail:
        final args = settings.arguments as PembayaranDetailArgs?;
        return _slide(PembayaranDetailPage(loan: args?.loan));
      
      case RouteNames.riwayat:
        return _slide(const RiwayatPage());

      // ── AI Scoring ─────────────────────────────────────────────────────────
      case RouteNames.aiStep1:
        final args = settings.arguments as AiStep1Args;
        return _slideFade(AiScoringStep1Page(
          loanAmount: args.loanAmount,
          loanTenor: args.loanTenor,
          loanPurpose: args.loanPurpose,
          loanType: args.loanType,
        ));

      case RouteNames.aiStep2:
        final args = settings.arguments as AiStep2Args;
        return _slideFade(AiScoringStep2Page(
          loanAmount: args.loanAmount,
          loanTenor: args.loanTenor,
          loanPurpose: args.loanPurpose,
          loanType: args.loanType,
          jenisKelamin: args.jenisKelamin,
          tanggalLahir: args.tanggalLahir,
          pendidikan: args.pendidikan,
          statusNikah: args.statusNikah,
        ));

      case RouteNames.aiStep3:
        final args = settings.arguments as AiStep3Args;
        return _slideFade(AiScoringStep3Page(
          loanAmount: args.loanAmount,
          loanTenor: args.loanTenor,
          loanPurpose: args.loanPurpose,
          loanType: args.loanType,
          jenisKelamin: args.jenisKelamin,
          tanggalLahir: args.tanggalLahir,
          pendidikan: args.pendidikan,
          statusNikah: args.statusNikah,
          punyaProperti: args.punyaProperti,
          punyaKendaraan: args.punyaKendaraan,
          sumberPenghasilan: args.sumberPenghasilan,
          pekerjaan: args.pekerjaan,
          lamaBekerja: args.lamaBekerja,
          lamaNomorHp: args.lamaNomorHp,
        ));

      case RouteNames.aiProcessing:
        final args = settings.arguments as AiProcessingArgs;
        return _slideFade(AiScoringProcessingPage(input: args.input));

      // ── Profile ────────────────────────────────────────────────────────────
      case RouteNames.generalInfo:
        return _slide(const GeneralInfoPage());

      case RouteNames.faq:
        return _slide(const FaqPage());

      // ── Fallback ───────────────────────────────────────────────────────────
      default:
        return _slide(const LoginPage());
    }
  }

  // ── Transition helpers ─────────────────────────────────────────────────────

  /// Slide from right — default for most page pushes.
  static PageRouteBuilder<T> _slide<T>(Widget page) => PageRouteBuilder<T>(
        settings: RouteSettings(name: _nameOf(page)),
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );

  /// Fade — used for root-level transitions (login → home).
  static PageRouteBuilder<T> _fade<T>(Widget page) => PageRouteBuilder<T>(
        settings: RouteSettings(name: _nameOf(page)),
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      );

  /// Slide + fade — used for AI scoring steps (matches existing behaviour).
  static PageRouteBuilder<T> _slideFade<T>(Widget page) => PageRouteBuilder<T>(
        settings: RouteSettings(name: _nameOf(page)),
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: anim, child: child),
        ),
      );

  static String? _nameOf(Widget page) => page.runtimeType.toString();
}
