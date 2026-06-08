import 'package:dio/dio.dart';
import '../models/transaction_model.dart';

/// Read-only access to the member's transaction history.
///
/// Flat repository taking [Dio] directly, mirroring [LoanRepository].
class TransactionRepository {
  final Dio _dio;

  TransactionRepository({required Dio dio}) : _dio = dio;

  /// Fetches all transactions for the authenticated member, newest first.
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await _dio.get('/transactions');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      }
      throw Exception(response.data['error'] ?? 'Gagal memuat riwayat transaksi');
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Terjadi kesalahan jaringan';
      throw Exception(msg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
