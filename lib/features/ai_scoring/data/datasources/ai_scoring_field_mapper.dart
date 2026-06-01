import '../../domain/entities/ai_scoring_input.dart';

/// Translates the Indonesian dropdown labels collected by the UI into the
/// exact field values expected by `PUT /api/v1/mobile/profile`.
///
/// Lives in the data layer — domain entities stay free of API details.
///
/// Fields intentionally omitted:
/// - `sumberPenghasilan` / `aset` — BE hardcodes `name_income_type='Working'`
///   and derives collateral from `own_car`/`own_realty`. No column in DB.
class AiScoringFieldMapper {
  const AiScoringFieldMapper();

  /// Returns the body for `PUT /api/v1/mobile/profile`.
  Map<String, dynamic> toProfilePayload(AiScoringInput input) {
    return {
      'code_gender': _gender(input.jenisKelamin),
      'birth_date': _birthDate(input.tanggalLahir),
      'education': _education(input.pendidikan),
      'family_status': _familyStatus(input.statusNikah),
      'income_type': _incomeType(input.sumberPenghasilan),
      'own_realty': _ownRealty(input.punyaProperti),
      'own_car': _ownCar(input.punyaKendaraan),
      'occupation': _occupation(input.pekerjaan),
      'children_count': _children(input.tanggungan),
      'family_members': _children(input.tanggungan) + 1, // children + self
      'monthly_income': _income(input.pendapatan),
      'employed_days': _employedDays(input.lamaBekerja),
      'last_phone_change_days': _lastPhoneChange(input.lamaNomorHp),
    };
  }

  /// Returns the body for `POST /api/v1/mobile/loans/apply`.
  Map<String, dynamic> toLoanPayload(AiScoringInput input) {
    return {
      'amount': input.loanAmount,
      'tenor': input.loanTenor,
      'purpose': input.loanPurpose,
      'type': input.loanType,
    };
  }

  // ── Profile field mappers ──────────────────────────────────────────────

  String _gender(String jenisKelamin) =>
      jenisKelamin == 'Laki-laki' ? 'M' : 'F';

  /// Converts an age-range label to an approximate ISO-8601 birth date.
  String _birthDate(String tanggalLahir) {
    final now = DateTime.now();
    final int approxAge;
    switch (tanggalLahir) {
      case '< 25 tahun':
        approxAge = 22;
      case '25–35 tahun':
        approxAge = 30;
      case '36–45 tahun':
        approxAge = 40;
      case '> 45 tahun':
        approxAge = 50;
      default:
        approxAge = 30;
    }
    final birth = DateTime(now.year - approxAge, now.month, now.day);
    return '${birth.year.toString().padLeft(4, '0')}'
        '-${birth.month.toString().padLeft(2, '0')}'
        '-${birth.day.toString().padLeft(2, '0')}';
  }

  String _education(String pendidikan) {
    switch (pendidikan) {
      case 'SD':
      case 'SMP':
        return 'Lower secondary';
      case 'SMA/SMK':
        return 'Secondary / secondary special';
      case 'D3':
        return 'Incomplete higher';
      case 'S1':
        return 'Higher education';
      case 'S2/S3':
        return 'Academic degree';
      default:
        return 'Secondary / secondary special';
    }
  }

  String _familyStatus(String statusNikah) {
    switch (statusNikah) {
      case 'Menikah':
        return 'Married';
      case 'Belum Menikah':
        return 'Single / not married';
      case 'Cerai':
        return 'Separated';
      default:
        return 'Single / not married';
    }
  }

  String _incomeType(String sumber) {
    switch (sumber) {
      case 'Karyawan (Working)':
        return 'Working';
      case 'Pengusaha / Wiraswasta (Commercial Associate)':
        return 'Commercial associate';
      case 'Ibu Rumah Tangga (State Servant)':
        return 'State servant';
      case 'Pensiunan (Pensioner)':
        return 'Pensioner';
      default:
        return 'Working';
    }
  }

  bool _ownRealty(String punyaProperti) => punyaProperti == 'Ya';

  bool _ownCar(String punyaKendaraan) => punyaKendaraan == 'Ya';

  String _occupation(String pekerjaan) {
    switch (pekerjaan) {
      case 'Buruh (Laborers)':
        return 'Laborers';
      case 'Staf Inti (Core Staff)':
        return 'Core staff';
      case 'Staf Penjualan (Sales Staff)':
        return 'Sales staff';
      case 'Manajer (Managers)':
        return 'Managers';
      case 'Driver':
        return 'Drivers';
      case 'Staf Akuntansi (Accountants)':
        return 'Accountants';
      case 'Petugas Medis (Medicine Staff)':
        return 'Medicine staff';
      case 'Staf Keamanan (Security Staff)':
        return 'Security staff';
      case 'Pekerja Masak (Cooking Staff)':
        return 'Cooking staff';
      case 'Pekerja Kebersihan (Cleaning Staff)':
        return 'Cleaning staff';
      case 'Agen Properti (Realty Agents)':
        return 'Realty agents';
      case 'Pekerja HR (HR Staff)':
        return 'HR staff';
      case 'IT Staff':
        return 'IT staff';
      case 'Sekretaris (Secretaries)':
        return 'Secretaries';
      case 'Penjaga (Waiters/Barmen Staff)':
        return 'Waiters/barmen staff';
      case 'Pekerja Swasta Rendah (Low-skill Laborers)':
        return 'Low-skill Laborers';
      default:
        return 'Laborers';
    }
  }

  int _children(String tanggungan) {
    if (tanggungan == '5+') return 5;
    return int.tryParse(tanggungan) ?? 0;
  }

  double _income(String pendapatan) {
    switch (pendapatan) {
      case '< Rp 1.000.000':
        return 800000;
      case 'Rp 1–3 juta':
        return 2000000;
      case 'Rp 3–5 juta':
        return 4000000;
      case 'Rp 5–7 juta':
        return 6000000;
      case '> Rp 7 juta':
        return 9000000;
      default:
        return 2000000;
    }
  }

  int _employedDays(String lamaBekerja) {
    switch (lamaBekerja) {
      case '< 1 tahun':
        return -180; // 6 months
      case '1–3 tahun':
        return -730; // 2 years
      case '3–5 tahun':
        return -1460; // 4 years
      case '> 5 tahun':
        return -2190; // 6 years
      default:
        return -1825; // 5 years
    }
  }

  int _lastPhoneChange(String lamaNomorHp) {
    switch (lamaNomorHp) {
      case '< 6 bulan':
        return -90; // 3 months
      case '6–12 bulan':
        return -270; // 9 months
      case '1–2 tahun':
        return -540; // 1.5 years
      case '> 2 tahun':
        return -1095; // 3 years
      default:
        return -180; // 6 months
    }
  }
}
