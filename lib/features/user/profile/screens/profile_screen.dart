import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/auth/screens/signup_screen.dart';
import 'package:raising_india/features/user/coupon/bloc/coupon_bloc.dart';
import 'package:raising_india/features/user/coupon/screens/coupons_screen.dart';
import 'package:raising_india/features/user/profile/bloc/profile_bloc.dart';
import 'package:raising_india/features/user/profile/screens/personal_info_screen.dart';
import 'package:raising_india/features/auth/bloc/auth_bloc.dart';
import 'package:raising_india/features/auth/screens/login_screen.dart';
import 'package:raising_india/features/user/address/screens/select_address_screen.dart';
import 'package:raising_india/features/user/notification/screens/notification_screen.dart';
import 'package:raising_india/features/user/order/screens/order_screen.dart';
import 'package:raising_india/screens/policy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String userId = '';
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Profile', style: simple_text_style(fontSize: 18)),
            const Spacer(),
          ],
        ),
        backgroundColor: AppColour.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is OnProfileLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColour.primary,
                      ),
                    );
                  } else if (state is OnProfileLoaded) {
                    userId = state.user!.uid;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppColour.primary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Icon(
                            Icons.person_outline,
                            color: AppColour.white,
                            size: 50,
                          ),
                        ),
                        SizedBox(width: 15),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${state.user?.name}',
                              style: simple_text_style(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${state.user?.email}',
                              style: simple_text_style(
                                fontSize: 14,
                                color: AppColour.lightGrey,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${state.user?.number}',
                              style: simple_text_style(
                                color: AppColour.lightGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return Center(
                    child: Text(
                      'Restart the app.....',
                      style: simple_text_style(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            customContainer(
              Column(
                children: [
                  optionListTile(map_svg, 'Addresses', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SelectAddressScreen(isFromProfile: true),
                      ),
                    );
                  }),
                  optionListTile(coupon_svg, 'Coupons & Cashback\'s', () {
                    context.read<CouponBloc>().add(LoadUserCoupons());
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CouponsScreen(isSelectionMode: false),
                      ),
                    );
                  }),
                ],
              ),
            ),
            customContainer(
              Column(
                children: [
                  optionListTile(notification_svg, 'Notifications', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsScreen(userId: userId,),
                      ),
                    );
                  }),
                  optionListTile(receipt_svg, 'My Orders', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderScreen()),
                    );
                  }),
                  optionListTile(policy_svg, 'Term & Conditions', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PolicyScreen()),
                    );
                  }),
                ],
              ),
            ),
            customContainer(
              optionListTile(logout_svg, 'Log Out', () {
                context.read<UserBloc>().add(UserLoggedOut());
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Logged out...')));
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                  (route) => false,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Container customContainer(Widget widget) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColour.lightGrey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(8),
      child: widget,
    );
  }

  ListTile optionListTile(String icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColour.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: SvgPicture.asset(icon, color: AppColour.primary),
      ),
      title: Text(title, style: simple_text_style(fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.keyboard_arrow_right_rounded),
    );
  }
}
