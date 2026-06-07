import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_colors.dart';

// ─── Slide-from-right page transition ────────────────────────────────────────

/// Standard slide-from-right + fade [PageRouteBuilder] used across the app.
///
/// Usage:
/// ```dart
/// Navigator.push(context, appSlideRoute(const SomePage()));
/// ```
PageRouteBuilder<T> appSlideRoute<T>(Widget page) => PageRouteBuilder<T>(
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

// ─── Ambient orb background ───────────────────────────────────────────────────

/// Two soft glowing circles + a backdrop blur, used as the background on
/// auth and financial form pages.
///
/// Wrap your page's [Stack] children with this widget:
/// ```dart
/// Stack(children: [
///   const AmbientOrbBackground(),
///   SafeArea(child: ...),
/// ])
/// ```
class AmbientOrbBackground extends StatelessWidget {
  const AmbientOrbBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -150,
          left: -150,
          child: Container(
            width: 380,
            height: 380,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8F0D8).withValues(alpha: 0.75),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          right: -150,
          child: Container(
            width: 380,
            height: 380,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFDDE5C8).withValues(alpha: 0.65),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

// ─── Loading indicator ────────────────────────────────────────────────────────

/// Centered [CircularProgressIndicator] in the app's primary green colour.
///
/// Drop-in replacement for the repeated:
/// ```dart
/// Center(child: CircularProgressIndicator(color: kHijauTua))
/// ```
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: kHijauTua),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

/// Full-screen error state: icon, message, and a "Coba Lagi" retry button.
///
/// ```dart
/// AppErrorView(
///   message: state.errorMessage ?? 'Gagal memuat data',
///   onRetry: () => context.read<MyBloc>().add(const FetchRequested()),
/// )
/// ```
class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  /// Optional icon — defaults to [Icons.cloud_off_rounded].
  final IconData icon;

  const AppErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.cloud_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: const Color(0xFFB5C0A4)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: kHijauTua,
                foregroundColor: kPutih,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

/// Centered empty-state: icon + message, no action button.
///
/// ```dart
/// AppEmptyView(
///   icon: Icons.notifications_none_rounded,
///   message: 'Belum ada notifikasi',
/// )
/// ```
class AppEmptyView extends StatelessWidget {
  final IconData icon;
  final String message;

  const AppEmptyView({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kAbuAbu.withValues(alpha: 0.5), size: 64),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: kAbuAbu,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Account Inactive Dialog ──────────────────────────────────────────────────

/// Displays a premium minimalist dialog informing the user that the loan feature
/// is locked because their KYC/account is not yet approved by the admin.
void showAccountInactiveDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: kPutih,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: Colors.orange.shade700,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Fitur Terkunci',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2E14),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Fitur keuangan hanya dapat digunakan jika akun Anda telah aktif dan diverifikasi oleh Admin.\n\nPastikan pengajuan KYC Anda sudah disetujui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kHijauTua,
                  foregroundColor: kPutih,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Mengerti',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Runs [action] only if the account is verified (ACTIVE). Otherwise shows
/// the KYC-locked dialog. Use to gate all financial features behind approval.
void guardVerified(
  BuildContext context, {
  required String? status,
  required VoidCallback action,
}) {
  if (status == 'ACTIVE') {
    action();
  } else {
    showAccountInactiveDialog(context);
  }
}

