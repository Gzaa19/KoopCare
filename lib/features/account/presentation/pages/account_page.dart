import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/di/service_locator.dart';
import 'package:koopcare/core/router/route_names.dart';
import 'package:koopcare/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:koopcare/features/auth/presentation/bloc/auth_event.dart';
import 'package:koopcare/features/auth/presentation/bloc/auth_state.dart';
import 'package:koopcare/features/loan/presentation/bloc/loan_bloc.dart';
import 'package:koopcare/features/loan/presentation/bloc/loan_event.dart';
import 'package:koopcare/features/loan/presentation/bloc/loan_state.dart';
import 'package:koopcare/features/account/presentation/widgets/account_header_widget.dart';
import 'package:koopcare/features/account/presentation/widgets/dashboard_cards_widget.dart';
import 'package:koopcare/features/account/presentation/widgets/menu_section_widget.dart';
import 'package:koopcare/features/account/presentation/widgets/logout_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late final LoanBloc _loanBloc;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _loanBloc = getIt<LoanBloc>()..add(const FetchLoans());

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animCtrl.forward();
      context.read<AuthBloc>().add(const AuthProfileRefreshRequested());
    });
  }

  @override
  void dispose() {
    _loanBloc.close();
    _animCtrl.dispose();
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
          final email = user?.email ?? user?.phone ?? '—';
          final balance = user?.balance ?? 0.0;

          return BlocProvider<LoanBloc>.value(
            value: _loanBloc,
            child: BlocBuilder<LoanBloc, LoanState>(
              builder: (context, loanState) {
                double totalLoanKewajiban = 0.0;
                if (loanState is LoanLoaded) {
                  for (final loan in loanState.loans) {
                    if (loan.status == 'ACTIVE' || loan.status == 'APPROVED') {
                      totalLoanKewajiban += loan.approvedAmount ?? loan.amount;
                    }
                  }
                }

                return FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        AccountHeaderWidget(name: name, email: email),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              DashboardCardsWidget(
                                balance: balance,
                                totalLoan: totalLoanKewajiban,
                              ),
                              const SizedBox(height: 24),
                              MenuSectionWidget(
                                title: "KOPERASI & LAYANAN",
                                items: [
                                  MenuItemData(
                                    icon: Icons.info_outline_rounded,
                                    title: "General info",
                                    subtitle: "Detail informasi keanggotaan Anda",
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        RouteNames.generalInfo,
                                      );
                                    },
                                  ),
                                  MenuItemData(
                                    icon: Icons.credit_card_rounded,
                                    title: "Rekening Bank / Kartu",
                                    subtitle: "Kelola akun bank untuk penarikan dana",
                                    onTap: () => showComingSoon(context, "Rekening Bank / Kartu"),
                                  ),
                                  MenuItemData(
                                    icon: Icons.help_outline_rounded,
                                    title: "FAQ",
                                    subtitle: "Pertanyaan yang sering diajukan",
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        RouteNames.faq,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              MenuSectionWidget(
                                title: "PENGATURAN",
                                items: [
                                  MenuItemData(
                                    icon: Icons.security_rounded,
                                    title: "Pengaturan Keamanan",
                                    subtitle: "Ganti PIN, password & biometrik",
                                    onTap: () => showComingSoon(context, "Pengaturan Keamanan"),
                                  ),
                                  MenuItemData(
                                    icon: Icons.notifications_none_rounded,
                                    title: "Pengaturan Notifikasi",
                                    subtitle: "Kelola preferensi pemberitahuan Anda",
                                    onTap: () => showComingSoon(context, "Pengaturan Notifikasi"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              MenuSectionWidget(
                                title: "DUKUNGAN & TANGGAPAN",
                                items: [
                                  MenuItemData(
                                    icon: Icons.headset_mic_outlined,
                                    title: "Hubungi Kami",
                                    subtitle: "Hubungi bantuan customer service Koperasi",
                                    onTap: () => showComingSoon(context, "Hubungi Kami"),
                                  ),
                                  MenuItemData(
                                    icon: Icons.star_border_rounded,
                                    title: "Suka? Nilai kami",
                                    subtitle: "Berikan ulasan Anda di App Store",
                                    onTap: () => showComingSoon(context, "Beri Ulasan"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const LogoutButton(),
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
          );
        },
      ),
    );
  }
}
