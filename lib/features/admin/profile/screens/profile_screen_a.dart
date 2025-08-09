import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/admin/category/bloc/category_bloc.dart';
import 'package:raising_india/features/admin/category/screens/admin_categories_screen.dart';
import 'package:raising_india/features/admin/profile/widgets/option_list_tile_widget.dart';
import 'package:raising_india/features/admin/profile/widgets/upper_widget.dart';
import 'package:raising_india/features/admin/review/screens/review_screen_a.dart';
import 'package:raising_india/features/auth/bloc/auth_bloc.dart';
import 'package:raising_india/features/auth/screens/login_screen.dart';

class ProfileScreenA extends StatefulWidget {
  const ProfileScreenA({super.key});

  @override
  State<ProfileScreenA> createState() => _ProfileScreenAState();
}

class _ProfileScreenAState extends State<ProfileScreenA> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          upper_widget(50), // Example balance, replace with actual data
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(color: AppColour.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CusContainer(
                    Column(
                      children: [
                        optionsListTileWidget(
                          () {
                            print('Open Profile');
                          },
                          profile_svg,
                          'Profile',
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColour.grey,
                            size: 16,
                          ),
                        ),
                        optionsListTileWidget(
                              () {
                                context.read<CategoryBloc>().add(LoadCategories());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminCategoriesScreen(),
                              ),
                            );
                          },
                          category_svg,
                          'Categories',
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColour.grey,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  CusContainer(
                    BlocBuilder<UserBloc, UserState>(
                      builder: (context, state) {
                        return optionsListTileWidget(
                          () {
                            BlocProvider.of<UserBloc>(
                              context,
                            ).add(UserLoggedOut());
                            if (state is UserAuthenticated) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Logged out : ${state.user.name}',
                                  ),
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
                          logout_svg,
                          'Logout',
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColour.grey,
                            size: 16,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget CusContainer(Widget widget) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColour.lightGrey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: widget,
    );
  }
}
