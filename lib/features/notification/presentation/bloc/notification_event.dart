import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsFetchRequested extends NotificationEvent {
  const NotificationsFetchRequested();
}

class NotificationUnreadCountFetchRequested extends NotificationEvent {
  const NotificationUnreadCountFetchRequested();
}

class NotificationMarkReadRequested extends NotificationEvent {
  final int notificationId;
  const NotificationMarkReadRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class NotificationMarkAllReadRequested extends NotificationEvent {
  const NotificationMarkAllReadRequested();
}

class NotificationPollingStarted extends NotificationEvent {
  const NotificationPollingStarted();
}

class NotificationPollingStopped extends NotificationEvent {
  const NotificationPollingStopped();
}
