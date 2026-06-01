import 'package:equatable/equatable.dart';

/// All fields collected across the AI scoring multi-step UI plus the loan
/// parameters carried forward from [PengajuanPembiayaanPage].
///
/// The 11 profile fields (Indonesian display labels) are mapped to the
/// BE profile endpoint in the data layer. [sumberPenghasilan] and [aset]
/// are intentionally omitted — BE hardcodes `name_income_type='Working'`
/// and derives collateral from `own_car`/`own_realty`.
///
/// [loanAmount], [loanTenor], [loanPurpose], [loanType] come from the
/// Pengajuan page and are sent to `POST /loans/apply`.
class AiScoringInput extends Equatable {
  // ── Step 1 — identitas ──────────────────────────────────────────────
  final String jenisKelamin;
  final String tanggalLahir;
  final String pendidikan;
  final String statusNikah;

  // ── Step 2 — keseharian ─────────────────────────────────────────────
  final String punyaProperti;
  final String punyaKendaraan;
  final String sumberPenghasilan;
  final String pekerjaan;
  final String lamaBekerja;
  final String lamaNomorHp;

  // ── Step 3 — finansial (3 fields; jumlahPinjaman removed) ───────────
  final String tanggungan;
  final String pendapatan;

  // ── Loan params from PengajuanPembiayaanPage ────────────────────────
  final double loanAmount;
  final int loanTenor;
  final String loanPurpose;
  final String loanType; // 'MURABAHAH' | 'QARDHUL_HASAN'

  const AiScoringInput({
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.pendidikan,
    required this.statusNikah,
    required this.punyaProperti,
    required this.punyaKendaraan,
    required this.sumberPenghasilan,
    required this.pekerjaan,
    required this.lamaBekerja,
    required this.lamaNomorHp,
    required this.tanggungan,
    required this.pendapatan,
    required this.loanAmount,
    required this.loanTenor,
    required this.loanPurpose,
    required this.loanType,
  });

  @override
  List<Object?> get props => [
        jenisKelamin,
        tanggalLahir,
        pendidikan,
        statusNikah,
        punyaProperti,
        punyaKendaraan,
        sumberPenghasilan,
        pekerjaan,
        lamaBekerja,
        lamaNomorHp,
        tanggungan,
        pendapatan,
        loanAmount,
        loanTenor,
        loanPurpose,
        loanType,
      ];
}
