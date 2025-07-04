import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/auth/services/auth_service.dart';
import '../../../auth/bloc/auth_bloc.dart';

class HomeScreenU extends StatefulWidget {
  const HomeScreenU({super.key});

  @override
  State<HomeScreenU> createState() => _HomeScreenUState();
}

class _HomeScreenUState extends State<HomeScreenU> {
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        String name = '';
        if (state is UserAuthenticated) {
          name = state.user.name;
          print(name);
          authService.updateUserLocation(state.user.uid);
          print(state.user.uid);
        }
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Row(
              children: [
                Column(
                  children: [
                    Text(
                      'LOCATION',
                      style: simple_text_style(color : AppColour.primary,fontSize: 14,fontWeight: FontWeight.bold,),
                    ),
                    Text(
                      'Fetching address...',
                      style: simple_text_style(color : AppColour.black,fontSize: 14,fontWeight: FontWeight.w700,),
                    ),
                  ],
                )
              ],
            ),
          ),
          body: Center(child: Text('Welcome, $name')),
        );
      },
    );
  }
}
