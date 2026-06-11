import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:koopcare/core/app_colors.dart';

class Transaction extends Equatable {
  final int id;
  final String type;
  final double amount;
  final String? description;
  final String? referenceId;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
    this.referenceId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, type, amount, description, referenceId, createdAt];

  static const Set<String> _creditTypes = {
    'SETORAN_WAJIB',
    'TOP_UP',
  };

  bool get isCredit => _creditTypes.contains(type);

  bool get isDebit => !isCredit;

  String get label => switch (type) {
        'SETORAN_WAJIB' => 'Setoran Wajib',
        'TOP_UP' => 'Top Up Saldo',
        'BAYAR_ANGSURAN' => 'Pembayaran Cicilan',
        'TARIK_TUNAI' => 'Tarik Tunai',
        'PENARIKAN_SALDO' => 'Penarikan Saldo',
        'TRANSFER' => 'Transfer',
        _ => _titleCase(type),
      };

  IconData get icon => switch (type) {
        'SETORAN_WAJIB' => Icons.savings_outlined,
        'TOP_UP' => Icons.add_card_outlined,
        'BAYAR_ANGSURAN' => Icons.receipt_long_outlined,
        'TARIK_TUNAI' => Icons.payments_outlined,
        'PENARIKAN_SALDO' => Icons.account_balance_wallet_outlined,
        'TRANSFER' => Icons.swap_horiz_rounded,
        _ => Icons.swap_horiz_rounded,
      };

  Color get amountColor =>
      isCredit ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

  Color get iconColor => isCredit ? const Color(0xFF2E7D32) : kHijauTua;

  Color get iconBgColor =>
      isCredit ? const Color(0xFFE8F5E9) : const Color(0xFFEFF3E6);

  String get sign => isCredit ? '+' : '−';

  static String _titleCase(String raw) {
    if (raw.isEmpty) return raw;
    return raw
        .toLowerCase()
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
