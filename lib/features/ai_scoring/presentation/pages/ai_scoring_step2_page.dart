import 'package:flutter/material.dart';

import '../widgets/ai_dropdown_field.dart';
import '../widgets/ai_scoring_options.dart';
import '../widgets/ai_scoring_route.dart';
import '../widgets/ai_step_scaffold.dart';
import 'ai_scoring_step3_page.dart';

/// Step 2 — fields 5–8: housing, transport, occupation, income source.
class AiScoringStep2Page extends StatefulWidget {
  final String jenisKelamin;
  final String tanggalLahir;
  final String pendidikan;
  final String statusNikah;

  const AiScoringStep2Page({
    super.key,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.pendidikan,
    required this.statusNikah,
  });

  @override
  State<AiScoringStep2Page> createState() => _AiScoringStep2PageState();
}

class _AiScoringStep2PageState extends State<AiScoringStep2Page> {
  String? _statusTempat;
  String? _transportasi;
  String? _pekerjaan;
  String? _sumberPenghasilan;

  bool get _canNext =>
      _statusTempat != null &&
      _transportasi != null &&
      _pekerjaan != null &&
      _sumberPenghasilan != null;

  @override
  Widget build(BuildContext context) {
    return AiStepScaffold(
      title: 'Informasi Pribadi',
      currentStep: 2,
      totalSteps: 4,
      canNext: _canNext,
      onNext: () => Navigator.push(
        context,
        slideRoute(AiScoringStep3Page(
          jenisKelamin: widget.jenisKelamin,
          tanggalLahir: widget.tanggalLahir,
          pendidikan: widget.pendidikan,
          statusNikah: widget.statusNikah,
          statusTempat: _statusTempat!,
          transportasi: _transportasi!,
          pekerjaan: _pekerjaan!,
          sumberPenghasilan: _sumberPenghasilan!,
        )),
      ),
      fields: [
        AiDropdownField(
          number: 5,
          label: 'Status Tempat Tinggal',
          value: _statusTempat,
          options: kStatusTempat,
          onChanged: (v) => setState(() => _statusTempat = v),
        ),
        AiDropdownField(
          number: 6,
          label: 'Alat Transportasi',
          value: _transportasi,
          options: kTransportasi,
          onChanged: (v) => setState(() => _transportasi = v),
        ),
        AiDropdownField(
          number: 7,
          label: 'Jenis Pekerjaan',
          value: _pekerjaan,
          options: kJenisPekerjaan,
          onChanged: (v) => setState(() => _pekerjaan = v),
        ),
        AiDropdownField(
          number: 8,
          label: 'Sumber Penghasilan',
          value: _sumberPenghasilan,
          options: kSumberPenghasilan,
          onChanged: (v) => setState(() => _sumberPenghasilan = v),
        ),
      ],
    );
  }
}
