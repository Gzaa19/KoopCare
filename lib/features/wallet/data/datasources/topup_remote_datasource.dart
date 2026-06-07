import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/topup_model.dart';

class _TopupEndpoints {
  static const String create = '/topup';
  static String status(String orderId) => '/topup/$orderId/status';
}

abstract class TopupRemoteDataSource {
  Future<TopupSessionModel> createTopup(int amount);
  Future<String> getTopupStatus(String orderId);
}

class TopupRemoteDataSourceImpl implements TopupRemoteDataSource {
  final Dio _dio;

  const TopupRemoteDataSourceImpl(this._dio);

  @override
  Future<TopupSessionModel> createTopup(int amount) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _TopupEndpoints.create,
        data: {'amount': amount},
      );
      final body = response.data;
      if (body == null) {
        throw const ServerException('Respon kosong dari server');
      }
      return TopupSessionModel.fromJson(body);
    } on DioException catch (e) {
      final wrapped = e.error;
      if (wrapped is AppException) throw wrapped;
      throw ServerException(e.message ?? 'Kesalahan jaringan');
    }
  }

  @override
  Future<String> getTopupStatus(String orderId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _TopupEndpoints.status(orderId),
      );
      final body = response.data;
      if (body == null) {
        throw const ServerException('Respon kosong dari server');
      }
      return body['status'] as String? ?? 'UNKNOWN';
    } on DioException catch (e) {
      final wrapped = e.error;
      if (wrapped is AppException) throw wrapped;
      throw ServerException(e.message ?? 'Kesalahan jaringan');
    }
  }
}
