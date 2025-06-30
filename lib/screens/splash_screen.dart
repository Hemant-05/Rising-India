import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/features/on_boarding/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/user_bloc.dart';
import '../constant/ConPath.dart';
import '../features/auth/screens/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return BlocListener<UserBloc, UserState>(
      listenWhen: (prev, curr) => curr is! UserInitial,
      listener: (context, state) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isRememberMe = prefs.getBool('rememberMe') ?? false;
        if (isRememberMe && state is UserAuthenticated) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else if (isRememberMe && state is UserUnauthenticated) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
        }
      },
      child: Scaffold(
        body: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(appLogo, width: 100, height: 100),
            const SizedBox(height: 20),
            const Text('Loading...'),
          ],
        ),),
      ),
    );
  }
}