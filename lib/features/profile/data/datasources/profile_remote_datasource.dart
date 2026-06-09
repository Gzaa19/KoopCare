import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/profile_model.dart';

class _ProfileEndpoints {
  static const String profile = '/profile';
}

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;

  const ProfileRemoteDataSourceImpl(this._dio);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _ProfileEndpoints.profile,
      );
      final body = response.data;
      if (body == null) {
        throw const ServerException('Respon kosong dari server');
      }
      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const ServerException('Data profil tidak ditemukan');
      }
      return ProfileModel.fromJson(data);
    } on DioException catch (e) {
      final wrapped = e.error;
      if (wrapped is AppException) throw wrapped;
      throw ServerException(e.message ?? 'Kesalahan jaringan');
    }
  }
}
