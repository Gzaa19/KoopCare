import 'package:flutter/material.dart';

import '../../domain/entities/ai_scoring_input.dart';
import '../widgets/ai_dropdown_field.dart';
import '../widgets/ai_scoring_options.dart';
import '../widgets/ai_scoring_route.dart';
import '../widgets/ai_step_scaffold.dart';
import 'ai_scoring_processing_page.dart';

/// Step 3 — fields 9–12: assets, dependents, income, loan amount.
///
/// At submit time we have the full 12-field profile, so we assemble it into
/// an [AiScoringInput] and hand it to [AiScoringProcessingPage].
class AiScoringStep3Page extends StatefulWidget {
  final String jenisKelamin;
  final String tanggalLahir;
  final String pendidikan;
  final String statusNikah;
  final String statusTempat;
  final String transportasi;
  final String pekerjaan;
  final String sumberPenghasilan;

  const AiScoringStep3Page({
    super.key,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.pendidikan,
    required this.statusNikah,
    required this.statusTempat,
    required this.transportasi,
    required this.pekerjaan,
    required this.sumberPenghasilan,
  });

  @override
  State<AiScoringStep3Page> createState() => _AiScoringStep3PageState();
}

class _AiScoringStep3PageState extends State<AiScoringStep3Page> {
  String? _aset;
  String? _tanggungan;
  String? _pendapatan;
  String? _jumlahPinjaman;

  bool get _canNext =>
      _aset != null &&
      _tanggungan != null &&
      _pendapatan != null &&
      _jumlahPinjaman != null;

  void _onSubmit() {
    final input = AiScoringInput(
      jenisKelamin: widget.jenisKelamin,
      tanggalLahir: widget.tanggalLahir,
      pendidikan: widget.pendidikan,
      statusNikah: widget.statusNikah,
      statusTempat: widget.statusTempat,
      transportasi: widget.transportasi,
      pekerjaan: widget.pekerjaan,
      sumberPenghasilan: widget.sumberPenghasilan,
      aset: _aset!,
      tanggungan: _tanggungan!,
      pendapatan: _pendapatan!,
      jumlahPinjaman: _jumlahPinjaman!,
    );
    Navigator.push(
      context,
      slideRoute(AiScoringProcessingPage(input: input)),
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
          number: 9,
          label: 'Aset Lainnya',
          value: _aset,
          options: kAsetLainnya,
          onChanged: (v) => setState(() => _aset = v),
        ),
        AiDropdownField(
          number: 10,
          label: 'Jumlah Tanggungan Keluarga',
          value: _tanggungan,
          options: kTanggungan,
          onChanged: (v) => setState(() => _tanggungan = v),
        ),
        AiDropdownField(
          number: 11,
          label: 'Pendapatan Bulanan',
          value: _pendapatan,
          options: kPendapatan,
          onChanged: (v) => setState(() => _pendapatan = v),
        ),
        AiDropdownField(
          number: 12,
          label: 'Jumlah Pinjaman',
          value: _jumlahPinjaman,
          options: kJumlahPinjaman,
          onChanged: (v) => setState(() => _jumlahPinjaman = v),
        ),
      ],
    );
  }
}
