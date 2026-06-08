import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/di/service_locator.dart';
import 'package:koopcare/features/loan/data/models/loan_model.dart';
import 'package:koopcare/features/loan/data/models/installment_model.dart';
import 'package:koopcare/features/loan/presentation/bloc/installment/installment_bloc.dart';
import 'package:koopcare/features/loan/presentation/bloc/installment/installment_event.dart';
import 'package:koopcare/features/loan/presentation/bloc/installment/installment_state.dart';

/// Timeline showing the REAL installment schedule for an active/approved loan,
/// or a pending notice if the loan is still awaiting approval.
///
/// Reads installments from [InstallmentBloc] — the same source the payment
/// detail page uses — so paid status always matches there.
class CicilanTimelineWidget extends StatelessWidget {
  final LoanModel loan;

  const CicilanTimelineWidget({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    if (loan.status == 'PENDING') {
      return _pendingNotice();
    }

    // Fetch the real installments for this loan. A fresh bloc per loan id so
    // switching loans in the selector reloads correctly.
    return BlocProvider<InstallmentBloc>(
      key: ValueKey('installments-${loan.id}'),
      create: (_) => getIt<InstallmentBloc>()..add(FetchInstallments(loan.id)),
      child: BlocBuilder<InstallmentBloc, InstallmentState>(
        builder: (context, state) {
          final installments = switch (state) {
            InstallmentLoaded(:final installments) => installments,
            InstallmentPaying(:final installments) => installments,
            InstallmentPaidSuccess(:final installments) => installments,
            InstallmentProcessing(:final installments) => installments,
            InstallmentMidtransReady(:final installments) => installments,
            InstallmentError(:final installments) => installments,
            _ => const <InstallmentModel>[],
          };

          if (state is InstallmentLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: kHijauTua),
              ),
            );
          }

          if (installments.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Belum ada jadwal cicilan.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF888888),
                ),
              ),
            );
          }

          // The first unpaid installment is the "active" one.
          final firstUnpaidIndex =
              installments.indexWhere((i) => !i.isPaid);

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
              ...List.generate(installments.length, (index) {
                final inst = installments[index];
                final isActive = index == firstUnpaidIndex;
                return _buildTimelineItem(
                  number: inst.installmentNumber,
                  dueDate: DateFormat('dd MMM yyyy').format(inst.dueDate),
                  amount: _formatCurrency(inst.amount),
                  isPaid: inst.isPaid,
                  isActive: isActive,
                  isLast: index == installments.length - 1,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Widget _pendingNotice() {
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

  Widget _buildTimelineItem({
    required int number,
    required String dueDate,
    required String amount,
    required bool isPaid,
    required bool isActive,
    required bool isLast,
  }) {
    // Status drives the label + colors. Paid wins; then the active (next-due)
    // one; everything else is upcoming.
    final String statusLabel;
    final Color statusColor;
    final Color statusBgColor;

    if (isPaid) {
      statusLabel = 'Lunas';
      statusColor = const Color(0xFF2E7D32);
      statusBgColor = const Color(0xFFE8F5E9);
    } else if (isActive) {
      statusLabel = 'Tagihan Aktif';
      statusColor = const Color(0xFFEF6C00);
      statusBgColor = const Color(0xFFFFF3E0);
    } else {
      statusLabel = 'Akan Datang';
      statusColor = const Color(0xFF666666);
      statusBgColor = const Color(0xFFF5F5F5);
    }

    // The node circle: paid = check on green; active = filled; upcoming = pale.
    final Widget nodeChild = isPaid
        ? const Icon(Icons.check_rounded, size: 16, color: kPutih)
        : Text(
            '$number',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? kPutih : kHijauTua,
            ),
          );

    final Color nodeColor = isPaid
        ? const Color(0xFF2E7D32)
        : (isActive ? kHijauTua : const Color(0xFFE8F0D8));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: nodeColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: nodeChild),
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
                color: isActive
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
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
                      color: isPaid
                          ? const Color(0xFF2E7D32)
                          : (isActive ? kHijauTua : const Color(0xFF444444)),
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
}