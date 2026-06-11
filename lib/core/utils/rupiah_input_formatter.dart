import 'package:flutter/services.dart';

/// TextInputFormatter yang memformat angka menjadi format mata uang Indonesia.
/// Contoh: user ketik "5000000" → tampil "5.000.000"
///
/// Nilai bersih (tanpa titik) bisa diambil dengan:
///   RupiahInputFormatter.rawValue(controller.text)
class RupiahInputFormatter extends TextInputFormatter {
  RupiahInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Ambil hanya digit dari teks baru
    final digitsOnly = newValue.text.replaceAll('.', '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Batasi input agar tidak overflow (max 15 digit = ratusan triliun)
    if (digitsOnly.length > 15) return oldValue;

    // Format dengan titik sebagai separator ribuan
    final formatted = _formatWithDots(digitsOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _formatWithDots(String digitsOnly) {
    final buf = StringBuffer();
    final len = digitsOnly.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buf.write('.');
      buf.write(digitsOnly[i]);
    }
    return buf.toString();
  }

  /// Ambil nilai numerik murni (tanpa titik) dari teks yang sudah diformat.
  /// Mengembalikan 0 jika teks kosong atau bukan angka valid.
  static int rawValue(String formattedText) {
    final clean = formattedText.replaceAll('.', '');
    return int.tryParse(clean) ?? 0;
  }

  /// Ambil nilai double dari teks yang sudah diformat.
  static double rawValueDouble(String formattedText) {
    return rawValue(formattedText).toDouble();
  }
}
