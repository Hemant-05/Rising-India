import 'package:flutter/material.dart';
import 'package:raising_india/constant/AppColour.dart';

class back_button extends StatelessWidget {
  const back_button({super.key, });

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 40,
      width: 40,
      // margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColour.lightGrey.withOpacity(0.25),
        borderRadius: BorderRadius.circular(50),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          size: 14,
          Icons.arrow_back_ios_rounded,
          color: AppColour.black,
        ),
      ),
    );
  }
}
