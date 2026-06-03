import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../financial/data/models/loan_model.dart';
import '../financial/presentation/bloc/loan/loan_bloc.dart';
import '../financial/presentation/bloc/loan/loan_event.dart';
import '../financial/presentation/bloc/loan/loan_state.dart';
import '../../core/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../core/router/route_args.dart';
import '../../core/router/route_names.dart';
import '../../core/widgets/dashed_border_painter.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../auth/presentation/bloc/auth_event.dart';
import '../auth/presentation/bloc/auth_state.dart';
import '../auth/domain/entities/auth_user.dart';
import '../../core/widgets/app_widgets.dart';

class SimpananDanaPage extends StatefulWidget {
  const SimpananDanaPage({super.key});

  @override
  State<SimpananDanaPage> createState() => _SimpananDanaPageState();
}

class _SimpananDanaPageState extends State<SimpananDanaPage>
    with SingleTickerProviderStateMixin {
  bool _balanceVisible = true;
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

  String _formatRp(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
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
                              _buildAppBar(),
                              const SizedBox(height: 20),
                              _buildUserRow(name),
                              const SizedBox(height: 20),
                              _buildWalletCard(balance),
                              const SizedBox(height: 28),
                              _buildSectionTitle("Aktivitas Pembiayaan Anda"),
                              const SizedBox(height: 12),
                              _buildLoanStatusSection(activeLoan, user),
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

  Widget _buildAppBar() {
    return const Text(
      'Simpanan Dana',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1D2E14),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildUserRow(String name) {
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kPutih,
            border: Border.all(color: kHijauTua.withValues(alpha: 0.15), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              firstLetter,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kHijauTua,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2E14),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: kHijauTua.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Anggota Aktif',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: kHijauTua,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletCard(double balance) {
    final formatted = _formatRp(balance);
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
                          const SizedBox(width: 8),
                          Text(
                            'Saldo Top Up Utama',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFFFFFFFF).withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                        child: Icon(
                          _balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 18,
                          color: const Color(0xFFE8F0D8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Text(
                      _balanceVisible ? formatted : 'Rp ••••••••',
                      key: ValueKey(_balanceVisible ? formatted : 'hidden'),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: kPutih,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            RouteNames.topup,
                          ),
                          icon: const Icon(Icons.add_rounded, size: 16, color: kHijauTua),
                          label: const Text(
                            'Top Up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: kHijauTua,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPutih,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            RouteNames.transfer,
                          ),
                          icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 18, color: kPutih),
                          label: const Text(
                            'Tarik',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: kPutih,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: kPutih, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1D2E14),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildLoanStatusSection(LoanModel? loan, AuthUser? user) {
    if (loan == null) {
      return _buildNoLoanCard(user);
    }

    final isPending = loan.status == 'PENDING';
    final isApproved = loan.status == 'APPROVED';
    final isActive = loan.status == 'ACTIVE';

    Color statusColor = const Color(0xFF888888);
    Color statusBgColor = const Color(0xFFEEEEEE);
    String statusLabel = loan.status;

    if (isPending) {
      statusColor = Colors.orange.shade700;
      statusBgColor = Colors.orange.shade50;
      statusLabel = "Menunggu Persetujuan";
    } else if (isApproved) {
      statusColor = Colors.blue.shade700;
      statusBgColor = Colors.blue.shade50;
      statusLabel = "Pinjaman Disetujui";
    } else if (isActive) {
      statusColor = Colors.green.shade700;
      statusBgColor = Colors.green.shade50;
      statusLabel = "Pembiayaan Aktif";
    }

    final amountToDisplay = loan.approvedAmount ?? loan.amount;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kPutih,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8F0D8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              Text(
                loan.type == 'MURABAHAH' ? 'Syarik Murabahah' : 'Qardhul Hasan',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: kHijauTua,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Total Kewajiban Pinjaman",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatRp(amountToDisplay),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2E14),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Nomor Kontrak: #${loan.requestNumber.substring(0, (loan.requestNumber.length > 12 ? 12 : loan.requestNumber.length))}",
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 16),
          if (isPending)
            Text(
              "Pengajuan pinjaman Anda saat ini sedang dalam proses review oleh admin koperasi. Mohon tunggu proses analisis kelayakan kredit.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            )
          else if (isApproved)
            Text(
              "Pinjaman Anda telah disetujui! Dana pembiayaan akan dicairkan ke saldo Top Up Utama Anda dalam waktu dekat.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            )
          else if (isActive)
            Text(
              "Tagihan Anda saat ini berjalan aktif. Silakan lakukan pembayaran angsuran tepat waktu untuk menjaga skor kelayakan pinjaman Anda.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (isActive || isApproved) {
                  Navigator.pushNamed(
                    context,
                    RouteNames.pembayaranDetail,
                    arguments: PembayaranDetailArgs(loan: loan),
                  );
                } else {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Pengajuan pinjaman masih menunggu review admin."),
                      backgroundColor: kHijauTua,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kHijauTua,
                foregroundColor: kPutih,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                isActive ? 'Detail Pembayaran & Cicilan' : (isApproved ? 'Lihat Kontrak Detail' : 'Menunggu Review'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoLoanCard(AuthUser? user) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kHijauTua.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_chart_rounded,
                  color: kHijauTua,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ajukan Pembiayaan Syariah',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1D2E14),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Butuh dukungan dana modal usaha secara syariah dengan margin kompetitif? Dapatkan pembiayaan amanah sekarang.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (user?.status != 'ACTIVE') {
                      showAccountInactiveDialog(context);
                    } else {
                      Navigator.pushNamed(
                        context,
                        RouteNames.pengajuan,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kHijauTua,
                    foregroundColor: kPutih,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ajukan Sekarang',
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
        Positioned.fill(
          child: CustomPaint(
            painter: DashedBorderPainter(
              color: const Color(0xFFB0BDA0),
              radius: 20,
              dashWidth: 6,
              dashSpace: 4,
              strokeWidth: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
