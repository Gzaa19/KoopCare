import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';
import '../../../core/app_colors.dart';

// ─── Lupa PIN Page ────────────────────────────────────────────────────────────
// Menggantikan OtpPage yang sebelumnya dipakai untuk login.
// OTP dikirim via WhatsApp (Fonnte) → verifikasi → reset PIN.
// CATATAN: Berhasil hanya jika WHATSAPP_API_KEY di-set di backend .env
class LupaPinPage extends StatefulWidget {
  const LupaPinPage({super.key});

  @override
  State<LupaPinPage> createState() => _LupaPinPageState();
}

class _LupaPinPageState extends State<LupaPinPage> {
  // 0 = masukkan nomor, 1 = masukkan OTP, 2 = buat PIN baru
  int _step = 0;

  final _identifierCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final _newPinCtrl     = TextEditingController();
  final _confirmPinCtrl = TextEditingController();

  bool _isLoading = false;
  String? _error;
  int _countdown = 59;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    for (final c in _otpCtrls) { c.dispose(); }
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    super.dispose();
  }

  String get _otpValue => _otpCtrls.map((c) => c.text).join();

  // ── Step 0: kirim OTP ──────────────────────────────────────────────────────

  Future<void> _requestOtp() async {
    final id = _identifierCtrl.text.trim();
    if (id.isEmpty) {
      setState(() => _error = 'Masukkan nomor WhatsApp atau NIK');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      await AuthService.requestOtp(id);
      setState(() { _step = 1; _countdown = 59; });
      _startCountdown();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Gagal mengirim OTP. Cek koneksi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdown--);
      return _countdown > 0;
    });
  }

  // ── Step 1: verifikasi OTP ─────────────────────────────────────────────────

  Future<void> _verifyOtp() async {
    if (_otpValue.length != 6) {
      setState(() => _error = 'Masukkan 6 digit OTP');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      await AuthService.verifyOtp(
        identifier: _identifierCtrl.text.trim(),
        otp: _otpValue,
      );
      setState(() => _step = 2);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'OTP tidak valid atau kadaluarsa');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Step 2: reset PIN ──────────────────────────────────────────────────────

  Future<void> _resetPin() async {
    final newPin = _newPinCtrl.text.trim();
    if (newPin.length != 6) {
      setState(() => _error = 'PIN baru harus 6 digit');
      return;
    }
    if (newPin != _confirmPinCtrl.text.trim()) {
      setState(() => _error = 'Konfirmasi PIN tidak cocok');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      await AuthService.resetPin(
        identifier: _identifierCtrl.text.trim(),
        otp: _otpValue,
        newPin: newPin,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN berhasil direset. Silakan masuk.')),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Gagal mereset PIN');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _otpCtrls[index],
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              Container(
                width: 110, height: 110,
                decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.lock_reset, color: Colors.white, size: 50),
              ),

              const SizedBox(height: 24),

              Text(
                _step == 0 ? 'Lupa PIN' : _step == 1 ? 'Verifikasi OTP' : 'Buat PIN Baru',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                _step == 0
                    ? 'Masukkan nomor WhatsApp terdaftar'
                    : _step == 1
                        ? 'Kode OTP telah dikirim ke WhatsApp Anda'
                        : 'Masukkan PIN baru 6 digit',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // ── Step 0: input nomor ────────────────────────────────────────
              if (_step == 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _identifierCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(Icons.phone_outlined),
                      hintText: 'Nomor WhatsApp / NIK',
                    ),
                  ),
                ),

              // ── Step 1: OTP boxes ──────────────────────────────────────────
              if (_step == 1) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, _buildOtpBox),
                ),
                const SizedBox(height: 20),
                Text(
                  'Kirim ulang kode dalam 0:${_countdown.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 14),
                ),
                if (_countdown == 0)
                  TextButton(
                    onPressed: _requestOtp,
                    child: const Text('Kirim Ulang OTP',
                        style: TextStyle(color: kPrimary)),
                  ),
              ],

              // ── Step 2: PIN baru ───────────────────────────────────────────
              if (_step == 2) ...[
                _buildPinInput('PIN Baru', _newPinCtrl),
                const SizedBox(height: 16),
                _buildPinInput('Konfirmasi PIN Baru', _confirmPinCtrl),
              ],

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

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_step == 0
                          ? _requestOtp
                          : _step == 1
                              ? _verifyOtp
                              : _resetPin),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          _step == 0 ? 'KIRIM OTP' : _step == 1 ? 'VERIFIKASI' : 'SIMPAN PIN',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinInput(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: ctrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
              icon: Icon(Icons.lock_outline),
            ),
          ),
        ),
      ],
    );
  }
}
