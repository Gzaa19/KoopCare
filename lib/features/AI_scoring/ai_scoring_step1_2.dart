import 'package:flutter/material.dart';
import 'ai_scoring_shared.dart';
import 'ai_scoring_step3.dart';

// ─── Step 1 — Informasi Pribadi (fields 1–4) ──────────────────────────────────
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
        _slideRoute(AiScoringStep2Page(
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

// ─── Step 2 — Informasi Pribadi (fields 5–8) ──────────────────────────────────
class AiScoringStep2Page extends StatefulWidget {
  // Data passed from step 1
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
        _slideRoute(AiScoringStep3Page(
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

// ─── Slide-from-right route helper ───────────────────────────────────────────
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
