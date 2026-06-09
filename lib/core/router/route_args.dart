import 'package:koopcare/features/loan/domain/entities/loan.dart';
import 'package:koopcare/features/ai_scoring/domain/entities/ai_scoring_input.dart';
import 'package:koopcare/features/ai_scoring/domain/entities/ai_scoring_result.dart';

class Register2Args {
  final String nama;
  final String noWa;
  final String nik;

  const Register2Args({
    required this.nama,
    required this.noWa,
    required this.nik,
  });
}

class CreatePinArgs {
  final String fullName;
  final String noWa;
  final String nik;
  final String ktpFilePath;
  final String selfieFilePath;

  const CreatePinArgs({
    required this.fullName,
    required this.noWa,
    required this.nik,
    required this.ktpFilePath,
    required this.selfieFilePath,
  });
}

class PinSuccessArgs {
  final String? ktpFilePath;
  final String? selfieFilePath;

  const PinSuccessArgs({this.ktpFilePath, this.selfieFilePath});
}

class PembayaranDetailArgs {
  final Loan? loan;

  const PembayaranDetailArgs({this.loan});
}

class AiStep1Args {
  final double loanAmount;
  final int loanTenor;
  final String loanPurpose;
  final String loanType;

  const AiStep1Args({
    required this.loanAmount,
    required this.loanTenor,
    required this.loanPurpose,
    required this.loanType,
  });
}

class AiStep2Args {
  final double loanAmount;
  final int loanTenor;
  final String loanPurpose;
  final String loanType;
  final String jenisKelamin;
  final String tanggalLahir;
  final String pendidikan;
  final String statusNikah;

  const AiStep2Args({
    required this.loanAmount,
    required this.loanTenor,
    required this.loanPurpose,
    required this.loanType,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.pendidikan,
    required this.statusNikah,
  });
}

class AiStep3Args {
  final double loanAmount;
  final int loanTenor;
  final String loanPurpose;
  final String loanType;
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

  const AiStep3Args({
    required this.loanAmount,
    required this.loanTenor,
    required this.loanPurpose,
    required this.loanType,
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
  });
}

class AiProcessingArgs {
  final AiScoringInput input;

  const AiProcessingArgs({required this.input});
}

class AiScoringResultArgs {
  final AiScoringInput input;
  final AiScoringResult result;

  const AiScoringResultArgs({required this.input, required this.result});
}
