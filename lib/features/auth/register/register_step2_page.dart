import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'create_pin_page.dart';
import 'register_success_page.dart';
import 'register_step1_page.dart'; // for kPrimary + shared widgets

class RegisterStep2Page extends StatefulWidget {
  // ── Data passed from Step 1 ─────────────────────────────────────────────────
  final String nama;
  final String noWa;
  final String nik;

  const RegisterStep2Page({
    super.key,
    required this.nama,
    required this.noWa,
    required this.nik,
  });

  @override
  State<RegisterStep2Page> createState() => _RegisterStep2PageState();
}

class _RegisterStep2PageState extends State<RegisterStep2Page>
    with SingleTickerProviderStateMixin {
  XFile? ktpImage;
  XFile? selfieImage;
  Uint8List? ktpBytes;
  Uint8List? selfieBytes;
  bool agree = false;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

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

    // 2 upload boxes + 1 checkbox row = 3 items
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

    WidgetsBinding.instance.addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  // ── Image picking ─────────────────────────────────────────────────────────────
  Future<void> _pickImage(bool isKtp) async {
    // Show source picker bottom sheet
    final source = await _showSourceSheet();
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      if (isKtp) {
        ktpImage = picked;
        ktpBytes = bytes;
      } else {
        selfieImage = picked;
        selfieBytes = bytes;
      }
    });
  }

  Future<ImageSource?> _showSourceSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: kPrimary),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: kPrimary),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────────
  bool get _canSubmit =>
      agree && ktpImage != null && selfieImage != null && !_isLoading;

  Future<void> _onVerify() async {
    if (!_canSubmit) {
      _showValidationSnackbar();
      return;
    }

    setState(() => _isLoading = true);

    // Simulate async upload / API call
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => const RegisterSuccessPage(),
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

  void _showValidationSnackbar() {
    String msg;
    if (ktpImage == null) {
      msg = 'Harap unggah foto e-KTP terlebih dahulu';
    } else if (selfieImage == null) {
      msg = 'Harap unggah foto selfie dengan e-KTP';
    } else {
      msg = 'Harap setujui Syarat & Ketentuan';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Back button ───────────────────────────────────────────────
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

              const SizedBox(height: 16),

              // ── Title ─────────────────────────────────────────────────────
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

              // ── Step indicator (animated progress 0.5 → 1.0) ─────────────
              StepHeader(current: 2, total: 2),

              const SizedBox(height: 30),

              // ── Upload boxes ──────────────────────────────────────────────
              AnimatedField(
                slide: _slideAnims[0],
                fade: _fadeAnims[0],
                child: _buildUploadBox(
                  title: 'FOTO e-KTP ASLI',
                  isKtp: true,
                  icon: Icons.credit_card_outlined,
                ),
              ),

              AnimatedField(
                slide: _slideAnims[1],
                fade: _fadeAnims[1],
                child: _buildUploadBox(
                  title: 'FOTO SELFIE DENGAN e-KTP',
                  isKtp: false,
                  icon: Icons.face_outlined,
                ),
              ),

              // ── Checkbox ──────────────────────────────────────────────────
              AnimatedField(
                slide: _slideAnims[2],
                fade: _fadeAnims[2],
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: agree,
                      activeColor: kPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (v) => setState(() => agree = v ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'Saya menyetujui Syarat & Ketentuan',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Verify button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _onVerify : _onVerify, // always tappable to show snackbar
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _canSubmit ? kPrimary : Colors.grey[400],
                    elevation: _canSubmit ? 4 : 0,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'VERIFIKASI',
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
                        builder: (_) => const CreatePinPage(),
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
    );
  }

  // ── Upload box builder ────────────────────────────────────────────────────────
  Widget _buildUploadBox({
    required String title,
    required bool isKtp,
    required IconData icon,
  }) {
    final bytes = isKtp ? ktpBytes : selfieBytes;
    final hasImage = bytes != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _pickImage(isKtp),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: hasImage ? Colors.transparent : const Color(0xFFF5F7F0),
              border: Border.all(
                color: hasImage ? kPrimary : const Color(0xFFB0BDA0),
                width: hasImage ? 2 : 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: hasImage
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(bytes, fit: BoxFit.cover,
                            width: double.infinity, height: double.infinity),
                      ),
                      // Re-pick overlay
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('Ganti',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 36, color: const Color(0xFF8FA84A)),
                      const SizedBox(height: 8),
                      Text(
                        'Ketuk untuk mengunggah',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
