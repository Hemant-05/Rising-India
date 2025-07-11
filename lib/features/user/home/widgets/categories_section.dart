import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import '../../../../constant/AppData.dart';
import 'category_showing_widget.dart';

Widget categories_section(BuildContext context) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'All Categories',
            style: simple_text_style(color: AppColour.black, fontSize: 22),
          ),
          /*TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AllCategoriesScreen()),
              );
            },
            child: Text(
              'See All',
              style: simple_text_style(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),*/
        ],
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 120,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            category_showing_widget(context, categories[0]),
            category_showing_widget(context, categories[1]),
            category_showing_widget(context, categories[2]),
          ],
        ),
      ),
    ],
  );
}
