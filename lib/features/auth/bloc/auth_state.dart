part of 'auth_bloc.dart';


abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class ForgotPasswordState extends UserState {
  final String email;
  ForgotPasswordState(this.email);
  @override
  List<Object?> get props => [email];
}

class UserAuthenticated extends UserState {
  final AppUser user;
  UserAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class UserUnauthenticated extends UserState {}

class UserError extends UserState {
  final String message;
  UserError(this.message);
  @override
  List<Object?> get props => [message];
}

class VerificatoinSuccess extends UserState {
  final String email;
  VerificatoinSuccess(this.email);
  @override
  List<Object?> get props => [email];
}

class VerificationError extends UserState {
  final String message;
  VerificationError(this.message);
  @override
  List<Object?> get props => [message];
}

class ResetPasswordSuccess extends UserState {
  final String email;
  ResetPasswordSuccess(this.email);
  @override
  List<Object?> get props => [email];
}

class ResetPasswordError extends UserState {
  final String message;
  ResetPasswordError(this.message);
  @override
  List<Object?> get props => [message];
}