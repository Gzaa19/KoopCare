import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/app_constants.dart';
import 'package:koopcare/core/router/route_names.dart';
import 'package:koopcare/core/di/service_locator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

import '../bloc/topup_bloc.dart';
import '../bloc/topup_event.dart';
import '../bloc/topup_state.dart';
import 'midtrans_webview_page.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage>
    with SingleTickerProviderStateMixin {
  String? _selectedBank;
  final _rekeningCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AnimationController _ctrl;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  bool get _canSubmit =>
      _selectedBank != null &&
      _rekeningCtrl.text.trim().isNotEmpty &&
      _jumlahCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fades = List.generate(4, (i) {
      final s = i * 0.14;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(s, (s + 0.5).clamp(0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    _slides = List.generate(4, (i) {
      final s = i * 0.14;
      return Tween<Offset>(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(
            s,
            (s + 0.5).clamp(0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
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
    return BlocProvider<TopupBloc>(
      create: (_) => getIt<TopupBloc>(),
      child: BlocListener<TopupBloc, TopupState>(
        listener: (context, state) async {
          if (state.status == TopupFlowStatus.creating) {
            if (!context.mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
            return;
          }

          if (Navigator.canPop(context)) Navigator.of(context).pop();

          if (state.status == TopupFlowStatus.awaitingPayment &&
              state.session != null) {
            final bloc = context.read<TopupBloc>();
            await Navigator.of(context).push<bool?>(
              MaterialPageRoute(
                builder: (_) => MidtransWebViewPage(
                  redirectUrl: state.session!.redirectUrl,
                ),
              ),
            );

            bloc.add(TopupPollStatusRequested(state.session!.orderId));
          }

          if (state.status == TopupFlowStatus.success) {
            if (!context.mounted) return;
            context.read<AuthBloc>().add(const AuthProfileRefreshRequested());
            final amount =
                int.tryParse(
                  _jumlahCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
                ) ??
                0;
            Navigator.pushReplacementNamed(
              context,
              RouteNames.topupSuccess,
              arguments: amount,
            );
          }

          if (state.status == TopupFlowStatus.failure &&
              state.errorMessage != null) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: Scaffold(
          backgroundColor: kScaffold,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Form(
                      key: _formKey,
                      onChanged: () => setState(() {}),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _animated(0, _buildDropdownField()),
                          const SizedBox(height: 20),

                          _animated(
                            1,
                            _buildInputField(
                              label: 'Nomor Rekening',
                              controller: _rekeningCtrl,
                              hint: '',
                              isNumeric: true,
                              maxLength: 16,
                            ),
                          ),
                          const SizedBox(height: 20),

                          _animated(
                            2,
                            _buildInputField(
                              label: 'Jumlah Transfer (Rp)',
                              controller: _jumlahCtrl,
                              hint: 'Rp. 1.000.000',
                              isNumeric: true,
                            ),
                          ),
                          const SizedBox(height: 20),

                          _animated(
                            3,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF4A90D9),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Builder(
                    builder: (context) => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _canSubmit
                            ? () {
                                final amount =
                                    int.tryParse(
                                      _jumlahCtrl.text.replaceAll(
                                        RegExp(r'[^0-9]'),
                                        '',
                                      ),
                                    ) ??
                                    0;
                                if (amount <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Masukkan jumlah yang valid',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                context.read<TopupBloc>().add(
                                  TopupRequested(amount),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kHijauTua,
                          disabledBackgroundColor: const Color(0xFFB0BDA0),
                          foregroundColor: kPutih,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Lanjut Ke Verifikasi PIN',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Top Up',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Bank',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedBank,
              hint: const Text(
                '',
                style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF888888),
              ),
              items: kBankOptions.map((bank) {
                return DropdownMenuItem(
                  value: bank,
                  child: Text(
                    bank,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedBank = val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String hint = '',
    bool isNumeric = false,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            inputFormatters: [
              if (isNumeric) FilteringTextInputFormatter.digitsOnly,
              if (maxLength != null)
                LengthLimitingTextInputFormatter(maxLength),
            ],
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 14,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }
}
