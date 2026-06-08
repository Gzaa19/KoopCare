import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koopcare/core/di/service_locator.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/widgets/app_widgets.dart';
import 'package:koopcare/features/loan/data/models/loan_model.dart';
import 'package:koopcare/features/loan/data/models/installment_model.dart';
import '../bloc/installment/installment_bloc.dart';
import '../bloc/installment/installment_event.dart';
import '../bloc/installment/installment_state.dart';
import '../widgets/loan_info_card.dart';
import '../widgets/warning_banner.dart';
import '../widgets/cicilan_item_tile.dart';
import '../widgets/konfirmasi_pembayaran_sheet.dart';
import 'package:koopcare/features/wallet/presentation/pages/midtrans_webview_page.dart';

class PembayaranDetailPage extends StatefulWidget {
  final LoanModel? loan;
  const PembayaranDetailPage({super.key, this.loan});

  @override
  State<PembayaranDetailPage> createState() => _PembayaranDetailPageState();
}

class _PembayaranDetailPageState extends State<PembayaranDetailPage>
    with TickerProviderStateMixin {
  late final TabController _tabCtrl;
  bool _autoDebet = false;
  int? _selectedCicilan;

  late final AnimationController _entranceCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
          ),
        );
    _bodyFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.25, 0.85, curve: Curves.easeOut),
      ),
    );
    _bodySlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _entranceCtrl.forward(),
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loanId = widget.loan?.id;
    if (loanId == null) {
      return const Scaffold(
        backgroundColor: kScaffold,
        body: Center(child: Text('Tidak ada data pinjaman')),
      );
    }

    return BlocProvider<InstallmentBloc>(
      create: (_) => getIt<InstallmentBloc>()..add(FetchInstallments(loanId)),
      child: BlocConsumer<InstallmentBloc, InstallmentState>(
        listener: (context, state) async {
          if (state is InstallmentPaidSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cicilan berhasil dibayar')),
            );
            // Clear selection after a successful payment.
            setState(() => _selectedCicilan = null);
            // NOTE: refresh the beranda/simpanan balance here via your
            // AuthBloc, e.g.:
            // context.read<AuthBloc>().add(const AuthProfileRefreshRequested());
          } else if (state is InstallmentError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is InstallmentMidtransReady) {
            // The listener's context is the BlocConsumer's context (below the
            // provider), so reading the bloc here is safe.
            final paid = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) =>
                    MidtransWebViewPage(redirectUrl: state.redirectUrl),
              ),
            );
            if (paid == true && context.mounted) {
              context.read<InstallmentBloc>().add(
                PollInstallmentPayment(state.loanId, state.installmentId),
              );
            }
          } else if (state is InstallmentProcessing) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Pembayaran sedang diproses. Status akan diperbarui sebentar lagi.',
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          // Capture the bloc from the builder's context (below the provider) so
          // child methods can dispatch events without doing their own
          // context.read — which would resolve to the State's context, ABOVE
          // the provider, and crash.
          final bloc = context.read<InstallmentBloc>();

          final List<InstallmentModel> installments = switch (state) {
            InstallmentLoaded(:final installments) => installments,
            InstallmentPaying(:final installments) => installments,
            InstallmentPaidSuccess(:final installments) => installments,
            InstallmentProcessing(:final installments) => installments,
            InstallmentMidtransReady(:final installments) => installments,
            InstallmentError(:final installments) => installments,
            _ => const <InstallmentModel>[],
          };

          final bool isLoading = state is InstallmentLoading;
          final bool isPaying = state is InstallmentPaying;
          final int paidCount = installments.where((i) => i.isPaid).length;

          return Scaffold(
            backgroundColor: kScaffold,
            body: Stack(
              children: [
                const AmbientOrbBackground(),
                SafeArea(
                  child: Column(
                    children: [
                      _buildAppBar(context),
                      FadeTransition(
                        opacity: _headerFade,
                        child: SlideTransition(
                          position: _headerSlide,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Column(
                              children: [
                                LoanInfoCard(
                                  loan: widget.loan,
                                  paidIndicesCount: paidCount,
                                ),
                                const SizedBox(height: 12),
                                const WarningBanner(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeTransition(
                        opacity: _bodyFade,
                        child: SlideTransition(
                          position: _bodySlide,
                          child: TabBar(
                            controller: _tabCtrl,
                            dividerColor: Colors.transparent,
                            labelColor: kHijauTua,
                            unselectedLabelColor: const Color(0xFF888888),
                            indicator: const UnderlineTabIndicator(
                              borderSide: BorderSide(
                                color: kHijauTua,
                                width: 2.5,
                              ),
                              insets: EdgeInsets.symmetric(horizontal: 24),
                            ),
                            labelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.1,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            tabs: const [
                              Tab(text: 'Jadwal Cicilan'),
                              Tab(text: 'Fitur Pembayaran'),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: FadeTransition(
                          opacity: _bodyFade,
                          child: TabBarView(
                            controller: _tabCtrl,
                            children: [
                              _buildJadwalCicilanTab(installments, isLoading),
                              _buildFiturPembayaranTab(bloc, installments),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _buildBottomButton(
              context,
              installments,
              isPaying,
            ),
          );
        },
      ),
    );
  }

  // ── Custom App Bar ────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 40,
              height: 40,
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
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: kHijauTua,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Detail Pembayaran',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2E14),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Jadwal Cicilan — radio selection, sequential lock ──────────────
  Widget _buildJadwalCicilanTab(
    List<InstallmentModel> installments,
    bool isLoading,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: kHijauTua));
    }
    if (installments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Belum ada jadwal cicilan untuk pinjaman ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF888888),
            ),
          ),
        ),
      );
    }

    final list = List.generate(
      installments.length,
      (i) => _mapInstallment(installments[i], i),
    );

    // Row i is selectable if it is not paid AND every earlier row is paid
    // (strict sequential rule, matching the backend).
    bool isSelectableIndex(int i) {
      if (list[i]['paid'] == true) return false;
      for (int j = 0; j < i; j++) {
        if (list[j]['paid'] != true) return false;
      }
      return true;
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final c = list[i];
        return CicilanItemTile(
          cicilan: c,
          paid: c['paid'] == true,
          selectable: isSelectableIndex(i),
          selected: _selectedCicilan == i,
          onTap: isSelectableIndex(i)
              ? () => setState(
                  () => _selectedCicilan = (_selectedCicilan == i) ? null : i,
                )
              : null,
        );
      },
    );
  }

  Map<String, dynamic> _mapInstallment(InstallmentModel it, int index) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return {
      'no': index + 1,
      'date': DateFormat('dd MMM yyyy', 'id_ID').format(it.dueDate),
      'month': DateFormat('MMMM yyyy', 'id_ID').format(it.dueDate),
      'amount': formatter.format(it.amount),
      'paid': it.isPaid,
      // CicilanItemTile reads cicilan['locked'] as a non-nullable bool, so this
      // key must always be present. Sequencing is enforced by isSelectableIndex
      // (and the backend), so the visual "locked" flag stays false here.
      'locked': false,
      'id': it.id,
    };
  }

  // ── Tab 2: Fitur Pembayaran ───────────────────────────────────────────────
  // Receives the bloc captured from the builder's (provider-scoped) context.
  Widget _buildFiturPembayaranTab(
    InstallmentBloc bloc,
    List<InstallmentModel> installments,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: kPutih,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Autodebet Saldo Top Up',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2E14),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Aktifkan untuk pembayaran otomatis dari saldo Top Up Anda setiap jatuh tempo.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF777777),
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: _autoDebet,
                  onChanged: (v) => setState(() => _autoDebet = v),
                  activeThumbColor: kHijauTua,
                  activeTrackColor: const Color(
                    0xFF8FA84A,
                  ).withValues(alpha: 0.3),
                  inactiveTrackColor: const Color(0xFFDDDDDD),
                  inactiveThumbColor: kPutih,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Metode Pembayaran Lainnya',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2E14),
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: kPutih,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F0D8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_outlined,
                  color: kHijauTua,
                  size: 20,
                ),
              ),
              title: const Text(
                'Transfer Bank',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              subtitle: const Text(
                'BCA, Mandiri, BNI, BRI (via Midtrans)',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF777777),
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF888888),
              ),
              // Phase 2 (Midtrans cicilan payment) wiring. Uses the bloc passed
              // in from the builder — NOT context.read, which would fail here.
              onTap: () {
                if (_selectedCicilan == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Pilih cicilan di tab "Jadwal Cicilan" terlebih dahulu',
                      ),
                    ),
                  );
                  return;
                }
                if (_selectedCicilan! >= installments.length) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cicilan tidak ditemukan')),
                  );
                  return;
                }
                final inst = installments[_selectedCicilan!];
                final loanId = widget.loan?.id;
                if (loanId == null) return;
                bloc.add(PayInstallmentViaMidtrans(loanId, inst.id));
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Fixed bottom CTA — label reflects current selection ──────────────────
  Widget _buildBottomButton(
    BuildContext context,
    List<InstallmentModel> installments,
    bool isPaying,
  ) {
    final bool hasSelection =
        _selectedCicilan != null && _selectedCicilan! < installments.length;
    final bool canPay = hasSelection && !isPaying;

    String label = 'Pilih Cicilan untuk Dibayar';
    if (hasSelection) {
      final c = _mapInstallment(
        installments[_selectedCicilan!],
        _selectedCicilan!,
      );
      label = 'Bayar Cicilan ${c['month'] ?? ''}';
    }

    return Container(
      color: kPutih,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: canPay
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
          onPressed: canPay
              ? () => _showKonfirmasiSheet(context, installments)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: kHijauTua,
            disabledBackgroundColor: const Color(0xFFB0BDA0),
            foregroundColor: kPutih,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isPaying
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: kPutih,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  void _showKonfirmasiSheet(
    BuildContext context,
    List<InstallmentModel> installments,
  ) {
    if (_selectedCicilan == null || _selectedCicilan! >= installments.length) {
      return;
    }
    // Capture the bloc from the current (provider-scoped) context BEFORE
    // opening the sheet, since the sheet's builder context is outside it.
    final bloc = context.read<InstallmentBloc>();
    final loanId = widget.loan?.id;
    final c = _mapInstallment(
      installments[_selectedCicilan!],
      _selectedCicilan!,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KonfirmasiPembayaranSheet(
        month: c['month'] as String,
        amount: c['amount'] as String,
        onBayar: () {
          Navigator.pop(context);
          final installmentId = c['id'];
          if (loanId != null && installmentId != null) {
            bloc.add(PayInstallmentFromBalance(loanId, installmentId as int));
          }
        },
      ),
    );
  }
}