import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:  Center(child: Text('personal Info...', style: simple_text_style())),
    );
  }
}
