import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/order/bloc/order_bloc.dart';
import '../../../../constant/ConPath.dart';

class OrderPlacedScreen extends StatelessWidget  {
  const OrderPlacedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(done_svg),
            SizedBox(height: 10,),
            Text('Order Placed Successfully',style: simple_text_style(fontWeight: FontWeight.bold,fontSize: 20),),
            SizedBox(height: 10,),
            ElevatedButton(
              style: elevated_button_style(),
                onPressed: (){
                  BlocProvider.of<OrderBloc>(context).add(LoadUserOngoingOrderEvent());
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text('Continue Shopping',style: simple_text_style(color: AppColour.white),))
          ],
        ),
      ),
    );
  }
}
