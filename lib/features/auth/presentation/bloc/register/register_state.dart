import 'package:equatable/equatable.dart';

import '../../../domain/entities/auth_user.dart';

enum RegisterStatus { initial, submitting, success, error }

class RegisterState extends Equatable {
  final RegisterStatus status;
  final AuthUser? user;
  final String? errorMessage;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.user,
    this.errorMessage,
  });

  const RegisterState.initial() : this();

  const RegisterState.submitting() : this(status: RegisterStatus.submitting);

  const RegisterState.success(AuthUser user)
    : this(status: RegisterStatus.success, user: user);

  const RegisterState.error(String message)
    : this(status: RegisterStatus.error, errorMessage: message);

  @override
  List<Object?> get props => [status, user, errorMessage];
}
