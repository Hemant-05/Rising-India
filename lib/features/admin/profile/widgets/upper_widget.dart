import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';

Expanded upper_widget(int balance) {
  return Expanded(
    flex: 2,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        color: AppColour.primary,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Text(
                'My Profile',
                style: simple_text_style(color: AppColour.white,
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'Available Balance',
                style: simple_text_style(
                  color: AppColour.white,
                  fontSize: 20,
                ),
              ),
              Text(
                '₹ $balance',
                style: simple_text_style(
                  color: AppColour.white,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                          color: AppColour.white, width: 1.5)),

                  onPressed: (){
                    // go to withdraw screen
                    // Add your withdraw logic here
                  }, child: Text('Withdraw', style: simple_text_style(color: AppColour.white))),
            ],
          ),
        ],
      ),
    ),
  );
}