import 'package:flutter/material.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';

class PlaceOrderScreen extends StatelessWidget  {
  const PlaceOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Order Placed Successfully',style: simple_text_style(fontWeight: FontWeight.bold,fontSize: 20),),
            ElevatedButton(
              style: elevated_button_style(),
                onPressed: (){},
                child: Text('Continue Shopping',style: simple_text_style(color: AppColour.white),))
          ],
        ),
      ),
    );
  }
}
