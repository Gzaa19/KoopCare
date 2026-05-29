import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String identifier;
  final String pin;

  const AuthLoginRequested({required this.identifier, required this.pin});

  @override
  List<Object?> get props => [identifier, pin];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
