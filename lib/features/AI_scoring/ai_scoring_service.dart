import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── ML API Response ──────────────────────────────────────────────────────────

class AiScoringResult {
  final String recommendation; // 'LAYAK' or 'TIDAK_LAYAK'
  final double probDefault;    // probability of default, e.g. 0.13
  final String riskLevel;      // 'low', 'medium', 'high'
  final int aiScore;           // derived: 0-100

  const AiScoringResult({
    required this.recommendation,
    required this.probDefault,
    required this.riskLevel,
    required this.aiScore,
  });

  bool get isApproved => recommendation == 'LAYAK';

  factory AiScoringResult.fromJson(Map<String, dynamic> json) {
    final rec = json['recommendation'] as String? ?? 'TIDAK_LAYAK';
    final prob = (json['prob_default'] as num?)?.toDouble() ?? 0.5;
    final risk = json['risk_level'] as String? ?? 'high';
    // Mirror backend logic: LAYAK=80, TIDAK_LAYAK=20
    final score = rec == 'LAYAK' ? 80 : 20;
    return AiScoringResult(
      recommendation: rec,
      probDefault: prob,
      riskLevel: risk,
      aiScore: score,
    );
  }
}

// ─── Field Mappers ────────────────────────────────────────────────────────────
// Converts the Flutter dropdown display values (Indonesian)
// into the exact field values the ML API expects.

int _mapAgeRange(String tanggalLahir) {
  // API expects days_birth as negative integer (days before today)
  switch (tanggalLahir) {
    case '< 25 tahun':   return -8000;   // ~22 years
    case '25–35 tahun':  return -10950;  // ~30 years
    case '36–45 tahun':  return -14600;  // ~40 years
    case '> 45 tahun':   return -18250;  // ~50 years
    default:             return -10950;
  }
}

String _mapGender(String jenisKelamin) =>
    jenisKelamin == 'Laki-laki' ? 'M' : 'F';

String _mapEducation(String pendidikan) {
  switch (pendidikan) {
    case 'SD':    return 'Lower secondary';
    case 'SMP':   return 'Lower secondary';
    case 'SMA/SMK': return 'Secondary / secondary special';
    case 'D3':    return 'Incomplete higher';
    case 'S1':    return 'Higher education';
    case 'S2/S3': return 'Academic degree';
    default:      return 'Secondary / secondary special';
  }
}

String _mapFamilyStatus(String statusNikah) {
  switch (statusNikah) {
    case 'Menikah':        return 'Married';
    case 'Belum Menikah':  return 'Single / not married';
    case 'Cerai':          return 'Separated';
    default:               return 'Single / not married';
  }
}

String _mapRealty(String statusTempat) {
  // Own property = Y
  return statusTempat == 'Milik Pribadi' ? 'Y' : 'N';
}

String _mapCar(String transportasi) {
  return (transportasi == 'Mobil' || transportasi == 'Motor & Mobil') ? 'Y' : 'N';
}

String _mapOccupation(String pekerjaan) {
  switch (pekerjaan) {
    case 'PNS':          return 'Core staff';
    case 'Swasta':       return 'Laborers';
    case 'Wiraswasta':   return 'Sales staff';
    case 'Freelance':    return 'Low-skill Laborers';
    case 'Tidak Bekerja': return 'Low-skill Laborers';
    default:             return 'Laborers';
  }
}

String _mapIncomeType(String sumberPenghasilan) {
  switch (sumberPenghasilan) {
    case 'Gaji':      return 'Working';
    case 'Usaha':     return 'Commercial associate';
    case 'Investasi': return 'Pensioner';
    case 'Lainnya':   return 'Working';
    default:          return 'Working';
  }
}

int _mapChildren(String tanggungan) {
  if (tanggungan == '5+') return 5;
  return int.tryParse(tanggungan) ?? 0;
}

double _mapIncome(String pendapatan) {
  switch (pendapatan) {
    case '< Rp 1.000.000':  return 800000;
    case 'Rp 1–3 juta':     return 2000000;
    case 'Rp 3–5 juta':     return 4000000;
    case 'Rp 5–7 juta':     return 6000000;
    case '> Rp 7 juta':     return 9000000;
    default:                 return 2000000;
  }
}

double _mapLoanAmount(String jumlahPinjaman) {
  switch (jumlahPinjaman) {
    case 'Rp 500.000':   return 500000;
    case 'Rp 1.000.000': return 1000000;
    case 'Rp 3.000.000': return 3000000;
    case 'Rp 5.000.000': return 5000000;
    case 'Rp 10.000.000': return 10000000;
    default:              return 1000000;
  }
}

String _mapAssetToCollateral(String aset) {
  // Has collateral if they own property-like assets
  return (aset == 'Tanah' || aset == 'Kendaraan') ? '1' : '0';
}

// ─── AI Scoring Service ───────────────────────────────────────────────────────

class AiScoringService {
  static const String _mlApiUrl =
      'https://koopcare-mlops-credit-scoring-api-production.up.railway.app/predict';

  /// Calls the Railway ML API directly — no backend, no auth needed.
  ///
  /// Takes all 12 collected form fields from the Flutter AI scoring steps.
  static Future<AiScoringResult> predict({
    // Step 1
    required String jenisKelamin,
    required String tanggalLahir,
    required String pendidikan,
    required String statusNikah,
    // Step 2
    required String statusTempat,
    required String transportasi,
    required String pekerjaan,
    required String sumberPenghasilan,
    // Step 3
    required String aset,
    required String tanggungan,
    required String pendapatan,
    required String jumlahPinjaman,
  }) async {
    final income      = _mapIncome(pendapatan);
    final loanAmount  = _mapLoanAmount(jumlahPinjaman);
    final children    = _mapChildren(tanggungan);
    const tenor       = 12; // default tenor in months
    final annuity     = loanAmount / tenor;
    final famMembers  = children + 1; // children + self

    final payload = {
      'tenure_months':          1,
      'monthly_income':         income,
      'loan_amount':            loanAmount,
      'loan_purpose':           'others',
      'existing_loan_balance':  0,
      'has_collateral':         int.parse(_mapAssetToCollateral(aset)),
      'code_gender':            _mapGender(jenisKelamin),
      'name_income_type':       _mapIncomeType(sumberPenghasilan),
      'name_education_type':    _mapEducation(pendidikan),
      'name_family_status':     _mapFamilyStatus(statusNikah),
      'occupation_type':        _mapOccupation(pekerjaan),
      'flag_own_car':           _mapCar(transportasi),
      'flag_own_realty':        _mapRealty(statusTempat),
      'cnt_children':           children,
      'cnt_fam_members':        famMembers,
      'amt_income_total':       income,
      'amt_credit':             loanAmount,
      'amt_annuity':            annuity,
      'amt_goods_price':        loanAmount,
      'days_birth':             _mapAgeRange(tanggalLahir),
      'days_employed':          -1825,  // default ~5 years
      'days_last_phone_change': -180,
    };

    final response = await http.post(
      Uri.parse(_mlApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return AiScoringResult.fromJson(data);
    }

    throw Exception('ML API error: ${response.statusCode} ${response.body}');
  }
}
