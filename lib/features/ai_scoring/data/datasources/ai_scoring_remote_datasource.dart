import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/ai_scoring_input.dart';
import '../models/ai_scoring_result_model.dart';
import 'ai_scoring_field_mapper.dart';

abstract class AiScoringRemoteDataSource {
  Future<AiScoringResultModel> predict(AiScoringInput input);
}

class AiScoringRemoteDataSourceImpl implements AiScoringRemoteDataSource {
  final Dio _dio;
  final AiScoringFieldMapper _mapper;

  static const int _maxPolls = 10;

  static const Duration _pollInterval = Duration(seconds: 2);

  const AiScoringRemoteDataSourceImpl(this._dio, this._mapper);

  @override
  Future<AiScoringResultModel> predict(AiScoringInput input) async {
    await _updateProfile(input);

    final loanId = await _applyLoan(input);

    return _pollLoanResult(loanId);
  }

  Future<void> _updateProfile(AiScoringInput input) async {
    try {
      final payload = _mapper.toProfilePayload(input);
      final response = await _dio.put<Map<String, dynamic>>(
        '/profile',
        data: payload,
      );
      final body = response.data;
      if (body == null || body['success'] != true) {
        throw const ServerException('Gagal memperbarui profil');
      }
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<int> _applyLoan(AiScoringInput input) async {
    try {
      final payload = _mapper.toLoanPayload(input);
      final response = await _dio.post<Map<String, dynamic>>(
        '/loans/apply',
        data: payload,
      );
      final body = response.data;
      if (body == null || body['success'] != true) {
        throw const ServerException('Gagal mengajukan pinjaman');
      }
      final loanId = body['loanId'] as int?;
      if (loanId == null) {
        throw const ServerException('Loan ID tidak ditemukan dalam respons');
      }
      return loanId;
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<AiScoringResultModel> _pollLoanResult(int loanId) async {
    for (var attempt = 0; attempt < _maxPolls; attempt++) {
      await Future.delayed(_pollInterval);
      try {
        final response = await _dio.get<Map<String, dynamic>>(
          '/loans/$loanId',
        );
        final body = response.data;
        if (body == null || body['success'] != true) continue;

        final data = body['data'] as Map<String, dynamic>?;
        if (data == null) continue;

        if (data['ai_recommendation'] != null) {
          return AiScoringResultModel.fromJson(loanId, data);
        }
      } on DioException catch (e) {
        _rethrow(e);
      }
    }
    throw const ServerException(
      'Sistem AI membutuhkan waktu lebih lama. Silakan cek status pinjaman nanti.',
    );
  }

  Never _rethrow(DioException e) {
    final wrapped = e.error;
    if (wrapped is AppException) throw wrapped;
    throw ServerException(e.message ?? 'Kesalahan jaringan');
  }
}
