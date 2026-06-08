import 'package:dio/dio.dart';
import '../models/loan_model.dart';
import '../models/installment_model.dart';

class LoanRepository {
  final Dio _dio;

  LoanRepository({required Dio dio}) : _dio = dio;

  Future<List<LoanModel>> getMemberLoans() async {
    try {
      final response = await _dio.get('/loans');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => LoanModel.fromJson(json)).toList();
      }
      throw Exception(response.data['error'] ?? 'Gagal memuat daftar pinjaman');
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Terjadi kesalahan jaringan';
      throw Exception(msg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<List<InstallmentModel>> getInstallments(int loanId) async {
    try {
      final response = await _dio.get('/loans/$loanId/installments');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        return data.map((j) => InstallmentModel.fromJson(j)).toList();
      }
      throw Exception(response.data['error'] ?? 'Gagal memuat cicilan');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? 'Terjadi kesalahan jaringan');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
   Future<void> payInstallmentFromBalance(int loanId, int installmentId) async {
    try {
      final response = await _dio.post(
        '/loans/$loanId/installments/$installmentId/pay-balance',
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return;
      }
      throw Exception(response.data['error'] ?? 'Pembayaran gagal');
    } on DioException catch (e) {
      // Surfaces 'Saldo tidak mencukupi' / sequential-rule messages verbatim.
      throw Exception(e.response?.data?['error'] ?? 'Terjadi kesalahan jaringan');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  /// Creates a Midtrans Snap session for an installment. Returns the
  /// redirect_url + order_id, mirroring the top-up createTopup shape.
  Future<Map<String, dynamic>> payInstallmentViaMidtrans(
      int loanId, int installmentId) async {
    try {
      final response = await _dio.post(
        '/loans/$loanId/installments/$installmentId/pay-midtrans',
      );
      if (response.statusCode == 201 && response.data['success'] == true) {
        return {
          'order_id': response.data['order_id'],
          'redirect_url': response.data['redirect_url'],
        };
      }
      throw Exception(response.data['error'] ?? 'Gagal membuat pembayaran');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? 'Terjadi kesalahan jaringan');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> getInstallmentPaymentStatus(
      int loanId, int installmentId) async {
    try {
      final response = await _dio.get(
        '/loans/$loanId/installments/$installmentId/payment-status',
      );
      return response.data['status'] as String? ?? 'UNKNOWN';
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? 'Terjadi kesalahan jaringan');
    }
  }
  
}
