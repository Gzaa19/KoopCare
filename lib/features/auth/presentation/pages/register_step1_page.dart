import 'package:flutter/material.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/widgets/app_widgets.dart';
import '../widgets/register/animated_field.dart';
import '../widgets/register/register_text_field.dart';
import '../widgets/register/step_header.dart';
import '../../../../core/router/route_args.dart';
import '../../../../core/router/route_names.dart';

class RegisterStep1Page extends StatefulWidget {
  const RegisterStep1Page({super.key});

  @override
  State<RegisterStep1Page> createState() => _RegisterStep1PageState();
}

class _RegisterStep1PageState extends State<RegisterStep1Page>
    with SingleTickerProviderStateMixin {
  final _namaCtrl = TextEditingController();
  final _waCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AnimationController _entranceCtrl;
  late final List<Animation<Offset>> _slideAnims;
  late final List<Animation<double>> _fadeAnims;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnims = List.generate(3, (i) {
      final start = i * 0.12;
      final end = start + 0.55;
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _fadeAnims = List.generate(3, (i) {
      final start = i * 0.12;
      final end = start + 0.55;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _entranceCtrl.forward(),
    );
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _namaCtrl.dispose();
    _waCtrl.dispose();
    _nikCtrl.dispose();
    super.dispose();
  }

  void _onNext() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    Navigator.pushNamed(
      context,
      RouteNames.register2,
      arguments: Register2Args(
        nama: _namaCtrl.text.trim(),
        noWa: _waCtrl.text.trim(),
        nik: _nikCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const AmbientOrbBackground(),
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: kPutih,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE8F0D8), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: kHijauTua),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Buat Akun Baru',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D2E14),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const StepHeader(current: 1, total: 2),
                    const SizedBox(height: 32),
                    AnimatedField(
                      slide: _slideAnims[0],
                      fade: _fadeAnims[0],
                      child: RegisterTextField(
                        label: 'Nama Lengkap (Sesuai KTP)',
                        controller: _namaCtrl,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama wajib diisi'
                            : null,
                      ),
                    ),
                    AnimatedField(
                      slide: _slideAnims[1],
                      fade: _fadeAnims[1],
                      child: RegisterTextField(
                        label: 'Nomor WhatsApp Aktif',
                        controller: _waCtrl,
                        isNumeric: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nomor WhatsApp wajib diisi';
                          }
                          if (v.trim().length < 10) {
                            return 'Nomor tidak valid';
                          }
                          return null;
                        },
                      ),
                    ),
                    AnimatedField(
                      slide: _slideAnims[2],
                      fade: _fadeAnims[2],
                      child: RegisterTextField(
                        label: 'NIK (Nomor Induk Kependudukan)',
                        controller: _nikCtrl,
                        isNumeric: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'NIK wajib diisi';
                          }
                          if (v.trim().length != 16) {
                            return 'NIK harus 16 digit';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: kHijauTua.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kHijauTua,
                            foregroundColor: kPutih,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Lanjutkan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
