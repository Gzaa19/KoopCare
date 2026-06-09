import 'package:equatable/equatable.dart';

class AiScoringInput extends Equatable {
  final String jenisKelamin;
  final String tanggalLahir;
  final String pendidikan;
  final String statusNikah;

  final String punyaProperti;
  final String punyaKendaraan;
  final String sumberPenghasilan;
  final String pekerjaan;
  final String lamaBekerja;
  final String lamaNomorHp;

  final String tanggungan;
  final String pendapatan;

  final double loanAmount;
  final int loanTenor;
  final String loanPurpose;
  final String loanType;

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
