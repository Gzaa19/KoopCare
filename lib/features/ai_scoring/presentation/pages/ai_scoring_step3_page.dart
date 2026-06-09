import 'package:flutter/material.dart';

import '../../domain/entities/ai_scoring_input.dart';
import '../widgets/ai_dropdown_field.dart';
import '../widgets/ai_scoring_options.dart';
import '../widgets/ai_step_scaffold.dart';
import '../../../../core/router/route_args.dart';
import '../../../../core/router/route_names.dart';

class AiScoringStep3Page extends StatefulWidget {
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

  const AiScoringStep3Page({
    super.key,
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

  @override
  State<AiScoringStep3Page> createState() => _AiScoringStep3PageState();
}

class _AiScoringStep3PageState extends State<AiScoringStep3Page> {
  String? _tanggungan;
  String? _pendapatan;

  bool get _canNext => _tanggungan != null && _pendapatan != null;

  void _onSubmit() {
    final input = AiScoringInput(
      loanAmount: widget.loanAmount,
      loanTenor: widget.loanTenor,
      loanPurpose: widget.loanPurpose,
      loanType: widget.loanType,
      jenisKelamin: widget.jenisKelamin,
      tanggalLahir: widget.tanggalLahir,
      pendidikan: widget.pendidikan,
      statusNikah: widget.statusNikah,
      punyaProperti: widget.punyaProperti,
      punyaKendaraan: widget.punyaKendaraan,
      sumberPenghasilan: widget.sumberPenghasilan,
      pekerjaan: widget.pekerjaan,
      lamaBekerja: widget.lamaBekerja,
      lamaNomorHp: widget.lamaNomorHp,
      tanggungan: _tanggungan!,
      pendapatan: _pendapatan!,
    );
    Navigator.pushNamed(
      context,
      RouteNames.aiProcessing,
      arguments: AiProcessingArgs(input: input),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AiStepScaffold(
      title: 'Detail Ekonomi',
      currentStep: 3,
      totalSteps: 4,
      canNext: _canNext,
      onNext: _onSubmit,
      fields: [
        AiDropdownField(
          number: 11,
          label: 'Jumlah Tanggungan Keluarga',
          value: _tanggungan,
          options: kTanggungan,
          onChanged: (v) => setState(() => _tanggungan = v),
        ),
        AiDropdownField(
          number: 12,
          label: 'Pendapatan Bulanan',
          value: _pendapatan,
          options: kPendapatan,
          onChanged: (v) => setState(() => _pendapatan = v),
        ),
      ],
    );
  }
}
