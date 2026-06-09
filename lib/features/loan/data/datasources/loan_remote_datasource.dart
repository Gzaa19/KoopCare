import 'package:dio/dio.dart';

import '../models/installment_model.dart';
import '../models/loan_model.dart';

abstract class LoanRemoteDataSource {
  Future<List<LoanModel>> getMemberLoans();
  Future<List<InstallmentModel>> getInstallments(int loanId);
  Future<void> payInstallmentFromBalance(int loanId, int installmentId);
  Future<Map<String, dynamic>> payInstallmentViaMidtrans(
      int loanId, int installmentId);
  Future<String> getInstallmentPaymentStatus(int loanId, int installmentId);
}

class LoanRemoteDataSourceImpl implements LoanRemoteDataSource {
  final Dio _dio;

  LoanRemoteDataSourceImpl(this._dio);

  @override
  Future<List<LoanModel>> getMemberLoans() async {
    final response = await _dio.get('/loans');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((json) => LoanModel.fromJson(json)).toList();
    }
    throw Exception(response.data['error'] ?? 'Gagal memuat daftar pinjaman');
  }

  @override
  Future<List<InstallmentModel>> getInstallments(int loanId) async {
    final response = await _dio.get('/loans/$loanId/installments');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((j) => InstallmentModel.fromJson(j)).toList();
    }
    throw Exception(response.data['error'] ?? 'Gagal memuat cicilan');
  }

  @override
  Future<void> payInstallmentFromBalance(int loanId, int installmentId) async {
    final response = await _dio.post(
      '/loans/$loanId/installments/$installmentId/pay-balance',
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return;
    }
    throw Exception(response.data['error'] ?? 'Pembayaran gagal');
  }

  @override
  Future<Map<String, dynamic>> payInstallmentViaMidtrans(
      int loanId, int installmentId) async {
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
  }

  @override
  Future<String> getInstallmentPaymentStatus(
      int loanId, int installmentId) async {
    final response = await _dio.get(
      '/loans/$loanId/installments/$installmentId/payment-status',
    );
    return response.data['status'] as String? ?? 'UNKNOWN';
  }
}
