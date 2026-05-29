import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../widgets/register/animated_field.dart';
import '../widgets/register/register_text_field.dart';
import '../widgets/register/step_header.dart';
import 'register_step2_page.dart';

/// Step 1 of registration: collect name, WhatsApp number, NIK.
///
/// This step is a pure form — no backend calls, no BLoC. The collected
/// values are passed forward via the [RegisterStep2Page] constructor.
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

    // Staggered slide+fade for each of the 3 fields.
    _slideAnims = List.generate(3, (i) {
      final start = i * 0.15;
      final end = start + 0.55;
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    _fadeAnims = List.generate(3, (i) {
      final start = i * 0.15;
      final end = start + 0.55;
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _entranceCtrl.forward());
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

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => RegisterStep2Page(
          nama: _namaCtrl.text.trim(),
          noWa: _waCtrl.text.trim(),
          nik: _nikCtrl.text.trim(),
        ),
        transitionsBuilder: (_, animation, _, child) {
          final slide = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: kPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'KoopCare',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const StepHeader(current: 1, total: 2),
                const SizedBox(height: 30),
                AnimatedField(
                  slide: _slideAnims[0],
                  fade: _fadeAnims[0],
                  child: RegisterTextField(
                    label: 'NAMA LENGKAP (SESUAI KTP)',
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
                    label: 'NOMOR WHATSAPP AKTIF',
                    controller: _waCtrl,
                    isNumeric: true,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Nomor WhatsApp wajib diisi';
                      }
                      if (v.trim().length < 10) return 'Nomor tidak valid';
                      return null;
                    },
                  ),
                ),
                AnimatedField(
                  slide: _slideAnims[2],
                  fade: _fadeAnims[2],
                  child: RegisterTextField(
                    label: 'NIK (NOMOR INDUK KEPENDUDUKAN)',
                    controller: _nikCtrl,
                    isNumeric: true,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'NIK wajib diisi';
                      if (v.trim().length != 16) return 'NIK harus 16 digit';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      elevation: 4,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'BERIKUTNYA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (kDebugMode)
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterStep2Page(
                            nama: 'Debug User',
                            noWa: '08123456789',
                            nik: '1234567890123456',
                          ),
                        ),
                      ),
                      child: const Text(
                        'Skip (debug)',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
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
}
