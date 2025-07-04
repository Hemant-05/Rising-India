import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/admin/home/widgets/info_card_widget.dart';
import 'package:raising_india/features/admin/home/widgets/review_tile_widget.dart';
import '../../../../comman/simple_text_style.dart';
import '../../../auth/bloc/auth_bloc.dart';

class HomeScreenA extends StatelessWidget {
  const HomeScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        String name = '';
        if (state is UserAuthenticated) {
          name = state.user.name;
        }
        return Scaffold(
          backgroundColor: Colors.grey[100],
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.grey[100],
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColour.white,
                  child: SvgPicture.asset(
                    profile_svg,
                    color: AppColour.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADMIN PORTAL',
                      style: simple_text_style(
                        color: AppColour.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      name,
                      style: simple_text_style(
                        color: AppColour.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Container(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Row(
                    children: [
                      info_card('20', 'RUNNING ORDERS'),
                      SizedBox(width: 10),
                      info_card('10', 'ORDERS REQUEST'),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                review_tile(4.5,24),
              ],
            ),
          ),
        );
      },
    );
  }
}
