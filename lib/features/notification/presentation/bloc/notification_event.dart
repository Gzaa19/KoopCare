import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch the latest notifications from the server.
class NotificationsFetchRequested extends NotificationEvent {
  const NotificationsFetchRequested();
}

/// Fetch the unread count from the server.
class NotificationUnreadCountFetchRequested extends NotificationEvent {
  const NotificationUnreadCountFetchRequested();
}

/// Mark a single notification as read.
class NotificationMarkReadRequested extends NotificationEvent {
  final int notificationId;
  const NotificationMarkReadRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read.
class NotificationMarkAllReadRequested extends NotificationEvent {
  const NotificationMarkAllReadRequested();
}

/// Start background polling for new notifications (foreground only).
class NotificationPollingStarted extends NotificationEvent {
  const NotificationPollingStarted();
}

/// Stop background polling.
class NotificationPollingStopped extends NotificationEvent {
  const NotificationPollingStopped();
}
