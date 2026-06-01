import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the general info page opens (or on pull-to-refresh) to load the
/// member's personal profile from the backend.
class ProfileFetchRequested extends ProfileEvent {
  const ProfileFetchRequested();
}
