import 'package:equatable/equatable.dart';

/// All 12 fields collected across the AI scoring multi-step UI.
///
/// Values are the **Indonesian display labels** the user picked from
/// dropdowns (e.g. `'Laki-laki'`, `'Rp 1–3 juta'`). Mapping to the ML API
/// contract happens in the data layer — domain stays free of API details.
class AiScoringInput extends Equatable {
  // Step 1 — identitas
  final String jenisKelamin;
  final String tanggalLahir;
  final String pendidikan;
  final String statusNikah;

  // Step 2 — keseharian
  final String statusTempat;
  final String transportasi;
  final String pekerjaan;
  final String sumberPenghasilan;

  // Step 3 — finansial
  final String aset;
  final String tanggungan;
  final String pendapatan;
  final String jumlahPinjaman;

  const AiScoringInput({
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.pendidikan,
    required this.statusNikah,
    required this.statusTempat,
    required this.transportasi,
    required this.pekerjaan,
    required this.sumberPenghasilan,
    required this.aset,
    required this.tanggungan,
    required this.pendapatan,
    required this.jumlahPinjaman,
  });

  @override
  List<Object?> get props => [
        jenisKelamin,
        tanggalLahir,
        pendidikan,
        statusNikah,
        statusTempat,
        transportasi,
        pekerjaan,
        sumberPenghasilan,
        aset,
        tanggungan,
        pendapatan,
        jumlahPinjaman,
      ];
}
