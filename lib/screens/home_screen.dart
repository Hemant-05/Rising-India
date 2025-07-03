import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        String name = '';
        String role = '';
        if (state is UserAuthenticated) {
          name = state.user.name;
          role = state.user.role.name;
        }
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Home'),
            actions: [
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  return state is UserLoading
                      ? const CircularProgressIndicator()
                      : IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () {
                            BlocProvider.of<UserBloc>(
                              context,
                            ).add(UserLoggedOut());
                            if (state is UserAuthenticated) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Logged out : ${state.user.name}'),
                                ),
                              );
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                        );
                },
              ),
            ],
          ),
          body: Center(child: Text('Welcome, $name ($role)')),
        );
      },
    );
  }
}
