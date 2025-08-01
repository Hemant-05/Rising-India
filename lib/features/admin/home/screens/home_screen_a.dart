import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/admin/home/bloc/order_cubit/order_stats_cubit.dart';
import 'package:raising_india/features/admin/home/widgets/info_card_widget.dart';
import 'package:raising_india/features/admin/home/widgets/review_tile_widget.dart';
import '../../../../comman/simple_text_style.dart';
import '../../../auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreenA extends StatelessWidget {
  const HomeScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 50),
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            String name = '';
            if (state is UserAuthenticated) {
              name = state.user.name;
            }
            return AppBar(
              backgroundColor: AppColour.white,
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
            );
          },
        ),
      ),
      body: BlocBuilder<OrderStatsCubit, OrderStatsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats Tiles Row
              Column(
                children: [
                  SizedBox(
                    height: 90,
                    width: double.infinity,
                    child: Row(
                      children: [
                        info_card(state.runningOrders.toString(), 'RUNNING'),
                        // put real data here
                        SizedBox(width: 10),
                        info_card(state.todaysOrders.toString(), 'TODAYS'),
                        // put real data here
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    width: double.infinity,
                    child: Row(
                      children: [
                        info_card(
                          state.deliveredOrders.toString(),
                          'DELIVERED',
                        ),
                        // put real data here
                        SizedBox(width: 10),
                        info_card(state.cancelledOrders.toString(), 'CANCELLED'),
                        // put real data here
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    width: double.infinity,
                    child: Row(
                      children: [
                        info_card(
                          state.totalOrders.toString(),
                          'ALL ORDERS',
                        ),
                        // put real data here
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  review_tile(4.5, 24, context), // put real data here
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}