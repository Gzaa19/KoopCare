import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../loan/data/models/loan_model.dart';
import '../loan/presentation/bloc/loan_bloc.dart';
import '../loan/presentation/bloc/loan_event.dart';
import '../loan/presentation/bloc/loan_state.dart';
import '../../core/app_colors.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../auth/presentation/bloc/auth_event.dart';
import '../auth/presentation/bloc/auth_state.dart';
import 'presentation/widgets/beranda_app_bar.dart';
import 'presentation/widgets/balance_card.dart';
import 'presentation/widgets/fin_stats_card.dart';
import 'presentation/widgets/quick_actions.dart';
import 'presentation/widgets/pembayaran_section.dart';

// ─── Beranda Page ─────────────────────────────────────────────────────────────
class BerandaPage extends StatefulWidget {
  final void Function(int)? onSwitchTab;
  const BerandaPage({super.key, this.onSwitchTab});
  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage>
    with SingleTickerProviderStateMixin {
  bool _balanceVisible = true;

  // Staggered entrance
  late final AnimationController _ctrl;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  // Loan data (created once, survives AuthBloc rebuilds)
  late final LoanBloc _loanBloc;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  void initState() {
    super.initState();
    _loanBloc = getIt<LoanBloc>()..add(const FetchLoans());
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 5 sections: appbar, balance card, fin stats, quick actions, pembayaran
    _fades = List.generate(5, (i) {
      final s = i * 0.10;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(s, (s + 0.45).clamp(0, 1), curve: Curves.easeOut),
        ),
      );
    });

    _slides = List.generate(5, (i) {
      final s = i * 0.10;
      return Tween<Offset>(
        begin: const Offset(0, 0.22),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(
            s,
            (s + 0.45).clamp(0, 1),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.forward();
      // Refresh profile so balance is always current when beranda opens.
      context.read<AuthBloc>().add(const AuthProfileRefreshRequested());
    });
  }

  @override
  void dispose() {
    _loanBloc.close();
    _ctrl.dispose();
    super.dispose();
  }

  Widget _animated(int index, Widget child) => FadeTransition(
        opacity: _fades[index],
        child: SlideTransition(position: _slides[index], child: child),
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.user;
        return Scaffold(
          backgroundColor: kScaffold,
          body: SafeArea(
            child: BlocProvider<LoanBloc>.value(
              value: _loanBloc,
              child: BlocBuilder<LoanBloc, LoanState>(
                builder: (context, loanState) {
                  // Resolve the most relevant active loan for the summary cards.
                  LoanModel? activeLoan;
                  int loanCount = 0;
                  if (loanState is LoanLoaded && loanState.loans.isNotEmpty) {
                    final loans = loanState.loans;
                    loanCount = loans.length;
                    activeLoan = loans.cast<LoanModel?>().firstWhere(
                          (l) => l!.status == 'ACTIVE',
                          orElse: () => loans.cast<LoanModel?>().firstWhere(
                                (l) => l!.status == 'APPROVED',
                                orElse: () =>
                                    loans.cast<LoanModel?>().firstWhere(
                                          (l) => l!.status == 'PENDING',
                                          orElse: () => loans.first,
                                        ),
                              ),
                        );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<AuthBloc>()
                          .add(const AuthProfileRefreshRequested());
                      // also refresh loans
                      _loanBloc.add(const FetchLoans());
                      await Future.delayed(const Duration(milliseconds: 600));
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _animated(
                            0,
                            BerandaAppBar(
                              user: user,
                              greeting: _getGreeting(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _animated(
                                  1,
                                  BalanceCard(
                                    user: user,
                                    balanceVisible: _balanceVisible,
                                    onToggleVisibility: () => setState(
                                      () => _balanceVisible = !_balanceVisible,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _animated(
                                  2,
                                  FinStatsCard(activeLoan: activeLoan),
                                ),
                                const SizedBox(height: 20),
                                _animated(
                                  3,
                                  QuickActions(
                                    user: user,
                                    onSwitchTab: widget.onSwitchTab,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _animated(
                                  4,
                                  PembayaranSection(
                                    activeLoan: activeLoan,
                                    onViewAll: () =>
                                        widget.onSwitchTab?.call(2),
                                  ),
                                ),
                                // When there are multiple loans, the summary
                                // above shows only the most relevant one — this
                                // banner tells the user there are more and
                                // routes them to the cicilan tab to pick.
                                if (loanCount > 1) ...[
                                  const SizedBox(height: 12),
                                  _MultiLoanBanner(
                                    count: loanCount,
                                    onTap: () => widget.onSwitchTab?.call(2),
                                  ),
                                ],
                                const SizedBox(height: 110),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Banner shown when the member has more than one loan ───────────────────────
class _MultiLoanBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _MultiLoanBanner({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0D8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.layers_outlined, size: 20, color: kHijauTua),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Anda memiliki $count pembiayaan. Ketuk untuk melihat semua.',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D2E14),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: kHijauTua),
          ],
        ),
      ),
    );
  }
}