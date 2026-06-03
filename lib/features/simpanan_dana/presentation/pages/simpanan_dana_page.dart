import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/di/service_locator.dart';
import 'package:koopcare/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:koopcare/features/auth/presentation/bloc/auth_event.dart';
import 'package:koopcare/features/auth/presentation/bloc/auth_state.dart';
import 'package:koopcare/features/loan/data/models/loan_model.dart';
import 'package:koopcare/features/loan/presentation/bloc/loan_bloc.dart';
import 'package:koopcare/features/loan/presentation/bloc/loan_event.dart';
import 'package:koopcare/features/loan/presentation/bloc/loan_state.dart';
import 'package:koopcare/features/simpanan_dana/presentation/widgets/simpanan_user_row_widget.dart';
import 'package:koopcare/features/simpanan_dana/presentation/widgets/wallet_card_widget.dart';
import 'package:koopcare/features/simpanan_dana/presentation/widgets/loan_status_widget.dart';

class SimpananDanaPage extends StatefulWidget {
  const SimpananDanaPage({super.key});

  @override
  State<SimpananDanaPage> createState() => _SimpananDanaPageState();
}

class _SimpananDanaPageState extends State<SimpananDanaPage>
    with SingleTickerProviderStateMixin {
  late final LoanBloc _loanBloc;

  // Entrance animations
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _loanBloc = getIt<LoanBloc>()..add(const FetchLoans());

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceCtrl.forward();
      context.read<AuthBloc>().add(const AuthProfileRefreshRequested());
    });
  }

  @override
  void dispose() {
    _loanBloc.close();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState.user;
          final name = user?.name ?? '—';
          final balance = user?.balance ?? 0.0;

          return BlocProvider<LoanBloc>.value(
            value: _loanBloc,
            child: BlocBuilder<LoanBloc, LoanState>(
              builder: (context, loanState) {
                LoanModel? activeLoan;
                if (loanState is LoanLoaded && loanState.loans.isNotEmpty) {
                  final loans = loanState.loans;
                  // Priority: ACTIVE > APPROVED > PENDING > any
                  activeLoan = loans.cast<LoanModel?>().firstWhere(
                        (l) => l!.status == 'ACTIVE',
                        orElse: () => loans.cast<LoanModel?>().firstWhere(
                              (l) => l!.status == 'APPROVED',
                              orElse: () => loans.cast<LoanModel?>().firstWhere(
                                    (l) => l!.status == 'PENDING',
                                    orElse: () => loans.first,
                                  ),
                            ),
                      );
                }

                return SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              const Text(
                                'Simpanan Dana',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D2E14),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SimpananUserRowWidget(name: name),
                              const SizedBox(height: 20),
                              WalletCardWidget(balance: balance),
                              const SizedBox(height: 28),
                              const Text(
                                "Aktivitas Pembiayaan Anda",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D2E14),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              LoanStatusWidget(loan: activeLoan, user: user),
                              const SizedBox(height: 110),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
