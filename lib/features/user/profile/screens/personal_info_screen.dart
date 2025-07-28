import 'package:flutter/material.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Persona Info', style: simple_text_style(fontSize: 18)),
            const Spacer(),
          ],
        ),
        backgroundColor: AppColour.white,
      ),
      body:  Container(
        alignment: Alignment.center,
        child: Text('Working on Profile..'),
      )
    );
  }
}
