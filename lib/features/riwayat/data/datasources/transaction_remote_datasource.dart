import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions();
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final Dio dio;

  const TransactionRemoteDataSourceImpl(this.dio);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await dio.get('/transactions');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      }
      throw ServerException(
        response.data['error'] ?? 'Gagal memuat riwayat transaksi',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Terjadi kesalahan jaringan';
      throw ServerException(msg, statusCode: e.response?.statusCode);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
