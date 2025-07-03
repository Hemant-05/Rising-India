import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';

Widget cus_text_field(String label, TextEditingController _controller,String hintText,
    {bool obscureText = false, bool isNumber = false})  {
  return Column(
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: simple_text_style(color: AppColour.grey, fontSize: 12),
        ),
      ),
      const SizedBox(height: 10,),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColour.grey.withOpacity(0.1),
        ),
        child: TextField(
          keyboardType: isNumber? TextInputType.number: TextInputType.text,
          controller: _controller,
          obscureText: obscureText,
          obscuringCharacter: '*',
          decoration: InputDecoration(
            hintStyle: simple_text_style(color: AppColour.lightGrey),
            hintText: hintText,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 18,
            ),
          ),
        ),
      ),
    ],
  );
}