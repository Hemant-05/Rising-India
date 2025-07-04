part of 'auth_bloc.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStarted extends UserEvent {}

class UserLoggedIn extends UserEvent {
  final AppUser user;
  UserLoggedIn(this.user);
  @override
  List<Object?> get props => [user];
}

class UserLoggedOut extends UserEvent {}

class VerifyCode extends UserEvent {
  final String email;
  final String code;
  VerifyCode(this.code, this.email);
  @override
  List<Object?> get props => [code];
}

class SendVerificationCode extends UserEvent {
  final String email;
  SendVerificationCode(this.email);
  @override
  List<Object?> get props => [email];
}

class ResetPassword extends UserEvent {
  final String email, password, confirmPassword,code;
  ResetPassword({
    required this.code,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
  @override
  List<Object?> get props => [email, password, confirmPassword];
}

class UserSignUp extends UserEvent {
  final String name, email, number, password,confirmPassword;
  final UserRole role;
  UserSignUp({
    required this.name,
    required this.email,
    required this.number,
    required this.password,
    required this.confirmPassword,
    required this.role,
  });
  @override
  List<Object?> get props => [name, email, number, password, role];
}

class UserSignIn extends UserEvent {
  final String email, password;
  final bool rememberMe;
  UserSignIn(this.email, this.password, this.rememberMe);
  @override
  List<Object?> get props => [email, password];
}

class UserGoogleSignIn extends UserEvent {}
