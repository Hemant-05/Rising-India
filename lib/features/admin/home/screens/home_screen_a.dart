import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/admin/home/bloc/order_cubit/order_stats_cubit.dart';
import 'package:raising_india/features/admin/home/widgets/info_card_widget.dart';
import 'package:raising_india/features/admin/home/widgets/review_analytics_widget.dart';
import 'package:raising_india/features/admin/home/widgets/sales_dashboard_widget.dart';
import 'package:raising_india/features/admin/order/OrderFilterType.dart';
import 'package:raising_india/features/admin/order/screens/order_list_screen.dart';
import 'package:raising_india/features/admin/review/bloc/admin_review_bloc.dart';
import 'package:raising_india/features/admin/sales_analytics/bloc/sales_analytics_bloc.dart';
import 'package:raising_india/services/admin_notification_service.dart';
import '../../../../comman/simple_text_style.dart';
import '../../../auth/bloc/auth_bloc.dart';

class HomeScreenA extends StatefulWidget {
  const HomeScreenA({super.key});

  @override
  State<HomeScreenA> createState() => _HomeScreenAState();
}

class _HomeScreenAState extends State<HomeScreenA> {
  @override
  void initState() {
    super.initState();
    context.read<AdminReviewBloc>().add(LoadAllReviews());
    context.read<SalesAnalyticsBloc>().add(LoadSalesAnalytics());
    // _initializeNotifications();
  }

  void _initializeNotifications() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        AdminNotificationService.initializeAdminNotifications();
        AdminNotificationService.setupAdminMessageHandler();
      }
    });
  }

  void navigateToOrderListScreen(String title, OrderFilterType orderType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OrderListScreen(title: title, orderType: orderType),
      ),
    );
  }

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
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
              child:
              // Stats Tiles Row
              Column(
                children: [
                  SizedBox(
                    height: 90,
                    width: double.infinity,
                    child: Row(
                      children: [
                        info_card(
                          state.runningOrders.toString(),
                          'RUNNING',
                          AppColour.primary.withOpacity(0.6),
                          () => navigateToOrderListScreen(
                            'Running',
                            OrderFilterType.running,
                          ),
                        ),
                        // put real data here
                        SizedBox(width: 10),
                        info_card(
                          state.todayOrders.toString(),
                          'TODAYS',
                          AppColour.lightGrey.withOpacity(0.6),
                          () => navigateToOrderListScreen(
                            'Today',
                            OrderFilterType.today,
                          ),
                        ),
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
                          AppColour.green.withOpacity(0.6),
                          () => navigateToOrderListScreen(
                            'Delivered',
                            OrderFilterType.delivered,
                          ),
                        ),
                        // put real data here
                        SizedBox(width: 10),
                        info_card(
                          state.cancelledOrders.toString(),
                          'CANCELLED',
                          AppColour.red.withOpacity(0.6),
                          () => navigateToOrderListScreen(
                            'Cancelled',
                            OrderFilterType.cancelled,
                          ),
                        ),
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
                          AppColour.white,
                          () => navigateToOrderListScreen(
                            'All',
                            OrderFilterType.all,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  const SalesDashboardWidget(),
                  SizedBox(height: 10),
                  SizedBox(height: 140, child: ReviewAnalyticsWidget()),
                ],
              ),

          );
        },
      ),
    );
  }
}
