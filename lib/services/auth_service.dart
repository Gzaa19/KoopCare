import 'api_service.dart';

// ─── Model ─────────────────────────────────────────────────────────────────────

class AuthUser {
  final int id;
  final String name;
  final String phone;
  final String? email;

  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as int,
        name: json['name'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
      );
}

// ─── Auth Service ─────────────────────────────────────────────────────────────

class AuthService {
  // ── Login ─────────────────────────────────────────────────────────────────
  // POST /mobile/login
  // [identifier] = nomor WA atau email
  // [pin]        = 6 digit angka
  // Backend memverifikasi PIN via bcrypt, lalu return JWT.
  // TIDAK menggunakan OTP — OTP hanya untuk lupa PIN.
  static Future<AuthUser> login({
    required String identifier,
    required String pin,
  }) async {
    final response = await ApiService.post('/login', {
      'identifier': identifier,
      'pin': pin,
    });
    final token = response['token'] as String;
    final user = AuthUser.fromJson(response['user'] as Map<String, dynamic>);
    await ApiService.saveToken(token);
    return user;
  }

  // ── Register ──────────────────────────────────────────────────────────────
  // POST /mobile/register
  // Wajib: full_name, nik (16 digit), phone, pin (6 digit)
  // Opsional: email, monthly_income, birth_date, education, occupation
  //
  // Catatan: foto KTP/selfie TIDAK dikirim di sini.
  // Foto dikirim terpisah ke POST /mobile/kyc/submit setelah login.
  // Backend langsung membuat akun ACTIVE dan return JWT.
  static Future<AuthUser> register({
    required String fullName,
    required String noWa,
    required String nik,
    required String pin,
    String? email,
    int monthlyIncome = 0,
  }) async {
    final response = await ApiService.post('/register', {
      'full_name': fullName,
      'phone': noWa,
      'nik': nik,
      'pin': pin,
      if (email != null && email.isNotEmpty) 'email': email,
      'monthly_income': monthlyIncome,
    });
    final token = response['token'] as String;
    final user = AuthUser.fromJson(response['user'] as Map<String, dynamic>);
    await ApiService.saveToken(token);
    return user;
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  // Backend stateless (JWT), cukup hapus token lokal
  static Future<void> logout() async {
    await ApiService.clearToken();
  }

  // ── Auth check ────────────────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    return ApiService.hasToken();
  }

  // ── Lupa PIN: Minta OTP via WhatsApp ──────────────────────────────────────
  // POST /mobile/otp/request
  // OTP dikirim ke nomor WA via Fonnte — HANYA jika WHATSAPP_API_KEY di-set di backend.
  // Jika key tidak ada, backend gagal diam-diam (return false) tapi tidak error 500.
  static Future<void> requestOtp(String identifier) async {
    await ApiService.post('/otp/request', {'identifier': identifier});
  }

  // ── Lupa PIN: Verifikasi OTP ──────────────────────────────────────────────
  // POST /mobile/otp/verify
  // OTP disimpan in-memory di backend (Map), expire 10 menit.
  // Lempar ApiException jika salah/kadaluarsa.
  static Future<void> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    await ApiService.post('/otp/verify', {
      'identifier': identifier,
      'otp': otp,
    });
  }

  // ── Lupa PIN: Reset PIN ───────────────────────────────────────────────────
  // POST /mobile/reset-pin
  // Backend re-verifikasi OTP di sini juga, jadi verifyOtp() di atas opsional.
  static Future<void> resetPin({
    required String identifier,
    required String otp,
    required String newPin,
  }) async {
    await ApiService.post('/reset-pin', {
      'identifier': identifier,
      'otp': otp,
      'newPin': newPin,
    });
  }

  // ── Profile ───────────────────────────────────────────────────────────────
  // GET /mobile/profile (perlu token)
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiService.get('/profile');
    return response['data'] as Map<String, dynamic>;
  }
}
