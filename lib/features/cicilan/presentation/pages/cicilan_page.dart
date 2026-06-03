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
}
