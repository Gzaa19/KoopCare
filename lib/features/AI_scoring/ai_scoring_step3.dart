import 'package:flutter/material.dart';
import 'ai_scoring_shared.dart';
import 'ai_scoring_processing.dart';

// ─── Step 3 — Detail Ekonomi (fields 9–12) ───────────────────────────────────
class AiScoringStep3Page extends StatefulWidget {
  // Carried data from steps 1–2
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

  @override
  Widget build(BuildContext context) {
    return AiStepScaffold(
      title: 'Detail Ekonomi',
      currentStep: 3,
      totalSteps: 4,
      canNext: _canNext,
      // Pass ALL collected data forward to ProcessingPage
      onNext: () => Navigator.push(
        context,
        _slideRoute(AiScoringProcessingPage(
          jenisKelamin:     widget.jenisKelamin,
          tanggalLahir:     widget.tanggalLahir,
          pendidikan:       widget.pendidikan,
          statusNikah:      widget.statusNikah,
          statusTempat:     widget.statusTempat,
          transportasi:     widget.transportasi,
          pekerjaan:        widget.pekerjaan,
          sumberPenghasilan: widget.sumberPenghasilan,
          aset:             _aset!,
          tanggungan:       _tanggungan!,
          pendapatan:       _pendapatan!,
          jumlahPinjaman:   _jumlahPinjaman!,
        )),
      ),
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

// ─── Slide route helper ───────────────────────────────────────────────────────
PageRouteBuilder _slideRoute(Widget page) => PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
        return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: anim, child: child));
      },
    );
