import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';

Widget info_card(String text, String sub_text,Color color,VoidCallback onTap) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: simple_text_style(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sub_text,
                  style: simple_text_style(
                    color: AppColour.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColour.black,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}