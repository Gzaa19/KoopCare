import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class PembayaranDetailPage extends StatefulWidget {
  const PembayaranDetailPage({super.key});

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

    _tabCtrl = TabController(length: 2, vsync: this);

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    ));
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    ));
    _bodyFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOut),
    ));
    _bodySlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
    ));

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _entranceCtrl.forward());
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
      body: Column(
        children: [
          // ── Olive green app bar (always fixed) ───────────────────────────
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // ── TabBar (fixed/sticky) ─────────────────────────────────────────
          FadeTransition(
            opacity: _bodyFade,
            child: SlideTransition(
              position: _bodySlide,
              child: Container(
                color: kPutih,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabCtrl,
                    labelColor: kHijauTua,
                    unselectedLabelColor: const Color(0xFF888888),
                    indicatorColor: kHijauTua,
                    indicatorWeight: 2.5,
                    labelStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w400),
                    tabs: const [
                      Tab(text: 'Jadwal Cicilan'),
                      Tab(text: 'Fitur Pembayaran'),
                    ],
                  ),
                ),
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
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // ── Olive green app bar ───────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: kHijauTua,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: kPutih, size: 20),
            ),
            const Expanded(
              child: Text(
                'Detail Pembiayaan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kPutih,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kPutih,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nomor Pembiayaan',
              style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
          const SizedBox(height: 4),
          const Text(
            '#AKD100',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          const Text('Murabahah - Jual Beli',
              style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
          const Text('6 Bulan Cicilan',
              style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 14),
          _infoRow('Total Pembiayaan', 'Rp 1.080.000',
              valueColor: kHijauTua, valueBold: true),
          const SizedBox(height: 8),
          _infoRow('Cicilan per Bulan', 'Rp 180.000',
              valueColor: const Color(0xFF1A1A1A)),
          const SizedBox(height: 8),
          _infoRow('Sisa Cicilan', '6 Bulan',
              valueColor: const Color(0xFFE07B00)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value,
      {required Color valueColor, bool valueBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCC99), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.warning_amber_rounded,
              color: Color(0xFFE07B00), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pembayaran Tertunda',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCC5500),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Anda memiliki 2 cicilan yang sudah jatuh tempo',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF885500),
                    height: 1.4,
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: _cicilan.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
      itemBuilder: (_, i) {
        final c         = _cicilan[i];
        final bool hardLocked  = c['locked'] as bool;
        final bool paid        = _paidIndices.contains(i);
        final bool selectable  = _isSelectable(i);
        final bool selected    = _selectedCicilan == i;
        // Dim paid rows and any row that cannot currently be selected.
        final double opacity   = (paid || !selectable) ? 0.45 : 1.0;

        return Opacity(
          opacity: opacity,
          child: InkWell(
            onTap: selectable
                ? () => setState(
                    () => _selectedCicilan = selected ? null : i)
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  // Radio indicator — IgnorePointer so the row InkWell owns the tap
                  if (paid)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: kHijauTua,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: kPutih, size: 14),
                    )
                  else
                    IgnorePointer(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Radio<int>(
                          value: i,
                          groupValue: _selectedCicilan,
                          onChanged: (_) {},
                          activeColor: kHijauTua,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),

                  const SizedBox(width: 12),

                  // Number circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: paid
                          ? kHijauTua
                          : selected
                              ? const Color(0xFFE8F0D8)
                              : hardLocked
                                  ? const Color(0xFFEEEEEE)
                                  : const Color(0xFFEEEEEE),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${c['no']}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: paid ? kPutih : kHijauTua,
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
                            fontWeight: FontWeight.w600,
                            color: hardLocked
                                ? const Color(0xFF999999)
                                : const Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          paid
                              ? 'Sudah Dibayar'
                              : hardLocked
                                  ? 'Belum Jatuh Tempo'
                                  : 'Jatuh Tempo',
                          style: TextStyle(
                            fontSize: 11,
                            color: paid
                                ? kHijauTua
                                : const Color(0xFF999999),
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (paid)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
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
                              horizontal: 8, vertical: 3),
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
        );
      },
    );
  }

  // ── Tab 2: Fitur Pembayaran ───────────────────────────────────────────────
  Widget _buildFiturPembayaranTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: kPutih,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Aktifkan untuk pembayaran otomatis dari saldo Top Up Anda setiap jatuh tempo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Switch(
                  value: _autoDebet,
                  onChanged: (v) => setState(() => _autoDebet = v),
                  activeThumbColor: kHijauTua,
                  activeTrackColor: const Color(0xFF8FA84A),
                  inactiveTrackColor: const Color(0xFFDDDDDD),
                  inactiveThumbColor: kPutih,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Metode Pembayaran Lainnya',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: kPutih,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0D8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_outlined,
                    color: kHijauTua, size: 20),
              ),
              title: const Text(
                'Transfer Bank',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              subtitle: const Text(
                'BCA, Mandiri, BNI, BRI',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Color(0xFF888888)),
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: canPay ? _showKonfirmasiSheet : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: kHijauTua,
            disabledBackgroundColor: const Color(0xFFB0BDA0),
            foregroundColor: kPutih,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Konfirmasi Pembayaran',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Color(0xFFCCCCCC), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF555555),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Bayar',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF666666))),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}
