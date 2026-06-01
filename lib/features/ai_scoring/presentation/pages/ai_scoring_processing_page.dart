import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/ai_scoring_input.dart';
import '../../domain/entities/ai_scoring_result.dart';
import '../bloc/ai_scoring_bloc.dart';
import '../bloc/ai_scoring_event.dart';
import '../bloc/ai_scoring_state.dart';
import '../widgets/ai_result_dialog.dart';
import '../widgets/robot_illustration.dart';

/// Step 4 — fires the prediction request and waits for the ML API response.
///
/// The BLoC is created here and immediately handed the [AiScoringPredictionRequested]
/// event. Animations stay in the page (presentation concern); the request
/// lifecycle stays in the BLoC.
class AiScoringProcessingPage extends StatelessWidget {
  final AiScoringInput input;

  const AiScoringProcessingPage({super.key, required this.input});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AiScoringBloc>(
      create: (_) => getIt<AiScoringBloc>()
        ..add(AiScoringPredictionRequested(input)),
      child: _AiScoringProcessingView(input: input),
    );
  }
}

class _AiScoringProcessingView extends StatefulWidget {
  final AiScoringInput input;

  const _AiScoringProcessingView({required this.input});

  @override
  State<_AiScoringProcessingView> createState() =>
      _AiScoringProcessingViewState();
}

class _AiScoringProcessingViewState extends State<_AiScoringProcessingView>
    with TickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  // ── Result presentation ────────────────────────────────────────────────

  void _showResult(AiScoringResult result) {
    AiResultDialog.show(context, result: result);
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<AiScoringBloc>()
                  .add(AiScoringPredictionRequested(widget.input));
            },
            child: const Text('Coba Lagi'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      body: Stack(
        children: [
          // Ambient glowing orbs background
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

          SafeArea(
            child: BlocBuilder<AiScoringBloc, AiScoringState>(
              builder: (context, state) {
                final isDone = state.status == AiScoringStatus.success ||
                    state.status == AiScoringStatus.error;
                return Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: _buildBody(state),
                        ),
                      ),
                    ),
                    _buildProgressBar(),
                    _buildActionButton(state, isDone),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.home_rounded, color: kHijauTua, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'KoopCare AI',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2E14),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AiScoringState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RobotIllustration(bounceAnimation: _bounceAnim),
          const SizedBox(height: 40),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildStatusText(state),
          ),
          if (state.status == AiScoringStatus.loading) ...[
            const SizedBox(height: 20),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: kHijauTua,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusText(AiScoringState state) {
    switch (state.status) {
      case AiScoringStatus.error:
        return Text(
          state.errorMessage ?? 'Gagal menghubungi sistem AI.\nSilakan coba lagi.',
          key: const ValueKey('error'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.redAccent,
            height: 1.6,
          ),
        );
      case AiScoringStatus.success:
        final approved = state.result?.isApproved ?? false;
        return Text(
          approved
              ? 'Analisis selesai!\nSistem AI telah mengevaluasi profil kredit Anda.'
              : 'Analisis selesai.\nKami telah mengevaluasi profil kredit Anda.',
          key: const ValueKey('done'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF555555),
            height: 1.6,
          ),
        );
      case AiScoringStatus.idle:
      case AiScoringStatus.loading:
        return const Text(
          'Mohon waktunya sebentar, Tim AI Kami sedang menghitung skor kelayakan kredit Anda.',
          key: ValueKey('loading'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF555555),
            height: 1.6,
          ),
        );
    }
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Steps',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
              Text(
                '4/4',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.75, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 6,
              color: kHijauTua,
              backgroundColor: const Color(0xFFE8F0D8),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(AiScoringState state, bool isDone) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDone
              ? [
                  BoxShadow(
                    color: kHijauTua.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isDone
              ? () {
                  if (state.status == AiScoringStatus.error) {
                    _showErrorDialog(
                      state.errorMessage ??
                          'Gagal menghubungi sistem AI.\nSilakan coba lagi.',
                    );
                  } else if (state.result != null) {
                    _showResult(state.result!);
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: kHijauTua,
            disabledBackgroundColor: const Color(0xFFB8C8A0),
            foregroundColor: kPutih,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            isDone ? 'Lihat Hasil' : 'Menghitung...',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
