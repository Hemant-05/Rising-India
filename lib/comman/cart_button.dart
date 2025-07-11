import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/cart/screens/cart_screen.dart';
import 'package:raising_india/features/user/product_details/bloc/product_funtction_bloc/product_fun_bloc.dart';

import '../constant/ConPath.dart';

class cart_button extends StatelessWidget {
  const cart_button({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductFunBloc, ProductFunState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColour.black,
            borderRadius: BorderRadius.circular(40),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
            child: SvgPicture.asset(cart_svg, width: 22, height: 22),
          ),
        );
      },
    );
  }
}
