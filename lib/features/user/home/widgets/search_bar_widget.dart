import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/search/screens/product_search_screen.dart';

Widget search_bar_widget(BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductSearchScreen()),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: AppColour.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColour.lightGrey),
          const SizedBox(width: 16),
          Text(
            'Search for products or categories',
            style: simple_text_style(
              color: AppColour.lightGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}