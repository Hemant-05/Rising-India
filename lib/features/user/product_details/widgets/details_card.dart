import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';

class details_card extends StatelessWidget {
  const details_card({super.key, required this.icon, required this.title, required this.isIcon});
  final String icon;
  final String title;
  final bool isIcon;

  @override
  Widget build(BuildContext context) {
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        color: AppColour.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColour.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2.4,
        shadowColor: AppColour.lightGrey.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              isIcon? SvgPicture.asset(icon, width: 26, height: 26) : Text(
                icon,
                style: simple_text_style(
                  color: AppColour.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              Text(
                title,
                style: simple_text_style(
                  color: AppColour.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
}
