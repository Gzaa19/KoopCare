import 'package:flutter/material.dart';

import '../widgets/ai_dropdown_field.dart';
import '../widgets/ai_scoring_options.dart';
import '../widgets/ai_step_scaffold.dart';
import '../../../../core/router/route_args.dart';
import '../../../../core/router/route_names.dart';

/// Step 2 — fields 5–7: housing, transport, occupation.
///
/// `sumberPenghasilan` removed — BE hardcodes `name_income_type='Working'`.
class AiScoringStep2Page extends StatefulWidget {
  final double loanAmount;
  final int loanTenor;
  final String loanPurpose;
  final String loanType;
  final String jenisKelamin;
  final String tanggalLahir;
  final String pendidikan;
  final String statusNikah;

  const AiScoringStep2Page({
    super.key,
    required this.loanAmount,
    required this.loanTenor,
    required this.loanPurpose,
    required this.loanType,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.pendidikan,
    required this.statusNikah,
  });

  @override
  State<AiScoringStep2Page> createState() => _AiScoringStep2PageState();
}

class _AiScoringStep2PageState extends State<AiScoringStep2Page> {
  String? _punyaProperti;
  String? _punyaKendaraan;
  String? _sumberPenghasilan;
  String? _pekerjaan;
  String? _lamaBekerja;
  String? _lamaNomorHp;

  bool get _canNext =>
      _punyaProperti != null &&
      _punyaKendaraan != null &&
      _sumberPenghasilan != null &&
      _pekerjaan != null &&
      _lamaBekerja != null &&
      _lamaNomorHp != null;

  @override
  Widget build(BuildContext context) {
    return AiStepScaffold(
      title: 'Informasi Pribadi',
      currentStep: 2,
      totalSteps: 4,
      canNext: _canNext,
      onNext: () => Navigator.pushNamed(
        context,
        RouteNames.aiStep3,
        arguments: AiStep3Args(
          loanAmount: widget.loanAmount,
          loanTenor: widget.loanTenor,
          loanPurpose: widget.loanPurpose,
          loanType: widget.loanType,
          jenisKelamin: widget.jenisKelamin,
          tanggalLahir: widget.tanggalLahir,
          pendidikan: widget.pendidikan,
          statusNikah: widget.statusNikah,
          punyaProperti: _punyaProperti!,
          punyaKendaraan: _punyaKendaraan!,
          sumberPenghasilan: _sumberPenghasilan!,
          pekerjaan: _pekerjaan!,
          lamaBekerja: _lamaBekerja!,
          lamaNomorHp: _lamaNomorHp!,
        ),
      ),
      fields: [
        AiDropdownField(
          number: 5,
          label: 'Punya Properti',
          value: _punyaProperti,
          options: kPunyaProperti,
          onChanged: (v) => setState(() => _punyaProperti = v),
        ),
        AiDropdownField(
          number: 6,
          label: 'Punya Kendaraan',
          value: _punyaKendaraan,
          options: kPunyaKendaraan,
          onChanged: (v) => setState(() => _punyaKendaraan = v),
        ),
        AiDropdownField(
          number: 7,
          label: 'Sumber Penghasilan (Jenis Pekerjaan)',
          value: _sumberPenghasilan,
          options: kSumberPenghasilan,
          onChanged: (v) => setState(() => _sumberPenghasilan = v),
        ),
        AiDropdownField(
          number: 8,
          label: 'Pekerjaan Spesifik',
          value: _pekerjaan,
          options: kJenisPekerjaan,
          onChanged: (v) => setState(() => _pekerjaan = v),
        ),
        AiDropdownField(
          number: 9,
          label: 'Lama Bekerja',
          value: _lamaBekerja,
          options: kLamaBekerja,
          onChanged: (v) => setState(() => _lamaBekerja = v),
        ),
        AiDropdownField(
          number: 10,
          label: 'Lama Menggunakan Nomor HP',
          value: _lamaNomorHp,
          options: kLamaNomorHp,
          onChanged: (v) => setState(() => _lamaNomorHp = v),
        ),
      ],
    );
  }
}
