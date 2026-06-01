import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/notification_model.dart';

/// Talks to the backend notification endpoints.
abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(int id);
  Future<void> markAllRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;

  const NotificationRemoteDataSourceImpl(this._dio);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/notifications');
      final body = response.data;
      if (body == null) {
        throw const ServerException('Respon kosong dari server');
      }
      final list = body['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final wrapped = e.error;
      if (wrapped is AppException) throw wrapped;
      throw ServerException(e.message ?? 'Kesalahan jaringan');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/notifications/unread-count');
      final body = response.data;
      if (body == null) return 0;
      return body['count'] as int? ?? 0;
    } on DioException catch (e) {
      final wrapped = e.error;
      if (wrapped is AppException) throw wrapped;
      throw ServerException(e.message ?? 'Kesalahan jaringan');
    }
  }

  @override
  Future<void> markAsRead(int id) async {
    try {
      await _dio.patch<Map<String, dynamic>>('/notifications/$id/read');
    } on DioException catch (e) {
      final wrapped = e.error;
      if (wrapped is AppException) throw wrapped;
      throw ServerException(e.message ?? 'Kesalahan jaringan');
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await _dio.patch<Map<String, dynamic>>('/notifications/read-all');
    } on DioException catch (e) {
      final wrapped = e.error;
      if (wrapped is AppException) throw wrapped;
      throw ServerException(e.message ?? 'Kesalahan jaringan');
    }
  }
}

