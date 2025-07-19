import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Notifications...', style: simple_text_style())),
    );
  }
}
