import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';

ListTile optionsListTileWidget(VoidCallback onTap,String icon, String title, Widget trailing) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: AppColour.white,
      radius: 22,
      child: SvgPicture.asset(icon, color: AppColour.primary),
    ),
    title: Text(
      title,
      style: simple_text_style(color: AppColour.black, fontSize: 16),
    ),
    trailing: trailing,
    onTap: onTap
  );
}