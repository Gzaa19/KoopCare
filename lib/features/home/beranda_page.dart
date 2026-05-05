import 'package:flutter/material.dart';
import '../financial/pembayaran_detail_page.dart' hide kHijauTua, kPutih, kScaffold;
import '../financial/pengajuan_pembiayaan_page.dart' hide kProdukList, kTenorOptions;
import '../financial/tarik_tunai_page.dart' hide kHijauTua, kPutih, kScaffold, kBankOptions;

// ─── Colour tokens ────────────────────────────────────────────────────────────
const Color kHijauTua    = Color(0xFF4A5E2A);
const Color kCardGreen   = Color(0xFF556B2F);
const Color kUserCardTop = Color(0xFFDDE5C8);
const Color kAbuAbu      = Color(0xFF9E9E9E);
const Color kPutih       = Color(0xFFFFFFFF);
const Color kScaffold    = Color(0xFFF5F7F2);

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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 4 sections: appbar row, balance card, quick actions, pembayaran section
    _fades = List.generate(4, (i) {
      final s = i * 0.12;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(s, (s + 0.5).clamp(0, 1), curve: Curves.easeOut),
        ),
      );
    });

    _slides = List.generate(4, (i) {
      final s = i * 0.12;
      return Tween<Offset>(
        begin: const Offset(0, 0.22),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _ctrl,
        curve: Interval(s, (s + 0.5).clamp(0, 1), curve: Curves.easeOutCubic),
      ));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  PageRouteBuilder<void> _slideRoute(Widget page) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );

  Widget _animated(int index, Widget child) => FadeTransition(
        opacity: _fades[index],
        child: SlideTransition(position: _slides[index], child: child),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _animated(0, _buildAppBar()),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _animated(1, _buildBalanceCard()),
                    const SizedBox(height: 20),
                    _animated(2, _buildQuickActions()),
                    const SizedBox(height: 24),
                    _animated(3, _buildPembayaranSection()),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2C),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: kPutih, size: 28),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Beri Mesyanti',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Anggota Aktif',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
            ],
          ),
          const Spacer(),
          Stack(
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
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: Color(0xFF444444), size: 22),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '5',
                    style: TextStyle(
                      color: kPutih,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Total Simpanan balance card ───────────────────────────────────────────
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kPutih,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Simpanan',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w400,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                child: Icon(
                  _balanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF888888),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: Text(
              _balanceVisible ? 'Rp 5.000.000' : 'Rp ••••••••',
              key: ValueKey(_balanceVisible),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick actions ─────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.savings_outlined,      'label': 'Simpan\nDana'},
      {'icon': Icons.description_outlined,  'label': 'Ajukan\nPinjaman'},
      {'icon': Icons.swap_horiz_rounded,    'label': 'Transfer'},
      {'icon': Icons.history_rounded,       'label': 'Riwayat'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        final label = a['label'] as String;
        return _QuickAction(
          icon: a['icon'] as IconData,
          label: label,
          onTap: switch (label) {
            'Simpan\nDana' => () => widget.onSwitchTab?.call(1),
            'Ajukan\nPinjaman' => () => Navigator.push(
                  context,
                  _slideRoute(const PengajuanPembiayaanPage()),
                ),
            'Transfer' => () => Navigator.push(
                  context,
                  _slideRoute(const TransferPage()),
                ),
            _ => null,
          },
        );
      }).toList(),
    );
  }

  // ── Pembayaran Aktif section ──────────────────────────────────────────────
  Widget _buildPembayaranSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pembayaran Aktif',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 13,
                  color: kHijauTua,
                  fontWeight: FontWeight.w500,
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
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pinjaman Murabahah',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Jatuh tempo: 15 Des 2024',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0D8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Aktif',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: kHijauTua,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 14),
              _finRow('Total Pinjaman',    'Rp 10.000.000', valueColor: const Color(0xFF1A1A1A)),
              const SizedBox(height: 8),
              _finRow('Sudah Dibayar',     'Rp 5.000.000',  valueColor: const Color(0xFF1A1A1A)),
              const SizedBox(height: 8),
              _finRow('Sisa Pembayaran',   'Rp 5.000.000',  valueColor: const Color(0xFFCC4444)),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 0.5),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFEEEEEE),
                    valueColor: const AlwaysStoppedAnimation<Color>(kHijauTua),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 350),
                      pageBuilder: (_, _, _) => const PembayaranDetailPage(),
                      transitionsBuilder: (_, anim, _, child) => SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: anim,
                          curve: Curves.easeOutCubic,
                        )),
                        child: child,
                      ),
                    ),
                  ),
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
                    'Bayar Cicilan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
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
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: valueColor)),
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
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0D8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: kHijauTua, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF333333),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
