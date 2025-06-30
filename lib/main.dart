import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/features/on_boarding/screens/welcome_screen.dart';
import 'package:raising_india/screens/splash_screen.dart';

import 'firebase_options.dart';
import 'bloc/user_bloc.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    BlocProvider(
      create: (_) => UserBloc(AuthService())..add(AppStarted()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raising India',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
