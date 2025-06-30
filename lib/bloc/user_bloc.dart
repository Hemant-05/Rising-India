import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'package:equatable/equatable.dart';

// Events
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

class UserSignUp extends UserEvent {
  final String name, email, number, password;
  final UserRole role;
  UserSignUp({
    required this.name,
    required this.email,
    required this.number,
    required this.password,
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

// States
abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

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

class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthService authService;
  UserBloc(this.authService) : super(UserInitial()) {
    on<AppStarted>((event, emit) async {
      final user = await authService.getCurrentUser();
      if (user != null) {
        emit(UserAuthenticated(user));
      } else {
        emit(UserUnauthenticated());
      }
    });
    on<UserSignUp>((event, emit) async {
      emit(UserLoading());
      // Validate email format
      if (event.name.isEmpty) {
        emit(UserError('Name cannot be empty'));
        return;
      }
      if (event.email.isEmpty) {
        emit(UserError('Email cannot be empty'));
        return;
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(event.email)) {
        emit(UserError('Invalid email format'));
        return;
      }
      if (event.number.isEmpty) {
        emit(UserError('Phone number cannot be empty'));
        return;
      } else if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(event.number)) {
        emit(UserError('Invalid phone number format'));
        return;
      }
      if (event.password.isEmpty) {
        emit(UserError('Password cannot be empty'));
        return;
      } else if (event.password.length < 6) {
        emit(UserError('Password must be at least 6 characters long'));
        return;
      }

      final error = await authService.signUp(
        name: event.name,
        email: event.email,
        number: event.number,
        password: event.password,
        role: event.role,
      );
      if (error == null) {
        final user = await authService.getCurrentUser();
        emit(UserAuthenticated(user!));
      } else {
        emit(UserError(error));
      }
    });
    on<UserSignIn>((event, emit) async {
      emit(UserLoading());
      final error = await authService.signIn(event.email, event.password);
      if (error == null) {
        final user = await authService.getCurrentUser();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (event.rememberMe) {
          await prefs.setBool('rememberMe', true);
        } else {
          await prefs.remove('rememberMe');
        }
        emit(UserAuthenticated(user!));
      } else {
        emit(UserError(error));
      }
    });
    /*    on<UserGoogleSignIn>((event, emit) async {
      emit(UserLoading());
      final error = await authService.signInWithGoogle();
      if (error == null) {
        final user = await authService.getCurrentUser();
        emit(UserAuthenticated(user!));
      } else {
        emit(UserError(error));
      }
    });*/
    on<UserLoggedOut>((event, emit) async {
      emit(UserLoading());
      await authService.signOut();
      emit(UserUnauthenticated());
    });
  }
}
