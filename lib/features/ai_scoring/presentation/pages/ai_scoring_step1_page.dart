import 'package:flutter/material.dart';

import '../widgets/ai_dropdown_field.dart';
import '../widgets/ai_scoring_options.dart';
import '../widgets/ai_step_scaffold.dart';
import '../../../../core/router/route_args.dart';
import '../../../../core/router/route_names.dart';

class AiScoringStep1Page extends StatefulWidget {
  final double loanAmount;
  final int loanTenor;
  final String loanPurpose;
  final String loanType;

  const AiScoringStep1Page({
    super.key,
    required this.loanAmount,
    required this.loanTenor,
    required this.loanPurpose,
    required this.loanType,
  });

  @override
  State<AiScoringStep1Page> createState() => _AiScoringStep1PageState();
}

class _AiScoringStep1PageState extends State<AiScoringStep1Page> {
  String? _jenisKelamin;
  String? _tanggalLahir;
  String? _pendidikan;
  String? _statusNikah;

  bool get _canNext =>
      _jenisKelamin != null &&
      _tanggalLahir != null &&
      _pendidikan != null &&
      _statusNikah != null;

  @override
  Widget build(BuildContext context) {
    return AiStepScaffold(
      title: 'Informasi Pribadi',
      currentStep: 1,
      totalSteps: 4,
      canNext: _canNext,
      onNext: () => Navigator.pushNamed(
        context,
        RouteNames.aiStep2,
        arguments: AiStep2Args(
          loanAmount: widget.loanAmount,
          loanTenor: widget.loanTenor,
          loanPurpose: widget.loanPurpose,
          loanType: widget.loanType,
          jenisKelamin: _jenisKelamin!,
          tanggalLahir: _tanggalLahir!,
          pendidikan: _pendidikan!,
          statusNikah: _statusNikah!,
        ),
      ),
      fields: [
        AiDropdownField(
          number: 1,
          label: 'Jenis Kelamin',
          value: _jenisKelamin,
          options: kJenisKelamin,
          onChanged: (v) => setState(() => _jenisKelamin = v),
        ),
        AiDropdownField(
          number: 2,
          label: 'Tanggal Lahir',
          value: _tanggalLahir,
          options: kTanggalLahir,
          onChanged: (v) => setState(() => _tanggalLahir = v),
        ),
        AiDropdownField(
          number: 3,
          label: 'Pendidikan Terakhir',
          value: _pendidikan,
          options: kPendidikan,
          onChanged: (v) => setState(() => _pendidikan = v),
        ),
        AiDropdownField(
          number: 4,
          label: 'Status Pernikahan',
          value: _statusNikah,
          options: kStatusNikah,
          onChanged: (v) => setState(() => _statusNikah = v),
        ),
      ],
    );
  }
}
