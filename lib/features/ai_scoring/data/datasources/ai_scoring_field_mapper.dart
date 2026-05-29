import '../../domain/entities/ai_scoring_input.dart';

/// Translates the Indonesian dropdown labels collected by the UI into the
/// exact field values expected by the ML API.
///
/// Lives in the data layer because it only exists to bridge UI ↔ API
/// contract — the domain entities stay free of those magic strings.
class AiScoringFieldMapper {
  const AiScoringFieldMapper();

  Map<String, dynamic> toMlPayload(AiScoringInput input) {
    final income = _income(input.pendapatan);
    final loanAmount = _loanAmount(input.jumlahPinjaman);
    final children = _children(input.tanggungan);
    const tenor = 12; // default tenor in months
    final annuity = loanAmount / tenor;
    final famMembers = children + 1; // children + self

    return {
      'tenure_months': 1,
      'monthly_income': income,
      'loan_amount': loanAmount,
      'loan_purpose': 'others',
      'existing_loan_balance': 0,
      'has_collateral': _hasCollateral(input.aset),
      'code_gender': _gender(input.jenisKelamin),
      'name_income_type': _incomeType(input.sumberPenghasilan),
      'name_education_type': _education(input.pendidikan),
      'name_family_status': _familyStatus(input.statusNikah),
      'occupation_type': _occupation(input.pekerjaan),
      'flag_own_car': _ownCar(input.transportasi),
      'flag_own_realty': _ownRealty(input.statusTempat),
      'cnt_children': children,
      'cnt_fam_members': famMembers,
      'amt_income_total': income,
      'amt_credit': loanAmount,
      'amt_annuity': annuity,
      'amt_goods_price': loanAmount,
      'days_birth': _daysBirth(input.tanggalLahir),
      'days_employed': -1825, // default ~5 years
      'days_last_phone_change': -180,
    };
  }

  // ── Field-level mappers ────────────────────────────────────────────────

  int _daysBirth(String tanggalLahir) {
    switch (tanggalLahir) {
      case '< 25 tahun':
        return -8000; // ~22 years
      case '25–35 tahun':
        return -10950; // ~30 years
      case '36–45 tahun':
        return -14600; // ~40 years
      case '> 45 tahun':
        return -18250; // ~50 years
      default:
        return -10950;
    }
  }

  String _gender(String jenisKelamin) =>
      jenisKelamin == 'Laki-laki' ? 'M' : 'F';

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

  String _ownRealty(String statusTempat) =>
      statusTempat == 'Milik Pribadi' ? 'Y' : 'N';

  String _ownCar(String transportasi) =>
      (transportasi == 'Mobil' || transportasi == 'Motor & Mobil') ? 'Y' : 'N';

  String _occupation(String pekerjaan) {
    switch (pekerjaan) {
      case 'PNS':
        return 'Core staff';
      case 'Swasta':
        return 'Laborers';
      case 'Wiraswasta':
        return 'Sales staff';
      case 'Freelance':
      case 'Tidak Bekerja':
        return 'Low-skill Laborers';
      default:
        return 'Laborers';
    }
  }

  String _incomeType(String sumberPenghasilan) {
    switch (sumberPenghasilan) {
      case 'Gaji':
      case 'Lainnya':
        return 'Working';
      case 'Usaha':
        return 'Commercial associate';
      case 'Investasi':
        return 'Pensioner';
      default:
        return 'Working';
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

  double _loanAmount(String jumlahPinjaman) {
    switch (jumlahPinjaman) {
      case 'Rp 500.000':
        return 500000;
      case 'Rp 1.000.000':
        return 1000000;
      case 'Rp 3.000.000':
        return 3000000;
      case 'Rp 5.000.000':
        return 5000000;
      case 'Rp 10.000.000':
        return 10000000;
      default:
        return 1000000;
    }
  }

  int _hasCollateral(String aset) =>
      (aset == 'Tanah' || aset == 'Kendaraan') ? 1 : 0;
}
