import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

// ─── FAQ data model ───────────────────────────────────────────────────────────
class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}

const List<_FaqItem> kFaqData = [
  _FaqItem(
    'Apa itu KoopCare',
    'KoopCare adalah aplikasi digital resmi dari koperasi kami yang memudahkan '
    'anggota untuk melakukan transaksi, mengajukan peminjaman, memantau simpanan, '
    'dan mengakses layanan koperasi secara online dan kapan saja.',
  ),
  _FaqItem(
    'Apa Saja layanan KoopCare',
    'KoopCare menyediakan berbagai jenis layanan seperti:\n'
    '• Transaksi digital — Top Up, Transfer, Tarik dana\n'
    '• Peminjaman — Pengajuan pembiayaan Murabahah & Qardhul Hasan\n'
    '• Riwayat transaksi — Pantau semua aktivitas akun Anda\n'
    '• Notifikasi — Pemberitahuan jatuh tempo dan status pengajuan',
  ),
  _FaqItem(
    'Sistem Peminjaman',
    'Sistem peminjaman pada KoopCare menggunakan sistem AI yang dikembangkan '
    'di mana AI akan memberikan nilai selisih dalam jangka waktu 1–24 jam serta '
    'memberikan nilai selisih ai berdasarkan kepada admin untuk menerima dan '
    'menolak pemberian kepada anggota yang mengajukan permohonan tersebut.',
  ),
  _FaqItem(
    'Proses pencairan dana',
    'Proses pencairan dana akan diproses dalam jangka waktu 1–3 hari kerja '
    'setelah pengajuan disetujui oleh admin. Dana akan ditransfer langsung ke '
    'rekening bank yang telah Anda daftarkan pada data top up.',
  ),
  _FaqItem(
    'Lupa Password',
    'Jika pengguna KoopCare melupakan kata sandi, lakukan pemulihan melalui '
    'halaman login dengan langkah berikut:\n'
    '1. Tap tombol "Lupa Password" di halaman login\n'
    '2. Masukkan nomor WhatsApp/NIK terdaftar\n'
    '3. Verifikasi identitas melalui OTP (kode 6 digit)\n'
    '4. Buat kata sandi baru\n'
    '5. Serta mengaktifkan keamanan 2FA, fingerprint, facial ID',
  ),
  _FaqItem(
    'Apakah Data Saya Aman?',
    'KoopCare menggunakan enkripsi tingkat tinggi (AES-256) dan server bank '
    'lokal (AKS-256) dan mengikuti standar keamanan ISO 27001. Data anggota '
    'dilindungi secara akurat dengan keamanan 2FA, fingerprint, facial di '
    'setiap transaksi untuk memastikan keamanan data Anda selalu terjaga.',
  ),
  _FaqItem(
    'Bagaimana Sistem Bekerja',
    'KoopCare bekerja dengan cara yang sederhana namun canggih untuk kebutuhan '
    'anggota koperasi. Menggunakan AI untuk setiap kondisi dan kebutuhan data '
    'anggota secara akurat.\n\n'
    'Setelah Anda mendaftarkan diri sebagai anggota koperasi, sistem akan '
    'menganalisis informasi Anda dan memberikan rekomendasi layanan yang sesuai. '
    'Semua proses layanan yang berjalan cukup singkat.',
  ),
];

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  // Only one item open at a time (null = all collapsed)
  int? _openIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App bar ───────────────────────────────────────────────────
            _buildAppBar(context),

            // ── Scrollable FAQ list ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page title
                    const Center(
                      child: Text(
                        'FAQ',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FAQ accordion list
                    Container(
                      decoration: BoxDecoration(
                        color: kPutih,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        children: List.generate(kFaqData.length, (i) {
                          return _FaqTile(
                            item: kFaqData[i],
                            isOpen: _openIndex == i,
                            isLast: i == kFaqData.length - 1,
                            onTap: () => setState(() {
                              _openIndex = _openIndex == i ? null : i;
                            }),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Kembali button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.maybePop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kHijauTua,
                          foregroundColor: kPutih,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Kembali',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          // KoopCare logo
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2C),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home_rounded, color: kPutih, size: 16),
          ),
          const SizedBox(width: 8),
          const Text(
            'KoopCare',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single FAQ Accordion Tile ────────────────────────────────────────────────
class _FaqTile extends StatefulWidget {
  final _FaqItem item;
  final bool isOpen;
  final bool isLast;
  final VoidCallback onTap;

  const _FaqTile({
    required this.item,
    required this.isOpen,
    required this.isLast,
    required this.onTap,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _expandAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnim = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOutCubic,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _rotateAnim = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic),
    );

    if (widget.isOpen) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _FaqTile old) {
    super.didUpdateWidget(old);
    if (widget.isOpen != old.isOpen) {
      widget.isOpen ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Question row ─────────────────────────────────────────────────
        InkWell(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: widget.isOpen
                ? const Color(0xFFF0F5E8) // soft green when open
                : kPutih,
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.question,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: widget.isOpen
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: widget.isOpen
                          ? kHijauTua
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Rotating chevron
                RotationTransition(
                  turns: _rotateAnim,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: widget.isOpen
                        ? kHijauTua
                        : const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Animated answer panel ────────────────────────────────────────
        SizeTransition(
          sizeFactor: _expandAnim,
          axisAlignment: -1,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Container(
              width: double.infinity,
              color: kPutih,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.item.answer,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),

        // ── Divider (not on last item) ───────────────────────────────────
        if (!widget.isLast)
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}