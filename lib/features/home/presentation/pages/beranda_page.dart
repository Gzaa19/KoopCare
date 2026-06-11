import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import 'package:koopcare/features/loan/domain/entities/loan.dart';
import 'package:koopcare/features/loan/presentation/bloc/loan_bloc.dart';
import 'package:koopcare/features/loan/presentation/bloc/loan_event.dart';
import 'package:koopcare/features/loan/presentation/bloc/loan_state.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/shell/presentation/cubit/navigation_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/beranda_app_bar.dart';
import '../widgets/balance_card.dart';
import '../widgets/fin_stats_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/pembayaran_section.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});
  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage>
    with SingleTickerProviderStateMixin {
  bool _balanceVisible = true;

  late final AnimationController _ctrl;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState.user != null) {
          _loanBloc.add(const FetchLoans());
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState.user;
          return Scaffold(
            backgroundColor: kScaffold,
            body: SafeArea(
              child: BlocProvider<LoanBloc>.value(
                value: _loanBloc,
                child: BlocBuilder<LoanBloc, LoanState>(
                  builder: (context, loanState) {
                    Loan? activeLoan;
                    int loanCount = 0;
                    if (loanState is LoanLoaded && loanState.loans.isNotEmpty) {
                      final loans = loanState.loans;
                      loanCount = loans.length;
                      activeLoan = loans.cast<Loan?>().firstWhere(
                        (l) => l!.status == 'ACTIVE',
                        orElse: () => loans.cast<Loan?>().firstWhere(
                          (l) => l!.status == 'APPROVED',
                          orElse: () => loans.cast<Loan?>().firstWhere(
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
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _animated(
                                    4,
                                    PembayaranSection(
                                      activeLoan: activeLoan,
                                      onViewAll: () =>
                                          context.read<NavigationCubit>().changeTab(2),
                                    ),
                                  ),
                                  if (loanCount > 1) ...[
                                    const SizedBox(height: 12),
                                    _MultiLoanBanner(
                                      count: loanCount,
                                      onTap: () => context.read<NavigationCubit>().changeTab(2),
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
      ),
    );
  }
}

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