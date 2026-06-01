import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/router/route_args.dart';
import '../../core/router/route_names.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/dashed_border_painter.dart';

class PengajuanPembiayaanPage extends StatefulWidget {
  const PengajuanPembiayaanPage({super.key});

  @override
  State<PengajuanPembiayaanPage> createState() =>
      _PengajuanPembiayaanPageState();
}

class _PengajuanPembiayaanPageState extends State<PengajuanPembiayaanPage>
    with SingleTickerProviderStateMixin {
  // ── Form state ────────────────────────────────────────────────────────────
  String? _selectedProdukId;
  final _jumlahCtrl = TextEditingController();
  final _tujuanCtrl = TextEditingController();
  int?   _selectedTenor;

  // ── Focus Nodes for Premium Border Highlights ─────────────────────────────
  final _jumlahFocus = FocusNode();
  final _tujuanFocus = FocusNode();
  bool _jumlahHasFocus = false;
  bool _tujuanHasFocus = false;

  // ── Staggered entrance ────────────────────────────────────────────────────
  late final AnimationController _ctrl;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>>  _slides;

  // ── Computed cicilan ──────────────────────────────────────────────────────
  String get _cicilanEstimasi {
    final raw   = int.tryParse(_jumlahCtrl.text.trim());
    final tenor = _selectedTenor;
    if (raw == null || raw == 0 || tenor == null) return '-';
    return _formatRp((raw / tenor).ceil());
  }

  bool get _canSubmit =>
      _selectedProdukId != null &&
      _jumlahCtrl.text.trim().isNotEmpty &&
      _tujuanCtrl.text.trim().isNotEmpty &&
      _selectedTenor != null;

  @override
  void initState() {
    super.initState();

    _jumlahFocus.addListener(() {
      setState(() => _jumlahHasFocus = _jumlahFocus.hasFocus);
    });
    _tujuanFocus.addListener(() {
      setState(() => _tujuanHasFocus = _tujuanFocus.hasFocus);
    });

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fades = List.generate(6, (i) {
      final s = i * 0.10;
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _ctrl,
        curve: Interval(s, (s + 0.45).clamp(0, 1.0), curve: Curves.easeOut),
      ));
    });
    _slides = List.generate(6, (i) {
      final s = i * 0.10;
      return Tween<Offset>(
        begin: const Offset(0, 0.22),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _ctrl,
        curve: Interval(s, (s + 0.45).clamp(0, 1.0),
            curve: Curves.easeOutCubic),
      ));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void dispose() {
    _jumlahFocus.dispose();
    _tujuanFocus.dispose();
    _ctrl.dispose();
    _jumlahCtrl.dispose();
    _tujuanCtrl.dispose();
    super.dispose();
  }

  Widget _animated(int i, Widget child) => FadeTransition(
        opacity: _fades[i],
        child: SlideTransition(position: _slides[i], child: child),
      );

  String _formatRp(int v) {
    final s   = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp. ${buf.toString()}';
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
                _animated(0, _buildAppBar(context)),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _animated(1, _buildPilihProduk()),
                        const SizedBox(height: 22),

                        _animated(2,
                          _buildInputField(
                            label: 'Jumlah Pembiayaan (Rp)',
                            controller: _jumlahCtrl,
                            focusNode: _jumlahFocus,
                            isFocused: _jumlahHasFocus,
                            hint: 'Masukkan nominal pembiayaan',
                            isNumeric: true,
                            prefixText: _jumlahCtrl.text.isNotEmpty ? 'Rp. ' : null,
                          ),
                        ),
                        const SizedBox(height: 22),

                        _animated(3,
                          _buildInputField(
                            label: 'Tujuan Pembiayaan',
                            controller: _tujuanCtrl,
                            focusNode: _tujuanFocus,
                            isFocused: _tujuanHasFocus,
                            hint: 'Masukkan tujuan pengajuan',
                          ),
                        ),
                        const SizedBox(height: 22),

                        _animated(4, _buildTenorDropdown()),
                        const SizedBox(height: 22),

                        _animated(5, Column(
                          children: [
                            _buildCicilanCard(),
                            const SizedBox(height: 28),
                            _buildSubmitButton(),
                            const SizedBox(height: 24),
                            _buildFooterNote(),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
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
              child: const Icon(Icons.arrow_back_rounded,
                  size: 20, color: kHijauTua),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Ajukan Pembiayaan',
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

  // ── Pilih Produk ──────────────────────────────────────────────────────────
  Widget _buildPilihProduk() {
    final hasVal = _selectedProdukId != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Pilih Produk Pembiayaan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF1D2E14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasVal ? kHijauTua : const Color(0xFFE8F0D8),
              width: hasVal ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: hasVal
                    ? kHijauTua.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedProdukId,
              isExpanded: true,
              hint: const Text(
                'Pilih jenis pembiayaan',
                style: TextStyle(color: Color(0xFF888888), fontSize: 14),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF888888)),
              items: kProdukList
                  .map((p) => DropdownMenuItem(
                        value: p['id'],
                        child: Text(p['label']!,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedProdukId = v),
            ),
          ),
        ),
      ],
    );
  }

  // ── Text input field ──────────────────────────────────────────────────────
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    String hint = '',
    bool isNumeric = false,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF1D2E14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFocused ? kHijauTua : const Color(0xFFE8F0D8),
              width: isFocused ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isFocused
                    ? kHijauTua.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (prefixText != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    prefixText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType:
                      isNumeric ? TextInputType.number : TextInputType.text,
                  inputFormatters: isNumeric
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : null,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 14,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tenor dropdown ────────────────────────────────────────────────────────
  Widget _buildTenorDropdown() {
    final hasVal = _selectedTenor != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Tenor (Bulan)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF1D2E14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasVal ? kHijauTua : const Color(0xFFE8F0D8),
              width: hasVal ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: hasVal
                    ? kHijauTua.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedTenor,
              isExpanded: true,
              hint: const Text(
                'Pilih tenor pembayaran',
                style: TextStyle(color: Color(0xFF888888), fontSize: 14),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF888888)),
              items: kTenorOptions
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text('$t Bulan',
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedTenor = v),
            ),
          ),
        ),
      ],
    );
  }

  // ── Cicilan estimasi card ─────────────────────────────────────────────────
  Widget _buildCicilanCard() {
    final hasCicilan = _cicilanEstimasi != '-';
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cicilan Per Bulan (Estimasi)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF888888),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _cicilanEstimasi,
                  key: ValueKey(_cicilanEstimasi),
                  style: TextStyle(
                    fontSize: hasCicilan ? 20 : 15,
                    fontWeight: FontWeight.bold,
                    color: hasCicilan
                        ? kHijauTua
                        : const Color(0xFF888888),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: DashedBorderPainter(
                color: hasCicilan
                    ? kHijauTua.withValues(alpha: 0.4)
                    : const Color(0xFFDDE5C8),
                radius: 16,
                dashWidth: 6,
                dashSpace: 4,
                strokeWidth: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Submit button ─────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _canSubmit
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
        onPressed: _canSubmit
            ? () {
                final amount =
                    double.tryParse(_jumlahCtrl.text.trim()) ?? 0;
                final type = _selectedProdukId == 'QARDHUL_HASAN'
                    ? 'QARDHUL_HASAN'
                    : 'MURABAHAH';
                Navigator.pushNamed(
                  context,
                  RouteNames.aiStep1,
                  arguments: AiStep1Args(
                    loanAmount: amount,
                    loanTenor: _selectedTenor!,
                    loanPurpose: _tujuanCtrl.text.trim(),
                    loanType: type,
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: kHijauTua,
          disabledBackgroundColor: const Color(0xFFB8C8A0),
          foregroundColor: kPutih,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Selanjutnya',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ── Footer note ───────────────────────────────────────────────────────────
  Widget _buildFooterNote() {
    return const Column(
      children: [
        Text(
          'Proses AI Scoring akan dimulai setelah pengiriman.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF888888),
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'AI Scoring akan berjalan otomatis.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF888888),
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
