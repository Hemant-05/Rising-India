import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user_model.dart';
import '../services/auth_service.dart';
part 'auth_event.dart';
part 'auth_state.dart';

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
      if (event.confirmPassword.isEmpty) {
        emit(UserError('Confirm Password cannot be empty'));
        return;
      } else if (event.confirmPassword != event.password) {
        emit(UserError('Passwords do not match'));
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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('rememberMe', true);
        prefs.setBool('isAdmin', user?.role == admin);
        emit(UserAuthenticated(user!));
      } else {
        emit(UserError(error));
      }
    });

    on<UserSignIn>((event, emit) async {
      emit(UserLoading());
      if (event.email.isEmpty) {
        emit(UserError('Email cannot be empty'));
        return;
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(event.email)) {
        emit(UserError('Invalid email format'));
        return;
      }
      if (event.password.isEmpty) {
        emit(UserError('Please enter your password'));
        return;
      } else if (event.password.length < 6) {
        emit(UserError('Password must be at least 6 characters long'));
        return;
      }
      final error = await authService.signIn(event.email, event.password);
      if (error == null) {
        final user = await authService.getCurrentUser();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isAdmin', user?.role == admin);
        if (event.rememberMe) {
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setBool('rememberMe', true);
        } else {
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setBool('rememberMe', false);
        }
        emit(UserAuthenticated(user!));
      } else {
        emit(UserError(error));
      }
    });

    on<SendVerificationCode>((event, emit) async {
      emit(UserLoading());
      if (event.email.isEmpty) {
        emit(UserError('Email cannot be empty'));
        return;
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(event.email)) {
        emit(UserError('Invalid email format'));
        return;
      }
      final error = await authService.sendVerificationCode(event.email);
      if (error == 'ok') {
        emit(ForgotPasswordState(event.email));
      } else {
        emit(UserError(error!));
      }
    });

    on<VerifyCode>((event, emit) async {
      emit(UserLoading());
      final code = event.code.trim();
      final error = await authService.verifyCode(code); //await authService.verifyCode(event.code);
      if (error == 'ok') {
        emit(VerificatoinSuccess(event.email, event.code));
      } else {
        emit(VerificationError(error!));
      }
    });

    on<ResetPassword>((event, emit) async {
      emit(UserLoading());
      final code = event.code;
      final email = event.email;
      final password = event.password;
      final confirmPassword = event.confirmPassword;
      if(password .isEmpty) {
        emit(UserError('Password cannot be empty'));
        return;
      } else if (password.length < 6) {
        emit(UserError('Password must be at least 6 characters long'));
        return;
      }else if (confirmPassword.isEmpty) {
        emit(UserError('Confirm Password cannot be empty'));
        return;
      } else if (confirmPassword != password) {
        emit(UserError('Passwords do not match'));
        return;
      }
      final res = await authService.resetPassword(
        code,password
      );
      if (res == 'ok') {
        emit(ResetPasswordSuccess(email));
      } else {
        emit(ResetPasswordError(res!));
      }
    });

  on<UserLocationRequested> (
      (event, emit) async {
        emit(UserLocationLoading());
        try {
          final address = await authService.updateUserLocation(event.uid);
          emit(UserLocationSuccess(address!));
        } catch (e) {
          emit(UserError('Failed to get user location: $e'));
        }
      }
  );

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
