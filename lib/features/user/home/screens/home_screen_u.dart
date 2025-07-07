import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
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
        String address = '';
        if (state is UserAuthenticated) {
          name = state.user.name;
          authService.updateUserLocation(state.user.uid);
          address = state.user.address!;
        }
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColour.white,
                  child: SvgPicture.asset(menu_svg,width: 16,),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LOCATION',
                      style: simple_text_style(color : AppColour.primary,fontSize: 14,fontWeight: FontWeight.bold,),
                    ),
                    Text(
                      address??'Fetching address...',
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
