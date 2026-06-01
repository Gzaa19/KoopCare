import 'package:equatable/equatable.dart';

import '../../domain/entities/profile.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final Profile? profile;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  const ProfileState.initial() : this();

  const ProfileState.loading() : this(status: ProfileStatus.loading);

  const ProfileState.loaded(Profile profile)
    : this(status: ProfileStatus.loaded, profile: profile);

  const ProfileState.error(String message)
    : this(status: ProfileStatus.error, errorMessage: message);

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
