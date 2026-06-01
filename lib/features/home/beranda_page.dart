import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/di/service_locator.dart';
import '../financial/data/models/loan_model.dart';
import '../financial/presentation/bloc/loan/loan_bloc.dart';
import '../financial/presentation/bloc/loan/loan_event.dart';
import '../financial/presentation/bloc/loan/loan_state.dart';
import '../../core/app_colors.dart';
import '../../core/router/route_args.dart';
import '../../core/router/route_names.dart';
import '../auth/domain/entities/auth_user.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../auth/presentation/bloc/auth_event.dart';
import '../auth/presentation/bloc/auth_state.dart';
import '../notification/presentation/bloc/notification_bloc.dart';
import '../notification/presentation/bloc/notification_state.dart';

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

  // ── Loan data (created once, survives AuthBloc rebuilds) ──────────
  late final LoanBloc _loanBloc;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  @override
  void initState() {
    super.initState();
    _loanBloc = getIt<LoanBloc>()..add(const FetchLoans());
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 5 sections: appbar row, balance card, fin stats, quick actions, pembayaran section
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
          curve: Interval(s, (s + 0.45).clamp(0, 1), curve: Curves.easeOutCubic),
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

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _animated(0, _buildAppBar(user)),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _animated(1, _buildBalanceCard(user)),
                              const SizedBox(height: 14),
                              _animated(2, _buildFinStats(user, activeLoan)),
                              const SizedBox(height: 20),
                              _animated(3, _buildQuickActions()),
                              const SizedBox(height: 24),
                              _animated(4, _buildPembayaranSection(activeLoan)),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                      ],
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

  // ── App bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar(AuthUser? user) {
    final displayName = user?.name ?? '—';
    final greeting = _getGreeting();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: kPutih,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8F0D8), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.person_outline_rounded, color: kHijauTua, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const Spacer(),
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, notifState) {
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, RouteNames.notification),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: kPutih,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF444444),
                        size: 22,
                      ),
                    ),
                    if (notifState.unreadCount > 0)
                      Positioned(
                        top: -1,
                        right: -1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade700,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kPutih, width: 1.5),
                          ),
                          child: Text(
                            notifState.unreadCount > 99
                                ? '99+'
                                : '${notifState.unreadCount}',
                            style: const TextStyle(
                              color: kPutih,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoldChip() {
    return Container(
      width: 38,
      height: 28,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD700),
            Color(0xFFFFA500),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: GridPaper(
              color: Colors.black.withValues(alpha: 0.12),
              divisions: 2,
              subdivisions: 1,
              child: const SizedBox.shrink(),
            ),
          ),
          Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Total Simpanan balance card ───────────────────────────────────────────
  Widget _buildBalanceCard(AuthUser? user) {
    final balance = user?.balance ?? 0;
    final formatted = _formatRp(balance.toInt());
    
    final phone = user?.phone ?? '081234567890';
    final formattedVa = phone.length >= 4 
        ? 'VA •••• •••• ${phone.substring(phone.length - 4)}' 
        : 'VA •••• •••• ••••';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            kHijauTua,
            kCardGreen,
            Color(0xFF384A20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kHijauTua.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              left: -40,
              top: -40,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Color(0xFFE8F0D8),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Total Simpanan',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFFFFFFFF).withValues(alpha: 0.8),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      _buildGoldChip(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: Text(
                            _balanceVisible ? formatted : 'Rp ••••••••',
                            key: ValueKey(_balanceVisible ? formatted : 'hidden'),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: kPutih,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _balanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: kPutih,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedVa,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFFFFFFF).withValues(alpha: 0.7),
                          fontFamily: 'monospace',
                          letterSpacing: 0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: phone));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nomor Virtual Account disalin'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'SALIN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFD700).withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.copy_rounded,
                              color: const Color(0xFFFFD700).withValues(alpha: 0.9),
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRp(int value) {
    final s = value.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // ── Fin stats ─────────────────────────────────────────────────────────────
  Widget _buildFinStats(AuthUser? user, LoanModel? activeLoan) {
    final loanAmount = activeLoan != null && activeLoan.status != 'PENDING'
        ? (activeLoan.approvedAmount ?? activeLoan.amount)
        : 0.0;
    
    const maxLimit = 50000000.0; // Rp 50 Juta
    final availableLimit = (maxLimit - loanAmount).clamp(0.0, maxLimit);

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: kPutih,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8F0D8), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F0D8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        color: kHijauTua,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Limit Kredit AI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  formatter.format(availableLimit),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kHijauTua,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: kPutih,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF9EAE8), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9EAE8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.assignment_late_outlined,
                        color: Color(0xFFCC4444),
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Tagihan Aktif',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  formatter.format(loanAmount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCC4444),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Quick actions ─────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.savings_outlined, 'label': 'Simpan\nDana'},
      {'icon': Icons.description_outlined, 'label': 'Ajukan\nPinjaman'},
      {'icon': Icons.swap_horiz_rounded, 'label': 'Transfer'},
      {'icon': Icons.history_rounded, 'label': 'Riwayat'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: actions.map((a) {
        final label = a['label'] as String;
        return _QuickAction(
          icon: a['icon'] as IconData,
          label: label,
          onTap: switch (label) {
            'Simpan\nDana' => () => widget.onSwitchTab?.call(1),
            'Ajukan\nPinjaman' => () => Navigator.pushNamed(
              context,
              RouteNames.pengajuan,
            ),
            'Transfer' => () => Navigator.pushNamed(
              context,
              RouteNames.transfer,
            ),
            _ => null,
          },
        );
      }).toList(),
    );
  }

  // ── Pembayaran Section ────────────────────────────────────────────────────
  Widget _buildPembayaranSection(LoanModel? activeLoan) {
    if (activeLoan == null) {
      return const SizedBox.shrink(); // Hide if no loan
    }

    final isPending = activeLoan.status == 'PENDING';
    final loanAmount = activeLoan.approvedAmount ?? activeLoan.amount;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final statusColor = switch (activeLoan.status) {
      'ACTIVE' => const Color(0xFF2E7D32),
      'APPROVED' => const Color(0xFF1565C0),
      'PENDING' => const Color(0xFFEF6C00),
      _ => const Color(0xFF424242),
    };

    final statusBgColor = switch (activeLoan.status) {
      'ACTIVE' => const Color(0xFFE8F5E9),
      'APPROVED' => const Color(0xFFE3F2FD),
      'PENDING' => const Color(0xFFFFF3E0),
      _ => const Color(0xFFEEEEEE),
    };

    final statusLabel = switch (activeLoan.status) {
      'ACTIVE' => 'Aktif',
      'APPROVED' => 'Disetujui',
      'PENDING' => 'Menunggu',
      _ => activeLoan.status,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tagihan Saya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
                letterSpacing: 0.2,
              ),
            ),
            GestureDetector(
              onTap: () {
                widget.onSwitchTab?.call(2);
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: kHijauTua,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE8F0D8).withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pinjaman ${activeLoan.type == 'MURABAHAH' ? 'Murabahah' : 'Qardhul Hasan'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPending
                              ? 'Menunggu persetujuan admin'
                              : 'Tenor: ${activeLoan.approvedTenor ?? activeLoan.tenor} bulan',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 14),
              _finRow(
                'Total Pinjaman',
                formatter.format(loanAmount),
                valueColor: const Color(0xFF1A1A1A),
              ),
              if (!isPending) ...[
                const SizedBox(height: 8),
                _finRow(
                  'Sudah Dibayar',
                  'Rp 0',
                  valueColor: const Color(0xFF1A1A1A),
                ),
                const SizedBox(height: 8),
                _finRow(
                  'Sisa Pembayaran',
                  formatter.format(loanAmount),
                  valueColor: const Color(0xFFCC4444),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 0.0), // 0% paid
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF5F5F5),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        kHijauTua,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.pembayaranDetail,
                      arguments: PembayaranDetailArgs(loan: activeLoan),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kHijauTua,
                      foregroundColor: kPutih,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Bayar Cicilan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _finRow(String label, String value, {required Color valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ─── Quick Action Widget ──────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickAction({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: kPutih,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE8F0D8).withValues(alpha: 0.8),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: kHijauTua, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
