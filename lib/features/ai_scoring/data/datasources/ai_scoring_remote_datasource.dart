import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/ai_scoring_input.dart';
import '../models/ai_scoring_result_model.dart';
import 'ai_scoring_field_mapper.dart';

class _MlEndpoints {
  static const String predict = '/predict';
}

abstract class AiScoringRemoteDataSource {
  Future<AiScoringResultModel> predict(AiScoringInput input);
}

class AiScoringRemoteDataSourceImpl implements AiScoringRemoteDataSource {
  final Dio _dio;
  final AiScoringFieldMapper _mapper;

  const AiScoringRemoteDataSourceImpl(this._dio, this._mapper);

  @override
  Future<AiScoringResultModel> predict(AiScoringInput input) async {
    try {
      final payload = _mapper.toMlPayload(input);
      final response = await _dio.post<Map<String, dynamic>>(
        _MlEndpoints.predict,
        data: payload,
      );
      final body = response.data;
      if (body == null) {
        throw const ServerException('Respon kosong dari ML API');
      }
      return AiScoringResultModel.fromJson(body);
    } on DioException catch (e) {
      // ErrorInterceptor already wrapped the error into AppException.
      final wrapped = e.error;
      if (wrapped is AppException) throw wrapped;
      throw ServerException(e.message ?? 'Kesalahan jaringan ke ML API');
    }
  }
}
