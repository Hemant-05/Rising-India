import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/auth/services/auth_service.dart';
import 'package:raising_india/features/user/cart/screens/cart_screen.dart';
import 'package:raising_india/features/user/home/bloc/user_product_bloc/user_product_bloc.dart';
import 'package:raising_india/features/user/home/widgets/categories_section.dart';
import 'package:raising_india/features/user/home/widgets/product_grid.dart';
import 'package:raising_india/features/user/home/widgets/search_bar_widget.dart';
import '../../../auth/bloc/auth_bloc.dart';

class HomeScreenU extends StatefulWidget {
  const HomeScreenU({super.key});

  @override
  State<HomeScreenU> createState() => _HomeScreenUState();
}

class _HomeScreenUState extends State<HomeScreenU> {
  AuthService authService = AuthService();
  String address = 'Fetching address...';
  @override
  void initState() {
    super.initState();
    BlocProvider.of<UserProductBloc>(context).add(FetchBestSellingProducts());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserAuthenticated) {
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
                    SizedBox(
                      width: 200,
                      child: Text(
                        address,
                        style: simple_text_style(
                          color: AppColour.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
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
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen(),));
                    },
                      child: SvgPicture.asset(cart_svg, width: 22, height: 22)),
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Hey there, ',
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
                  const SizedBox(height: 16),
                  search_bar_widget(context),
                  const SizedBox(height: 16),
                  categories_section(context),
                  const SizedBox(height: 16),
                  Text(
                    'Best Products',
                    style: simple_text_style(
                      color: AppColour.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<UserProductBloc, UserProductState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state.bestSellingProducts.isEmpty) {
                        return Center(
                          child: Text(
                            'No Best Selling Products Available',
                            style: simple_text_style(
                              color: AppColour.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      } else if (state.error != null) {
                        return Center(child: Text(state.error!));
                      } else {
                        return ProductGrid(products: state.bestSellingProducts);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
