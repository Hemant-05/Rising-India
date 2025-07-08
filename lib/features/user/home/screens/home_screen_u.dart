import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/auth/services/auth_service.dart';
import 'package:raising_india/features/user/search/screens/product_search_screen.dart';
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
        String address = 'Fetching address...';
        if (state is UserAuthenticated) {
          name = state.user.name;
          final uid = state.user.uid;
          context.read<UserBloc>().add(UserLocationRequested(uid));
        } else if (state is UserLocationSuccess) {
          address = state.address;
        } else if (state is UserUnauthenticated) {
          return Scaffold(
            body: Center(child: Text('Please log in to continue')),
          );
        }
        return Scaffold(
          backgroundColor: AppColour.white,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: AppColour.white,
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColour.primary,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Image.asset(appLogo, width: 25, height: 25),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DELIVER TO',
                      style: simple_text_style(
                        color: AppColour.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      address,
                      style: simple_text_style(
                        color: AppColour.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColour.black,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: SvgPicture.asset(cart_svg, width: 22, height: 22),
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Hey ${name},',
                    style: simple_text_style(
                      color: AppColour.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: 'Welcome to Raising India',
                        style: simple_text_style(
                          color: AppColour.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductSearchScreen()));
                  },
                  child: Container(
                    decoration:BoxDecoration(
                      color: AppColour.lightGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: AppColour.lightGrey),
                        const SizedBox(width: 10),
                        Text(
                          'Search for products or categories',
                          style: simple_text_style(
                            color: AppColour.lightGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

              ],
            ),
          ),
        );
      },
    );
  }
}
