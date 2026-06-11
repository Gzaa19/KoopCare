import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/widgets/app_widgets.dart';
import 'package:koopcare/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:koopcare/features/ai_scoring/domain/entities/ai_scoring_input.dart';
import 'package:koopcare/features/ai_scoring/domain/entities/ai_scoring_result.dart';

class AiScoringResultPage extends StatelessWidget {
  final AiScoringInput input;
  final AiScoringResult result;

  const AiScoringResultPage({
    super.key,
    required this.input,
    required this.result,
  });

  String _formatRupiah(double v) {
    final s = v.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp. ${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final approved = result.isApproved;
    final scoreColor = approved ? kHijauTua : Colors.redAccent;

    final authState = context.read<AuthBloc>().state;
    final userName = authState.user?.name ?? 'Pengaju KoopCare';
    final userPhone = authState.user?.phone ?? '-';

    final successProb = (1.0 - result.probDefault) * 100;
    final failProb = result.probDefault * 100;

    return Scaffold(
      backgroundColor: kScaffold,
      body: Stack(
        children: [
          const AmbientOrbBackground(),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: (approved ? const Color(0xFFE8F0D8) : const Color(0xFFFFEBEE)).withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: (approved ? const Color(0xFFDDE5C8) : const Color(0xFFFFCDD2)).withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: approved
                                        ? [kHijauMuda, kHijauTua]
                                        : [const Color(0xFFEF5350), const Color(0xFFC62828)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (approved ? kHijauTua : const Color(0xFFC62828)).withValues(alpha: 0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  approved ? Icons.check_rounded : Icons.close_rounded,
                                  color: kPutih,
                                  size: 36,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Text(
                            approved ? 'Evaluasi Kelayakan Layak' : 'Belum Dapat Disetujui',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: scoreColor,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            approved
                                ? 'Sistem AI menilai Anda memiliki riwayat kredit dan profil finansial yang sehat.'
                                : 'Sistem AI menilai profil kredit Anda belum memenuhi kriteria kelayakan saat ini.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF666666),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),

                          _buildCard(
                            title: 'Data Diri Pengaju',
                            children: [
                              _infoRow('Nama Lengkap', userName),
                              _infoRow('Nomor WhatsApp', userPhone),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildCard(
                            title: 'Detail Pengajuan Pembiayaan',
                            children: [
                              _infoRow('Nominal Pengajuan', _formatRupiah(input.loanAmount)),
                              _infoRow('Tenor Pengajuan', '${input.loanTenor} Bulan'),
                              _infoRow('Tujuan Pembiayaan', input.loanPurpose),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildCard(
                            title: 'Analisis Kelayakan Kredit AI',
                            children: [
                              _infoRow(
                                'Probabilitas Berhasil Bayar',
                                '${successProb.toStringAsFixed(1)}%',
                                valueColor: kHijauTua,
                              ),
                              _infoRow(
                                'Probabilitas Gagal Bayar',
                                '${failProb.toStringAsFixed(1)}%',
                                valueColor: Colors.redAccent,
                              ),
                              _infoRow('Level Risiko Kredit', result.riskLevel.label),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [kHijauMuda, kHijauTua],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kHijauTua.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(
                          child: Text(
                            'Kembali ke Beranda',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: kPutih,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.psychology_outlined, color: kHijauTua, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'Laporan Hasil AI',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2E14),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kPutih,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2E14),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: valueColor ?? const Color(0xFF1D2E14),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
