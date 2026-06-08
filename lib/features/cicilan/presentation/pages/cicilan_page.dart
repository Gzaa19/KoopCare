import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/core/di/service_locator.dart';
import 'package:koopcare/core/router/route_args.dart';
import 'package:koopcare/core/router/route_names.dart';
import 'package:koopcare/features/loan/data/models/loan_model.dart';
import 'package:koopcare/features/loan/presentation/bloc/loan_bloc.dart';
import 'package:koopcare/features/loan/presentation/bloc/loan_event.dart';
import 'package:koopcare/features/loan/presentation/bloc/loan_state.dart';
import 'package:koopcare/features/cicilan/presentation/widgets/cicilan_summary_card.dart';
import 'package:koopcare/features/cicilan/presentation/widgets/cicilan_timeline_widget.dart';
import 'package:koopcare/features/cicilan/presentation/widgets/cicilan_autodebet_row.dart';

class DetailPembiayaanPage extends StatefulWidget {
  const DetailPembiayaanPage({super.key});

  @override
  State<DetailPembiayaanPage> createState() => _DetailPembiayaanPageState();
}

class _DetailPembiayaanPageState extends State<DetailPembiayaanPage> {
  // The loan the user is currently viewing. Null = use the default pick.
  int? _selectedLoanId;

  String _statusLabel(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Aktif';
      case 'APPROVED':
        return 'Disetujui';
      case 'PENDING':
        return 'Menunggu';
      case 'PAID_OFF':
        return 'Lunas';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return status;
    }
  }

  // Default pick when the user hasn't chosen: ACTIVE > APPROVED > PENDING > first.
  LoanModel _defaultLoan(List<LoanModel> loans) {
    return loans.cast<LoanModel?>().firstWhere(
          (l) => l!.status == 'ACTIVE',
          orElse: () => loans.cast<LoanModel?>().firstWhere(
                (l) => l!.status == 'APPROVED',
                orElse: () => loans.cast<LoanModel?>().firstWhere(
                      (l) => l!.status == 'PENDING',
                      orElse: () => loans.first,
                    ),
              ),
        )!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoanBloc>(
      create: (_) => getIt<LoanBloc>()..add(const FetchLoans()),
      child: SafeArea(
        child: BlocBuilder<LoanBloc, LoanState>(
          builder: (context, state) {
            if (state is! LoanLoaded || state.loans.isEmpty) {
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

            final loans = state.loans;

            // Resolve the loan to display: the user's selection if still valid,
            // otherwise the default priority pick.
            LoanModel activeLoan = _defaultLoan(loans);
            if (_selectedLoanId != null) {
              activeLoan = loans.cast<LoanModel?>().firstWhere(
                    (l) => l!.id == _selectedLoanId,
                    orElse: () => activeLoan,
                  )!;
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

                            // Loan selector — only shown when there's more than one.
                            if (loans.length > 1) ...[
                              _LoanSelector(
                                loans: loans,
                                selected: activeLoan,
                                statusLabel: _statusLabel,
                                onChanged: (l) =>
                                    setState(() => _selectedLoanId = l.id),
                              ),
                              const SizedBox(height: 20),
                            ],

                            CicilanSummaryCard(loan: activeLoan),
                            const SizedBox(height: 24),

                            CicilanTimelineWidget(loan: activeLoan),
                            const SizedBox(height: 24),

                            if (!isPending) ...[
                              const CicilanAutodebetRow(),
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
                                    arguments:
                                        PembayaranDetailArgs(loan: activeLoan),
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
}

// ── Loan selector dropdown ────────────────────────────────────────────────────
class _LoanSelector extends StatelessWidget {
  final List<LoanModel> loans;
  final LoanModel selected;
  final String Function(String) statusLabel;
  final ValueChanged<LoanModel> onChanged;

  const _LoanSelector({
    required this.loans,
    required this.selected,
    required this.statusLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: kPutih,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              size: 20, color: kHijauTua),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selected.id,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF888888)),
                items: loans.map((l) {
                  return DropdownMenuItem<int>(
                    value: l.id,
                    child: Text(
                      '${l.requestNumber} • ${statusLabel(l.status)}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D2E14),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (id) {
                  if (id == null) return;
                  final l = loans.firstWhere((e) => e.id == id);
                  onChanged(l);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}