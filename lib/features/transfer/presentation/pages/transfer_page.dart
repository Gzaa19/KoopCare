import 'package:flutter/material.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/features/transfer/presentation/widgets/transfer_form_widgets.dart';

const int kSaldoBisaDitarik = 3500000;

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage>
    with SingleTickerProviderStateMixin {
  String? _selectedBank;
  final _rekeningCtrl = TextEditingController();
  final _jumlahCtrl   = TextEditingController();

  late final AnimationController _ctrl;
  late final List<Animation<double>>  _fades;
  late final List<Animation<Offset>>  _slides;

  bool get _canSubmit =>
      _selectedBank != null &&
      _rekeningCtrl.text.trim().isNotEmpty &&
      _jumlahCtrl.text.trim().isNotEmpty;

  bool get _exceedsBalance {
    final raw = _jumlahCtrl.text.trim();
    if (raw.isEmpty) return false;
    final amount = int.tryParse(raw) ?? 0;
    return amount > kSaldoBisaDitarik;
  }

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fades = List.generate(4, (i) {
      final s = i * 0.13;
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _ctrl,
        curve: Interval(s, (s + 0.5).clamp(0, 1.0), curve: Curves.easeOut),
      ));
    });
    _slides = List.generate(4, (i) {
      final s = i * 0.13;
      return Tween<Offset>(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _ctrl,
        curve: Interval(s, (s + 0.5).clamp(0, 1.0),
            curve: Curves.easeOutCubic),
      ));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _rekeningCtrl.dispose();
    _jumlahCtrl.dispose();
    super.dispose();
  }

  Widget _animated(int i, Widget child) => FadeTransition(
        opacity: _fades[i],
        child: SlideTransition(position: _slides[i], child: child),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      body: SafeArea(
        child: Column(
          children: [
            TransferAppBar(onBack: () => Navigator.maybePop(context)),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _animated(0, const TransferBalanceCard()),
                    const SizedBox(height: 24),

                    _animated(1, TransferBankDropdown(
                      selectedBank: _selectedBank,
                      onChanged: (v) => setState(() => _selectedBank = v),
                    )),
                    const SizedBox(height: 20),

                    _animated(2,
                      TransferInputField(
                        label: 'Nomor Rekening',
                        controller: _rekeningCtrl,
                        hint: '',
                        isNumeric: true,
                        maxLength: 16,
                        onChanged: () => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _animated(3,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TransferInputField(
                            label: 'Jumlah Transfer (Rp)',
                            controller: _jumlahCtrl,
                            hint: 'Rp. 1.000.000',
                            isNumeric: true,
                            errorText: _exceedsBalance
                                ? 'Jumlah melebihi saldo yang tersedia'
                                : null,
                            onChanged: () => setState(() {}),
                          ),
                          const SizedBox(height: 16),

                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline,
                                  color: Color(0xFF4A90D9), size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Verifikasi PIN diperlukan di langkah berikutnya.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF555555),
                                    height: 1.4,
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
            ),

            TransferCtaButton(
              enabled: _canSubmit && !_exceedsBalance,
            ),
          ],
        ),
      ),
    );
  }
}
