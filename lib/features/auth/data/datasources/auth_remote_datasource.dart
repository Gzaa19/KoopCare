import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/auth_user_model.dart';

class _AuthEndpoints {
  static const String login = '/login';
  static const String register = '/register';
  static const String otpRequest = '/otp/request';
  static const String otpVerify = '/otp/verify';
  static const String resetPin = '/reset-pin';
}

typedef AuthSession = ({String token, AuthUserModel user});

abstract class AuthRemoteDataSource {
  Future<AuthSession> login({required String identifier, required String pin});

  Future<AuthSession> register({
    required String fullName,
    required String phone,
    required String nik,
    required String pin,
    String? email,
    int monthlyIncome = 0,
  });

  Future<void> requestOtp(String identifier);

  Future<void> verifyOtp({required String identifier, required String otp});

  Future<void> resetPin({
    required String identifier,
    required String otp,
    required String newPin,
  });

  Future<AuthUserModel> getProfile();

  Future<void> submitKyc({
    required String ktpFilePath,
    required String selfieFilePath,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthSession> login({required String identifier, required String pin}) {
    return _postSession(_AuthEndpoints.login, {
      'identifier': identifier,
      'pin': pin,
    });
  }

  @override
  Future<AuthSession> register({
    required String fullName,
    required String phone,
    required String nik,
    required String pin,
    String? email,
    int monthlyIncome = 0,
  }) {
    return _postSession(_AuthEndpoints.register, {
      'full_name': fullName,
      'phone': phone,
      'nik': nik,
      'pin': pin,
      if (email != null && email.isNotEmpty) 'email': email,
      'monthly_income': monthlyIncome,
    });
  }

  @override
  Future<void> requestOtp(String identifier) {
    return _postVoid(_AuthEndpoints.otpRequest, {'identifier': identifier});
  }

  @override
  Future<void> verifyOtp({required String identifier, required String otp}) {
    return _postVoid(_AuthEndpoints.otpVerify, {
      'identifier': identifier,
      'otp': otp,
    });
  }

  @override
  Future<void> resetPin({
    required String identifier,
    required String otp,
    required String newPin,
  }) {
    return _postVoid(_AuthEndpoints.resetPin, {
      'identifier': identifier,
      'otp': otp,
      'newPin': newPin,
    });
  }

  @override
  Future<AuthUserModel> getProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/profile');
      final body = response.data;
      if (body == null) {
        throw const ServerException('Respon kosong dari server');
      }
      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const ServerException('Data profil tidak ditemukan');
      }
      return AuthUserModel.fromProfileJson(data);
    } on DioException catch (e) {
      final wrapped = e.error;
      if (wrapped is AppException) throw wrapped;
      throw ServerException(e.message ?? 'Kesalahan jaringan');
    }
  }

  @override
  Future<void> submitKyc({
    required String ktpFilePath,
    required String selfieFilePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'ktp_photo': await MultipartFile.fromFile(
          ktpFilePath,
          filename: 'ktp.jpg',
        ),
        'selfie_photo': await MultipartFile.fromFile(
          selfieFilePath,
          filename: 'selfie.jpg',
        ),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/kyc/submit',
        data: formData,
      );

      final body = response.data;
      if (body == null || body['success'] != true) {
        throw ServerException(
          (body?['error'] as String?) ?? 'Gagal mengirim data KYC',
        );
      }
    } on DioException catch (e) {
      final wrapped = e.error;
      if (wrapped is AppException) throw wrapped;
      throw ServerException(e.message ?? 'Kesalahan jaringan saat upload KYC');
    }
  }

  Future<AuthSession> _postSession(
    String path,
    Map<String, dynamic> data,
  ) async {
    final body = await _post(path, data);
    return (
      token: body['token'] as String,
      user: AuthUserModel.fromJson(body['user'] as Map<String, dynamic>),
    );
  }

  Future<void> _postVoid(String path, Map<String, dynamic> data) async {
    await _post(path, data);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      final body = response.data;
      if (body == null) {
        throw const ServerException('Respon kosong dari server');
      }
      return body;
    } on DioException catch (e) {
      final wrapped = e.error;
      if (wrapped is AppException) throw wrapped;
      throw ServerException(e.message ?? 'Kesalahan jaringan');
    }
  }
}
