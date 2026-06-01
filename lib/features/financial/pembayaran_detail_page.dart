import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/app_widgets.dart';
import 'data/models/loan_model.dart';

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
  final Set<int> _paidIndices = {};

  late final AnimationController _entranceCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;

  late final List<Map<String, dynamic>> _cicilan;

  @override
  void initState() {
    super.initState();

    // Generate _cicilan dynamically based on loan or fallback safely
    _cicilan = [];
    final loan = widget.loan;
    final totalAmount = loan?.approvedAmount ?? loan?.amount;
    final totalTenor = loan?.approvedTenor ?? loan?.tenor;

    if (loan != null &&
        totalAmount != null &&
        totalTenor != null &&
        totalTenor > 0) {
      final monthlyAmount = totalAmount / totalTenor;
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      final formattedAmount = formatter.format(monthlyAmount);

      for (int i = 1; i <= totalTenor; i++) {
        final dueDate = loan.createdAt.add(Duration(days: 30 * i));
        _cicilan.add({
          'no': i,
          'date': DateFormat('dd MMM yyyy', 'id_ID').format(dueDate),
          'month': DateFormat('MMMM yyyy', 'id_ID').format(dueDate),
          'amount': formattedAmount,
          'status': i == 1 ? 'PENDING' : null,
          'statusColor': i == 1 ? const Color(0xFFF5A623) : null,
          'statusBg': i == 1 ? const Color(0xFFFFF3E0) : null,
          'locked': i > 1,
        });
      }
    }

    if (_cicilan.isEmpty) {
      // Fallback dummy data if no loan details exist
      _cicilan = [
        {
          'no': 1,
          'date': '15 Nov 2026',
          'month': 'November 2026',
          'amount': 'Rp 180.000',
          'status': 'PENDING',
          'statusColor': const Color(0xFFF5A623),
          'statusBg': const Color(0xFFFFF3E0),
          'locked': false,
        },
        {
          'no': 2,
          'date': '15 Des 2026',
          'month': 'Desember 2026',
          'amount': 'Rp 180.000',
          'status': 'DUE',
          'statusColor': const Color(0xFFCC3333),
          'statusBg': const Color(0xFFFFEEEE),
          'locked': false,
        },
        {
          'no': 3,
          'date': '11 Jan 2027',
          'month': 'Januari 2027',
          'amount': 'Rp 180.000',
          'status': null,
          'statusColor': null,
          'statusBg': null,
          'locked': true,
        },
      ];
    }

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

  // Row i is selectable if: not locked, not already paid, and all earlier
  // non-locked rows have been paid (sequential enforcement).
  bool _isSelectable(int i) {
    if (_cicilan[i]['locked'] as bool) return false;
    if (_paidIndices.contains(i)) return false;
    for (int j = 0; j < i; j++) {
      if (!(_cicilan[j]['locked'] as bool) && !_paidIndices.contains(j)) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      body: Stack(
        children: [
          const AmbientOrbBackground(),

          SafeArea(
            child: Column(
              children: [
                // ── App Bar ───────────────────────────────────────────
                _buildAppBar(context),

                // ── Info card + warning banner (fixed, animated in) ──────────────
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        children: [
                          _buildInfoCard(),
                          const SizedBox(height: 12),
                          _buildWarningBanner(),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── TabBar (fixed/sticky) ─────────────────────────────────────────
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
                        borderSide: BorderSide(color: kHijauTua, width: 2.5),
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

                // ── Scrollable tab content (fills remaining space) ────────────────
                Expanded(
                  child: FadeTransition(
                    opacity: _bodyFade,
                    child: TabBarView(
                      controller: _tabCtrl,
                      children: [
                        _buildJadwalCicilanTab(),
                        _buildFiturPembayaranTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
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

  // ── Info card (DB Synchronized) ───────────────────────────────────────────
  Widget _buildInfoCard() {
    final loan = widget.loan;
    final String reqNum = loan?.requestNumber ?? '#AKD100';
    final String typeLabel = loan?.type == 'QARDHUL_HASAN'
        ? 'Qardhul Hasan - Kebajikan'
        : 'Murabahah - Jual Beli';
    final int totalTenor = loan?.approvedTenor ?? loan?.tenor ?? 6;
    final double totalAmount = loan?.approvedAmount ?? loan?.amount ?? 1080000;
    final double monthlyAmount = totalTenor > 0
        ? (totalAmount / totalTenor)
        : 0;

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final formattedTotal = formatter.format(totalAmount);
    final formattedMonthly = formatter.format(monthlyAmount);

    final int remainingCicilan = totalTenor - _paidIndices.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kPutih,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nomor Pembiayaan',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF888888),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            reqNum,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2E14),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            typeLabel,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
          Text(
            '$totalTenor Bulan Cicilan',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          _infoRow(
            'Total Pembiayaan',
            formattedTotal,
            valueColor: kHijauTua,
            valueBold: true,
          ),
          const SizedBox(height: 10),
          _infoRow(
            'Cicilan per Bulan',
            formattedMonthly,
            valueColor: const Color(0xFF1A1A1A),
          ),
          const SizedBox(height: 10),
          _infoRow(
            'Sisa Cicilan',
            '$remainingCicilan Bulan',
            valueColor: const Color(0xFFE07B00),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    required Color valueColor,
    bool valueBold = false,
  }) {
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
            fontSize: 13.5,
            fontWeight: valueBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ── Warning banner ────────────────────────────────────────────────────────
  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE3D0), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFE07B00),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Pembayaran Tertunda',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCC5500),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Harap segera selesaikan cicilan Anda yang tertunda untuk menghindari denda.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF885500),
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Jadwal Cicilan — radio selection, sequential lock ──────────────
  Widget _buildJadwalCicilanTab() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _cicilan.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final c = _cicilan[i];
        final bool hardLocked = c['locked'] as bool;
        final bool paid = _paidIndices.contains(i);
        final bool selectable = _isSelectable(i);
        final bool selected = _selectedCicilan == i;
        final double opacity = (paid || !selectable) ? 0.55 : 1.0;

        return Opacity(
          opacity: opacity,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: kPutih,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? kHijauTua : Colors.transparent,
                width: selected ? 1.8 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? kHijauTua.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: selectable
                    ? () =>
                          setState(() => _selectedCicilan = selected ? null : i)
                    : null,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Row(
                    children: [
                      // Radio check box or paid check indicator
                      if (paid)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: kHijauTua,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: kPutih,
                            size: 14,
                          ),
                        )
                      else
                        IgnorePointer(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: Center(
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? kHijauTua
                                        : const Color(0xFFBDBDBD),
                                    width: 2,
                                  ),
                                ),
                                child: selected
                                    ? Center(
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: kHijauTua,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(width: 12),

                      // Monthly index bubble
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: paid
                              ? kHijauTua.withValues(alpha: 0.1)
                              : selected
                              ? const Color(0xFFE8F0D8)
                              : const Color(0xFFF5F7F2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${c['no']}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: paid
                                  ? kPutih
                                  : selected
                                  ? kHijauTua
                                  : const Color(0xFF666666),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Date + label
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['date'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: hardLocked
                                    ? const Color(0xFF999999)
                                    : const Color(0xFF1D2E14),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              paid
                                  ? 'Sudah Dibayar'
                                  : hardLocked
                                  ? 'Belum Jatuh Tempo'
                                  : 'Jatuh Tempo',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: paid
                                    ? kHijauTua
                                    : hardLocked
                                    ? const Color(0xFF999999)
                                    : const Color(0xFFCC5500),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Amount + status badge
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            c['amount'] as String,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: hardLocked
                                  ? const Color(0xFF999999)
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (paid)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'LUNAS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            )
                          else if (c['status'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: c['statusBg'] as Color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                c['status'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: c['statusColor'] as Color,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Tab 2: Fitur Pembayaran ───────────────────────────────────────────────
  Widget _buildFiturPembayaranTab() {
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
                'BCA, Mandiri, BNI, BRI',
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
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  // ── Fixed bottom CTA — label reflects current selection ──────────────────
  Widget _buildBottomButton() {
    final bool canPay = _selectedCicilan != null;
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
          onPressed: canPay ? _showKonfirmasiSheet : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: kHijauTua,
            disabledBackgroundColor: const Color(0xFFB0BDA0),
            foregroundColor: kPutih,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            canPay
                ? 'Bayar Cicilan ${_cicilan[_selectedCicilan!]['month']}'
                : 'Pilih Cicilan untuk Dibayar',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showKonfirmasiSheet() {
    if (_selectedCicilan == null) return;
    final c = _cicilan[_selectedCicilan!];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _KonfirmasiSheet(
        month: c['month'] as String,
        amount: c['amount'] as String,
        onBayar: () {
          Navigator.pop(context);
          setState(() {
            _paidIndices.add(_selectedCicilan!);
            _selectedCicilan = null;
          });
        },
      ),
    );
  }
}

// ─── Konfirmasi Pembayaran Bottom Sheet ───────────────────────────────────────
class _KonfirmasiSheet extends StatelessWidget {
  final String month;
  final String amount;
  final VoidCallback onBayar;

  const _KonfirmasiSheet({
    required this.month,
    required this.amount,
    required this.onBayar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kPutih,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 24),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const Text(
            'Konfirmasi Pembayaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2E14),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 20),
          _konfRow('Cicilan Bulan', month),
          const SizedBox(height: 12),
          _konfRow('Total Pembayaran', amount, valueColor: kHijauTua),
          const SizedBox(height: 12),
          _konfRow('Metode Pembayaran', 'Transfer Bank'),
          const SizedBox(height: 28),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFDDDDDD),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF777777),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onBayar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kHijauTua,
                    foregroundColor: kPutih,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Bayar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _konfRow(String label, String value, {Color? valueColor}) {
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
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF1D2E14),
          ),
        ),
      ],
    );
  }
}
