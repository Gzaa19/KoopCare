import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/router/route_args.dart';
import 'package:koopcare/core/router/route_names.dart';
import 'package:koopcare/core/widgets/app_widgets.dart';
import 'package:koopcare/core/widgets/dashed_border_painter.dart';
import 'package:koopcare/features/auth/domain/entities/auth_user.dart';
import 'package:koopcare/features/loan/domain/entities/loan.dart';
import 'package:koopcare/features/loan/presentation/bloc/loan_bloc.dart';
import 'package:koopcare/features/loan/presentation/bloc/loan_event.dart';
import 'package:koopcare/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:koopcare/features/auth/presentation/bloc/auth_event.dart';

class LoanStatusWidget extends StatelessWidget {
  final Loan? loan;
  final AuthUser? user;

  const LoanStatusWidget({
    super.key,
    required this.loan,
    required this.user,
  });

  String _formatRp(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    if (loan == null) {
      return _buildNoLoanCard(context);
    }
    return _buildActiveLoanCard(context, loan!);
  }

  Widget _buildActiveLoanCard(BuildContext context, Loan loan) {
    final isPending = loan.status == 'PENDING';
    final isApproved = loan.status == 'APPROVED';
    final isActive = loan.status == 'ACTIVE';
    final isPaidOff = loan.status == 'PAID_OFF';
    final isRejected = loan.status == 'REJECTED';

    Color statusColor = const Color(0xFF888888);
    Color statusBgColor = const Color(0xFFEEEEEE);
    String statusLabel = loan.status;

    if (isPending) {
      statusColor = Colors.orange.shade700;
      statusBgColor = Colors.orange.shade50;
      statusLabel = "Menunggu Persetujuan";
    } else if (isApproved) {
      statusColor = Colors.blue.shade700;
      statusBgColor = Colors.blue.shade50;
      statusLabel = "Pinjaman Disetujui";
    } else if (isActive) {
      statusColor = Colors.green.shade700;
      statusBgColor = Colors.green.shade50;
      statusLabel = "Pembiayaan Aktif";
    } else if (isPaidOff) {
      statusColor = Colors.teal.shade700;
      statusBgColor = Colors.teal.shade50;
      statusLabel = "Lunas";
    } else if (isRejected) {
      statusColor = Colors.red.shade700;
      statusBgColor = Colors.red.shade50;
      statusLabel = "Ditolak";
    } else {
      statusLabel = switch (loan.status) {
        'PENDING' => 'Menunggu',
        'APPROVED' => 'Disetujui',
        'ACTIVE' => 'Aktif',
        'PAID_OFF' => 'Lunas',
        'REJECTED' => 'Ditolak',
        _ => loan.status,
      };
    }

    final amountToDisplay = loan.approvedAmount ?? loan.amount;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kPutih,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8F0D8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              Text(
                loan.type == 'MURABAHAH' ? 'Syarik Murabahah' : 'Qardhul Hasan',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: kHijauTua,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Total Kewajiban Pinjaman",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatRp(amountToDisplay),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2E14),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Nomor Kontrak: #${loan.requestNumber.substring(0, (loan.requestNumber.length > 12 ? 12 : loan.requestNumber.length))}",
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 16),
          if (isPending)
            Text(
              "Pengajuan pinjaman Anda saat ini sedang dalam proses review oleh admin koperasi. Mohon tunggu proses analisis kelayakan kredit.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            )
          else if (isApproved)
            Text(
              "Pinjaman Anda telah disetujui! Dana pembiayaan akan dicairkan ke saldo Top Up Utama Anda dalam waktu dekat.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            )
          else if (isActive)
            Text(
              "Tagihan Anda saat ini berjalan aktif. Silakan lakukan pembayaran angsuran tepat waktu untuk menjaga skor kelayakan pinjaman Anda.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            )
          else if (isPaidOff)
            Text(
              "Pembiayaan Anda telah lunas. Terima kasih telah menjaga kelayakan kredit Anda dengan baik.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            )
          else if (isRejected)
            Text(
              "Mohon maaf, pengajuan pembiayaan Anda ditolak oleh admin.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (isActive || isApproved || isPaidOff) {
                  await Navigator.pushNamed(
                    context,
                    RouteNames.pembayaranDetail,
                    arguments: PembayaranDetailArgs(loan: loan),
                  );
                  if (context.mounted) {
                    context.read<LoanBloc>().add(const FetchLoans());
                    context.read<AuthBloc>().add(const AuthProfileRefreshRequested());
                  }
                } else {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isRejected
                            ? "Pengajuan pinjaman Anda ditolak oleh admin."
                            : "Pengajuan pinjaman masih menunggu review admin.",
                      ),
                      backgroundColor: isRejected ? Colors.red.shade800 : kHijauTua,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kHijauTua,
                foregroundColor: kPutih,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                isActive
                    ? 'Detail Pembayaran & Cicilan'
                    : (isApproved
                        ? 'Lihat Kontrak Detail'
                        : (isPaidOff ? 'Detail Pembiayaan' : (isRejected ? 'Ditolak' : 'Menunggu Review'))),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoLoanCard(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: kPutih,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kHijauTua.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_chart_rounded,
                  color: kHijauTua,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ajukan Pembiayaan Syariah',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1D2E14),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Butuh dukungan dana modal usaha secara syariah dengan margin kompetitif? Dapatkan pembiayaan amanah sekarang.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (user?.status != 'ACTIVE') {
                      showAccountInactiveDialog(context);
                    } else {
                      Navigator.pushNamed(
                        context,
                        RouteNames.pengajuan,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kHijauTua,
                    foregroundColor: kPutih,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ajukan Sekarang',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: DashedBorderPainter(
              color: const Color(0xFFB0BDA0),
              radius: 20,
              dashWidth: 6,
              dashSpace: 4,
              strokeWidth: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
