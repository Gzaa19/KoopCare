import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class GeneralInfoPage extends StatelessWidget {
  const GeneralInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) =>
          getIt<ProfileBloc>()..add(const ProfileFetchRequested()),
      child: const _GeneralInfoView(),
    );
  }
}

class _GeneralInfoView extends StatelessWidget {
  const _GeneralInfoView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
      appBar: AppBar(
        backgroundColor: kScaffold,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF1D2E14),
        title: const Text(
          'General Info',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2E14),
          ),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          switch (state.status) {
            case ProfileStatus.loading:
            case ProfileStatus.initial:
              return const AppLoadingIndicator();
            case ProfileStatus.error:
              return AppErrorView(
                message: state.errorMessage ?? 'Gagal memuat profil',
                onRetry: () => context
                    .read<ProfileBloc>()
                    .add(const ProfileFetchRequested()),
              );
            case ProfileStatus.loaded:
              return _ProfileContent(profile: state.profile!);
          }
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final Profile profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: kHijauTua,
      onRefresh: () async {
        context.read<ProfileBloc>().add(const ProfileFetchRequested());
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _buildIdentityHeader(),
          const SizedBox(height: 20),
          _buildSection(
            title: 'DATA PRIBADI',
            rows: [
              _InfoRow('Nama Lengkap', profile.fullName),
              _InfoRow('NIK', _maskNik(profile.nik)),
              _InfoRow('Jenis Kelamin', _genderLabel(profile.codeGender)),
              _InfoRow('Tanggal Lahir', _formatDate(profile.birthDate)),
              _InfoRow('Status Keluarga', _orDash(profile.familyStatus)),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'KONTAK',
            rows: [
              _InfoRow('No. Telepon', profile.phone),
              _InfoRow('Email', _orDash(profile.email)),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'PEKERJAAN & EKONOMI',
            rows: [
              _InfoRow('Pekerjaan', _orDash(profile.occupation)),
              _InfoRow('Pendidikan', _orDash(profile.education)),
              _InfoRow(
                'Pendapatan Bulanan',
                profile.monthlyIncome != null
                    ? _formatRp(profile.monthlyIncome!)
                    : '—',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'KELUARGA & ASET',
            rows: [
              _InfoRow('Jumlah Anak', _orDashNum(profile.childrenCount)),
              _InfoRow('Anggota Keluarga', _orDashNum(profile.familyMembers)),
              _InfoRow('Memiliki Kendaraan', _boolLabel(profile.ownCar)),
              _InfoRow('Memiliki Properti', _boolLabel(profile.ownRealty)),
            ],
          ),
          if (profile.createdAt != null) ...[
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Terdaftar sejak ${_formatDate(profile.createdAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIdentityHeader() {
    final firstLetter =
        profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'U';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F0D8), kScaffold],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8F0D8), width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPutih,
              border:
                  Border.all(color: kHijauTua.withValues(alpha: 0.15), width: 2),
            ),
            child: Center(
              child: Text(
                firstLetter,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: kHijauTua,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2E14),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: kHijauTua.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: kHijauTua,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _statusLabel(profile.status),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: kHijauTua,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<_InfoRow> rows}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF888888),
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8F0D8), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(rows.length, (index) {
              final row = rows[index];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            row.label,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 5,
                          child: Text(
                            row.value,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D2E14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < rows.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF0F3EA),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  String _orDash(String? value) =>
      (value == null || value.isEmpty) ? '—' : value;

  String _orDashNum(int? value) => value?.toString() ?? '—';

  String _boolLabel(bool value) => value ? 'Ya' : 'Tidak';

  String _genderLabel(String? code) {
    switch (code) {
      case 'M':
        return 'Laki-laki';
      case 'F':
        return 'Perempuan';
      default:
        return '—';
    }
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Anggota Aktif';
      case 'INACTIVE':
        return 'Tidak Aktif';
      case 'PENDING':
        return 'Menunggu Verifikasi';
      default:
        return status;
    }
  }

  String _maskNik(String nik) {
    if (nik.length <= 4) return nik.isEmpty ? '—' : nik;
    final visible = nik.substring(nik.length - 4);
    return '${'•' * (nik.length - 4)}$visible';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  String _formatRp(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
}

class _InfoRow {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);
}
