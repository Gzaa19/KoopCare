import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// Drives the general info page: loads the member's personal profile via the
/// [GetProfileUseCase] and emits loading / loaded / error states.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;

  ProfileBloc({required GetProfileUseCase getProfileUseCase})
    : _getProfileUseCase = getProfileUseCase,
      super(const ProfileState.initial()) {
    on<ProfileFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
    ProfileFetchRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileState.loading());
    final result = await _getProfileUseCase(const NoParams());
    emit(
      result.fold(
        (failure) => ProfileState.error(failure.message),
        (profile) => ProfileState.loaded(profile),
      ),
    );
  }
}
