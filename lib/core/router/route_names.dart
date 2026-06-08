/// Centralized route name constants.
///
/// Use these constants everywhere instead of raw strings to avoid typos
/// and make refactoring easier.
abstract class RouteNames {
  RouteNames._();

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const login          = '/login';
  static const register1      = '/register/step1';
  static const register2      = '/register/step2';
  static const createPin      = '/register/create-pin';
  static const pinSuccess     = '/register/pin-success';
  static const registerDone   = '/register/success';
  static const forgotPin      = '/forgot-pin';

  // ── Shell ─────────────────────────────────────────────────────────────────
  static const home           = '/home';

  // ── Notification ─────────────────────────────────────────────────────────
  static const notification   = '/notification';

  // ── Financial ─────────────────────────────────────────────────────────────
  static const pengajuan      = '/financial/pengajuan';
  static const topup          = '/financial/topup';
  static const topupSuccess   = '/financial/topup-success';
  static const transfer       = '/financial/transfer';
  static const pinVerify      = '/financial/pin-verify';
  static const pembayaranDetail = '/financial/pembayaran-detail';
  static const riwayat        = '/financial/riwayat';

  // ── AI Scoring ────────────────────────────────────────────────────────────
  static const aiStep1        = '/ai-scoring/step1';
  static const aiStep2        = '/ai-scoring/step2';
  static const aiStep3        = '/ai-scoring/step3';
  static const aiProcessing   = '/ai-scoring/processing';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const generalInfo    = '/profile/general-info';
  static const faq            = '/faq';
}
