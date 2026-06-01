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
