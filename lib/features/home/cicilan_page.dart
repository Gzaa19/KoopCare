import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/di/service_locator.dart';
import '../../core/app_colors.dart';
import '../../core/router/route_args.dart';
import '../../core/router/route_names.dart';
import '../financial/data/models/loan_model.dart';
import '../financial/presentation/bloc/loan/loan_bloc.dart';
import '../financial/presentation/bloc/loan/loan_event.dart';
import '../financial/presentation/bloc/loan/loan_state.dart';

class DetailPembiayaanPage extends StatelessWidget {
  const DetailPembiayaanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoanBloc>(
      create: (_) => getIt<LoanBloc>()..add(const FetchLoans()),
      child: SafeArea(
        child: BlocBuilder<LoanBloc, LoanState>(
          builder: (context, state) {
            LoanModel? activeLoan;
            if (state is LoanLoaded && state.loans.isNotEmpty) {
              final loans = state.loans;
              // Priority: ACTIVE > APPROVED > PENDING > any
              activeLoan = loans.cast<LoanModel?>().firstWhere(
                (l) => l!.status == 'ACTIVE',
                orElse: () => loans.cast<LoanModel?>().firstWhere(
                  (l) => l!.status == 'APPROVED',
                  orElse: () => loans.cast<LoanModel?>().firstWhere(
                    (l) => l!.status == 'PENDING',
                    orElse: () => loans.first,
                  ),
                ),
              );
            }

            if (activeLoan == null) {
              return const Scaffold(
                backgroundColor: kScaffold,
                body: Center(
                  child: Text(
                    "Belum ada data pembiayaan",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF888888),
                    ),
                  ),
                ),
              );
            }

            final isPending = activeLoan.status == 'PENDING';

            return Scaffold(
              backgroundColor: kScaffold,
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Detail Pembiayaan",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D2E14),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            _buildSummaryCard(activeLoan),
                            const SizedBox(height: 24),

                            _buildTimelineSchedule(activeLoan),
                            const SizedBox(height: 24),

                            if (!isPending) ...[
                              _buildAutodebetRow(),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kHijauTua,
                                    foregroundColor: kPutih,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    RouteNames.pembayaranDetail,
                                    arguments: PembayaranDetailArgs(loan: activeLoan),
                                  ),
                                  child: const Text(
                                    "Bayar Cicilan Sekarang",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 110),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(LoanModel loan) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final loanAmount = loan.approvedAmount ?? loan.amount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kPutih,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8F0D8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0D8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  loan.type == 'MURABAHAH' ? 'Murabahah' : 'Qardhul Hasan',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: kHijauTua,
                  ),
                ),
              ),
              Text(
                '# ${loan.requestNumber.substring(0, (loan.requestNumber.length > 12 ? 12 : loan.requestNumber.length))}',
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Total Kewajiban Pembiayaan',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatter.format(loanAmount),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tenor', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
                  const SizedBox(height: 2),
                  Text('${loan.approvedTenor ?? loan.tenor} Bulan', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Tanggal Persetujuan', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMM yyyy').format(loan.createdAt),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSchedule(LoanModel loan) {
    if (loan.status == 'PENDING') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFE0B2), width: 1),
        ),
        child: const Row(
          children: [
            Icon(Icons.hourglass_empty_rounded, color: Color(0xFFEF6C00)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Pembiayaan sedang diproses. Jadwal cicilan akan aktif setelah disetujui admin.",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE65100),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final monthlyAmount =
        loan.approvedAmount != null &&
            loan.approvedTenor != null &&
            loan.approvedTenor! > 0
        ? loan.approvedAmount! / loan.approvedTenor!
        : 0.0;
    
    final formattedAmount = formatter.format(monthlyAmount);
    final tenor = loan.approvedTenor ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Jadwal Pembayaran Cicilan",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(tenor, (index) {
          final monthNum = index + 1;
          final dueDate = loan.createdAt.add(Duration(days: 30 * monthNum));
          final formattedDate = DateFormat('dd MMM yyyy').format(dueDate);
          final status = monthNum == 1 ? "Pending" : "Due";
          final isCurrent = monthNum == 1;

          return _buildTimelineItem(
            monthNum,
            formattedDate,
            formattedAmount,
            status,
            isCurrent,
            index == tenor - 1,
          );
        }),
      ],
    );
  }

  Widget _buildTimelineItem(int index, String dueDate, String amount, String status, bool isCurrent, bool isLast) {
    // Glowing Neon Badge setup
    final statusColor = switch (status) {
      'Pending' => const Color(0xFFEF6C00), // Due now
      'Due' => const Color(0xFF666666),    // Future
      _ => const Color(0xFF2E7D32),
    };

    final statusBgColor = switch (status) {
      'Pending' => const Color(0xFFFFF3E0),
      'Due' => const Color(0xFFF5F5F5),
      _ => const Color(0xFFE8F5E9),
    };

    final statusLabel = switch (status) {
      'Pending' => 'Tagihan Aktif',
      'Due' => 'Akan Datang',
      _ => 'Lunas',
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCurrent ? kHijauTua : const Color(0xFFE8F0D8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCurrent ? kPutih : kHijauTua,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: const Color(0xFFE8F0D8),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: kPutih,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent
                    ? kHijauTua.withValues(alpha: 0.25)
                    : const Color(0xFFE8F0D8).withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jatuh Tempo: $dueDate',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 0,
                  child: Text(
                    amount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? kHijauTua : const Color(0xFF444444),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAutodebetRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kPutih,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8F0D8).withValues(alpha: 0.5), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.payment_outlined, color: kHijauTua, size: 20),
              SizedBox(width: 12),
              Text(
                "Autodebet Saldo Top Up",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: false,
            onChanged: (v) {},
            activeThumbColor: kHijauTua,
          ),
        ],
      ),
    );
  }
}
