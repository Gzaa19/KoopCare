import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

// ─── Dropdown option data ─────────────────────────────────────────────────────
const List<String> kJenisKelamin    = ['Laki-laki', 'Perempuan'];
const List<String> kTanggalLahir    = ['< 25 tahun', '25–35 tahun', '36–45 tahun', '> 45 tahun'];
const List<String> kPendidikan      = ['SD', 'SMP', 'SMA/SMK', 'D3', 'S1', 'S2/S3'];
const List<String> kStatusNikah     = ['Belum Menikah', 'Menikah', 'Cerai'];
const List<String> kStatusTempat    = ['Milik Pribadi', 'Kontrak/Sewa', 'Rumah Orang Tua', 'Dinas'];
const List<String> kTransportasi    = ['Motor', 'Mobil', 'Motor & Mobil', 'Tidak Ada'];
const List<String> kJenisPekerjaan  = ['PNS', 'Swasta', 'Wiraswasta', 'Freelance', 'Tidak Bekerja'];
const List<String> kSumberPenghasilan = ['Gaji', 'Usaha', 'Investasi', 'Lainnya'];
const List<String> kAsetLainnya     = ['Tidak Ada', 'TV DST', 'Elektronik', 'Tanah', 'Kendaraan'];
const List<String> kTanggungan      = ['0', '1', '2', '3', '4', '5+'];
const List<String> kPendapatan      = ['< Rp 1.000.000', 'Rp 1–3 juta', 'Rp 3–5 juta', 'Rp 5–7 juta', '> Rp 7 juta'];
const List<String> kJumlahPinjaman  = ['Rp 500.000', 'Rp 1.000.000', 'Rp 3.000.000', 'Rp 5.000.000', 'Rp 10.000.000'];

// ─── Shared step header ───────────────────────────────────────────────────────
class AiStepHeader extends StatelessWidget {
  final String title;
  final int currentStep;
  final int totalSteps;
  final String subtitle;

  const AiStepHeader({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    this.subtitle =
        'Mari mulai dengan melengkapi detail identitas Anda. Data ini membantu kami membangun profil risiko awal secara akurat.',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Steps row + animated bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Steps',
                style: TextStyle(
                    fontSize: 12, color: Color(0xFF888888))),
            Text('$currentStep/$totalSteps',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333))),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: currentStep / totalSteps),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => LinearProgressIndicator(
            value: v,
            minHeight: 6,
            color: kHijauTua,
            backgroundColor: const Color(0xFFDDDDDD),
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        const SizedBox(height: 16),

        // Subtitle
        Text(
          subtitle,
          style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              height: 1.5),
        ),
      ],
    );
  }
}

// ─── Shared numbered dropdown field ──────────────────────────────────────────
class AiDropdownField extends StatelessWidget {
  final int number;
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const AiDropdownField({
    super.key,
    required this.number,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number. ${label.toUpperCase()}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF444444),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: kFieldBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: value != null
                  ? kHijauTua.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: const SizedBox.shrink(),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF888888), size: 22),
              items: options
                  .map((o) => DropdownMenuItem(
                        value: o,
                        child: Text(o,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1A1A1A))),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared page scaffold ─────────────────────────────────────────────────────
class AiStepScaffold extends StatelessWidget {
  final String title;
  final int currentStep;
  final int totalSteps;
  final List<Widget> fields;
  final VoidCallback? onNext;
  final bool canNext;

  const AiStepScaffold({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    required this.fields,
    required this.onNext,
    this.canNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: Color(0xFF333333)),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AiStepHeader(
                      title: title,
                      currentStep: currentStep,
                      totalSteps: totalSteps,
                    ),
                    const SizedBox(height: 20),

                    // Grey fields container
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: fields
                            .expand((f) => [f, const SizedBox(height: 16)])
                            .toList()
                          ..removeLast(),
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // Fixed bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canNext ? onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kHijauTua,
                    disabledBackgroundColor: const Color(0xFFB8C8A0),
                    foregroundColor: kPutih,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Selanjutnya',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
