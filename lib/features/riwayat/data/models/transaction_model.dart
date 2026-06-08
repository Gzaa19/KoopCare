import 'package:flutter/material.dart';
import 'package:koopcare/core/app_colors.dart';

/// A single financial transaction record for a member.
///
/// Maps the backend `transactions` table rows returned by
/// `GET /transactions` (newest first).
class TransactionModel {
  final int id;
  final String type; // SETORAN_WAJIB | TOP_UP | BAYAR_ANGSURAN | TARIK_TUNAI | PENARIKAN_SALDO | ...
  final double amount;
  final String? description;
  final String? referenceId;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
    this.referenceId,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: (json['type'] ?? '').toString(),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      description: json['description'],
      referenceId: json['reference_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  // ── Presentation helpers ──────────────────────────────────────────────────
  // Credit/debit split mirrors the admin dashboard's TodayTransactions widget
  // and the backend transactionService, so the app and admin agree.

  static const Set<String> _creditTypes = {
    'SETORAN_WAJIB',
    'TOP_UP',
  };

  static const Set<String> _debitTypes = {
    'TARIK_TUNAI',
    'BAYAR_ANGSURAN',
    'PENARIKAN_SALDO',
  };

  /// True if this transaction adds to the member's balance.
  bool get isCredit => _creditTypes.contains(type);

  /// True if this transaction reduces the member's balance.
  /// Unknown types fall through to debit-styling as a safe default.
  bool get isDebit => !isCredit;

  /// Indonesian label shown to the user instead of the raw enum.
  String get label => switch (type) {
        'SETORAN_WAJIB' => 'Setoran Wajib',
        'TOP_UP' => 'Top Up Saldo',
        'BAYAR_ANGSURAN' => 'Pembayaran Cicilan',
        'TARIK_TUNAI' => 'Tarik Tunai',
        'PENARIKAN_SALDO' => 'Penarikan Saldo',
        _ => _titleCase(type),
      };

  /// Icon per transaction type, mirroring the admin dashboard.
  IconData get icon => switch (type) {
        'SETORAN_WAJIB' => Icons.savings_outlined,
        'TOP_UP' => Icons.add_card_outlined,
        'BAYAR_ANGSURAN' => Icons.receipt_long_outlined,
        'TARIK_TUNAI' => Icons.payments_outlined,
        'PENARIKAN_SALDO' => Icons.account_balance_wallet_outlined,
        _ => Icons.swap_horiz_rounded,
      };

  Color get amountColor =>
      isCredit ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

  Color get iconColor => isCredit ? const Color(0xFF2E7D32) : kHijauTua;

  Color get iconBgColor =>
      isCredit ? const Color(0xFFE8F5E9) : const Color(0xFFEFF3E6);

  /// Sign prefix for the amount, e.g. "+" or "−".
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
