import 'package:flutter/material.dart';
import 'package:koopcare/core/app_colors.dart';

/// A tile displaying details of a single loan installment (status, date, amount, active selection)
/// originally extracted from `pembayaran_detail_page.dart`.
class CicilanItemTile extends StatelessWidget {
  final Map<String, dynamic> cicilan;
  final bool paid;
  final bool selectable;
  final bool selected;
  final VoidCallback? onTap;

  const CicilanItemTile({
    super.key,
    required this.cicilan,
    required this.paid,
    required this.selectable,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hardLocked = cicilan['locked'] as bool;
    final double opacity = (paid || !selectable) ? 0.55 : 1.0;

    return Opacity(
      opacity: opacity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: kPutih,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? kHijauTua : Colors.transparent,
            width: selected ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? kHijauTua.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: selectable ? onTap : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  // Radio check box or paid check indicator
                  if (paid)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: kHijauTua,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: kPutih,
                        size: 14,
                      ),
                    )
                  else
                    IgnorePointer(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Center(
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? kHijauTua
                                    : const Color(0xFFBDBDBD),
                                width: 2,
                              ),
                            ),
                            child: selected
                                ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: kHijauTua,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(width: 12),

                  // Monthly index bubble
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: paid
                          ? kHijauTua.withValues(alpha: 0.1)
                          : selected
                          ? const Color(0xFFE8F0D8)
                          : const Color(0xFFF5F7F2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${cicilan['no']}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: paid
                              ? kPutih
                              : selected
                              ? kHijauTua
                              : const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Date + label
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cicilan['date'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: hardLocked
                                ? const Color(0xFF999999)
                                : const Color(0xFF1D2E14),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          paid
                              ? 'Sudah Dibayar'
                              : hardLocked
                              ? 'Belum Jatuh Tempo'
                              : 'Jatuh Tempo',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: paid
                                ? kHijauTua
                                : hardLocked
                                ? const Color(0xFF999999)
                                : const Color(0xFFCC5500),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount + status badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        cicilan['amount'] as String,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: hardLocked
                              ? const Color(0xFF999999)
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (paid)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'LUNAS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        )
                      else if (cicilan['status'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: cicilan['statusBg'] as Color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cicilan['status'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: cicilan['statusColor'] as Color,
								),
							  ),
							),
						],
					  ),
					],
				  ),
				),
			  ),
			),
		  ),
		);
	  }
}
