import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';
import 'pin_success_page.dart';
import 'register_success_page.dart';
import '../../../core/app_colors.dart';

// ─── Create PIN Page ──────────────────────────────────────────────────────────
// Dipanggil dari RegisterStep2Page dengan data registrasi lengkap.
// Di sini PIN dibuat, lalu AuthService.register() dipanggil ke backend.
class CreatePinPage extends StatefulWidget {
  final String fullName;
  final String noWa;
  final String nik;

  const CreatePinPage({
    super.key,
    required this.fullName,
    required this.noWa,
    required this.nik,
  });

  @override
  State<CreatePinPage> createState() => _CreatePinPageState();
}

class _CreatePinPageState extends State<CreatePinPage> {
  final List<TextEditingController> pin = List.generate(6, (_) => TextEditingController());
  final List<TextEditingController> confirm = List.generate(6, (_) => TextEditingController());

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [...pin, ...confirm]) { c.dispose(); }
    super.dispose();
  }

  String _getPin(List<TextEditingController> list) =>
      list.map((e) => e.text).join();

  Widget _buildBox(List<TextEditingController> list, int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: list[index],
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        maxLength: 1,
        obscureText: true,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFE5E5E5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimary),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) FocusScope.of(context).nextFocus();
          if (value.isEmpty && index > 0) FocusScope.of(context).previousFocus();
        },
      ),
    );
  }

  Future<void> _simpanPin() async {
    final pinValue     = _getPin(pin);
    final confirmValue = _getPin(confirm);

    if (pinValue.length != 6 || confirmValue.length != 6) {
      setState(() => _error = 'PIN harus 6 digit');
      return;
    }
    if (pinValue != confirmValue) {
      setState(() => _error = 'PIN tidak sama');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      // Panggil backend — register sekaligus set PIN
      await AuthService.register(
        fullName: widget.fullName,
        noWa: widget.noWa,
        nik: widget.nik,
        pin: pinValue,
      );

      if (!mounted) return;
      // Akun berhasil dibuat → PinSuccessPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PinSuccessPage()),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Gagal terhubung ke server');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 45, height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back),
                  ),
                ),

                const SizedBox(height: 30),

                Center(
                  child: Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.lock_outline, color: Colors.white, size: 50),
                  ),
                ),

                const SizedBox(height: 30),

                const Center(
                  child: Text('Akun anda sudah aktif!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text('Buat 6-digit PIN Keamanan.',
                      style: TextStyle(fontSize: 14)),
                ),

                const SizedBox(height: 30),

                const Text('Buat PIN', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) => _buildBox(pin, i)),
                ),

                const SizedBox(height: 30),

                const Text('Konfirmasi PIN', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) => _buildBox(confirm, i)),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                ],

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _simpanPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Simpan & Lanjut',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),

                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const PinSuccessPage()),
                      ),
                      child: const Text('Skip (debug)',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
