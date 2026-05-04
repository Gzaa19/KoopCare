import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'register_step2_page.dart';

// ─── Shared colour token (keep in sync with your app theme) ──────────────────
const Color kPrimary = Color(0xFF6B7F3F);

class RegisterStep1Page extends StatefulWidget {
  const RegisterStep1Page({super.key});

  @override
  State<RegisterStep1Page> createState() => _RegisterStep1PageState();
}

class _RegisterStep1PageState extends State<RegisterStep1Page>
    with SingleTickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────────
  final _namaCtrl  = TextEditingController();
  final _waCtrl    = TextEditingController();
  final _nikCtrl   = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  // ── Entrance animation ────────────────────────────────────────────────────────
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

    // Staggered slide+fade for each of the 3 fields
    _slideAnims = List.generate(3, (i) {
      final start = i * 0.15;
      final end   = start + 0.55;
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
      final end   = start + 0.55;
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });

    // Kick off after first frame
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

  // ── Validation & navigation ───────────────────────────────────────────────────
  void _onNext() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => RegisterStep2Page(
          nama: _namaCtrl.text.trim(),
          noWa: _waCtrl.text.trim(),
          nik:  _nikCtrl.text.trim(),
        ),
        // Slide-in from right + fade
        transitionsBuilder: (_, animation, __, child) {
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
          child: SingleChildScrollView(          // prevents keyboard overflow
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── Back button ─────────────────────────────────────────────
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

                // ── Title ───────────────────────────────────────────────────
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

                // ── Step indicator ──────────────────────────────────────────
                StepHeader(current: 1, total: 2),

                const SizedBox(height: 30),

                // ── Staggered fields ────────────────────────────────────────
                AnimatedField(
                  slide: _slideAnims[0],
                  fade: _fadeAnims[0],
                  child: _buildField(
                    label: 'NAMA LENGKAP (SESUAI KTP)',
                    controller: _namaCtrl,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                  ),
                ),
                AnimatedField(
                  slide: _slideAnims[1],
                  fade: _fadeAnims[1],
                  child: _buildField(
                    label: 'NOMOR WHATSAPP AKTIF',
                    controller: _waCtrl,
                    isNumeric: true,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Nomor WhatsApp wajib diisi';
                      if (v.trim().length < 10) return 'Nomor tidak valid';
                      return null;
                    },
                  ),
                ),
                AnimatedField(
                  slide: _slideAnims[2],
                  fade: _fadeAnims[2],
                  child: _buildField(
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

                // ── Next button ─────────────────────────────────────────────
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
                          builder: (_) => RegisterStep2Page(
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

  // ── Field builder ─────────────────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool isNumeric = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF333333))),
        const SizedBox(height: 10),
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEDED),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            inputFormatters:
                isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
            validator: validator,
            decoration: const InputDecoration(
              border: InputBorder.none,
              errorStyle: TextStyle(height: 0), // shown outside container
            ),
          ),
        ),
        // Validator error shown below box, not inside
        Builder(builder: (ctx) {
          return const SizedBox(height: 4);
        }),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ─── Step header widget (shared between step1 & step2) ───────────────────────
class StepHeader extends StatelessWidget {
  final int current;
  final int total;

  const StepHeader({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Steps',
                style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
            Text('$current/$total',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333))),
          ],
        ),
        const SizedBox(height: 8),
        // Animated progress bar
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: current / total),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (_, value, __) => LinearProgressIndicator(
            value: value,
            minHeight: 6,
            color: kPrimary,
            backgroundColor: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

// ─── Animated field wrapper ───────────────────────────────────────────────────
class AnimatedField extends StatelessWidget {
  final Animation<Offset> slide;
  final Animation<double> fade;
  final Widget child;

  const AnimatedField({
    super.key,
    required this.slide,
    required this.fade,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

// ─── Animated field wrapper ───────────────────────────────────────────────────
class AnimatedField extends StatelessWidget {
  final Animation<Offset> slide;
  final Animation<double> fade;
  final Widget child;

  const AnimatedField({
    super.key,
    required this.slide,
    required this.fade,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
