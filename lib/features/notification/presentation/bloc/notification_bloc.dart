import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// Manages notification list state and a foreground polling timer.
///
/// Polls every 30 seconds for unread count changes.
/// When unread count increases, a local push notification is shown.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;
  final NotificationService _notificationService;

  Timer? _pollTimer;
  int _lastKnownUnreadCount = 0;

  NotificationBloc({
    required NotificationRepository repository,
    required NotificationService notificationService,
  })  : _repository = repository,
        _notificationService = notificationService,
        super(const NotificationState()) {
    on<NotificationsFetchRequested>(_onFetchRequested);
    on<NotificationUnreadCountFetchRequested>(_onUnreadCountFetchRequested);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationMarkAllReadRequested>(_onMarkAllRead);
    on<NotificationPollingStarted>(_onPollingStarted);
    on<NotificationPollingStopped>(_onPollingStopped);
  }

  Future<void> _onFetchRequested(
    NotificationsFetchRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.status == NotificationStatus.initial) {
      emit(state.copyWith(status: NotificationStatus.loading));
    }

    final result = await _repository.getNotifications();
    result.fold(
      (failure) => emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: failure.message,
      )),
      (notifications) {
        final unreadCount = notifications.where((n) => !n.isRead).length;

        // Show local push notification when new unreads appear.
        if (_lastKnownUnreadCount > 0 ||
            state.status != NotificationStatus.initial) {
          if (unreadCount > _lastKnownUnreadCount) {
            final newest = notifications
                .where((n) => !n.isRead)
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            if (newest.isNotEmpty) {
              _notificationService.showNotification(
                id: newest.first.id,
                title: newest.first.title,
                body: newest.first.message,
              );
            }
          }
        }
        _lastKnownUnreadCount = unreadCount;

        emit(state.copyWith(
          status: NotificationStatus.loaded,
          notifications: notifications,
          unreadCount: unreadCount,
        ));
      },
    );
  }

  Future<void> _onUnreadCountFetchRequested(
    NotificationUnreadCountFetchRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.getUnreadCount();
    result.fold(
      (_) {}, // ignore failures silently for polling
      (count) {
        if (_lastKnownUnreadCount > 0 || state.status != NotificationStatus.initial) {
          if (count > _lastKnownUnreadCount) {
            _notificationService.showNotification(
              id: 0,
              title: 'Notifikasi Baru',
              body: 'Anda memiliki notifikasi baru di aplikasi.',
            );
          }
        }
        _lastKnownUnreadCount = count;
        emit(state.copyWith(unreadCount: count));
      },
    );
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.markAsRead(event.notificationId);
    result.fold(
      (_) {},
      (_) {
        final updated = state.notifications
            .map((n) => n.id == event.notificationId
                ? n.copyWith(isRead: true)
                : n)
            .toList();
        final unread = updated.where((n) => !n.isRead).length;
        _lastKnownUnreadCount = unread;
        emit(state.copyWith(
          notifications: updated,
          unreadCount: unread,
        ));
      },
    );
  }

  Future<void> _onMarkAllRead(
    NotificationMarkAllReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.markAllRead();
    result.fold(
      (_) {},
      (_) {
        final updated = state.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        _lastKnownUnreadCount = 0;
        emit(state.copyWith(
          notifications: updated,
          unreadCount: 0,
        ));
      },
    );
  }

  void _onPollingStarted(
    NotificationPollingStarted event,
    Emitter<NotificationState> emit,
  ) {
    _pollTimer?.cancel();
    // Initial fetch.
    add(const NotificationUnreadCountFetchRequested());
    // Poll every 30 seconds.
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      add(const NotificationUnreadCountFetchRequested());
    });
  }

  void _onPollingStopped(
    NotificationPollingStopped event,
    Emitter<NotificationState> emit,
  ) {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
