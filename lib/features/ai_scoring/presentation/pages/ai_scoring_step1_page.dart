import 'package:flutter/material.dart';

import '../widgets/ai_dropdown_field.dart';
import '../widgets/ai_scoring_options.dart';
import '../widgets/ai_scoring_route.dart';
import '../widgets/ai_step_scaffold.dart';
import 'ai_scoring_step2_page.dart';

/// Step 1 — fields 1–4: gender, age range, education, marital status.
///
/// Pure form, no backend call. Values are passed forward via the next page's
/// constructor — when all 12 fields are collected, the processing page will
/// fire the prediction.
class AiScoringStep1Page extends StatefulWidget {
  const AiScoringStep1Page({super.key});

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
      onNext: () => Navigator.push(
        context,
        slideRoute(AiScoringStep2Page(
          jenisKelamin: _jenisKelamin!,
          tanggalLahir: _tanggalLahir!,
          pendidikan: _pendidikan!,
          statusNikah: _statusNikah!,
        )),
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
