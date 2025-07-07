import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/admin/review/screens/review_screen_a.dart';

Container review_tile(double rating, int reviewCount, BuildContext context) {
  return Container(
    padding: EdgeInsets.all(12),
    height: 90,
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppColour.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Text('Reviews', style: simple_text_style(color: AppColour.grey)),
            Spacer(),
            InkWell(
              onTap: () {
                // Navigate to the reviews page
                Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewScreenA()));
              },
              child: Text(
                'See All',
                style: simple_text_style(
                  color: AppColour.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            SvgPicture.asset(star_svg),
            SizedBox(width: 5),
            Text(
              rating.toString(),
              style: simple_text_style(
                color: AppColour.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 5),
            Text(
              '($reviewCount Reviews)',
              style: simple_text_style(
                color: AppColour.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}