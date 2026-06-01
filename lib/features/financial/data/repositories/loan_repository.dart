import 'package:dio/dio.dart';
import '../models/loan_model.dart';

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
}
