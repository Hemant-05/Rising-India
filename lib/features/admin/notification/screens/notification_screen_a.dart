import 'package:flutter/material.dart';
import 'package:raising_india/constant/AppColour.dart';

class NotificationScreenA extends StatefulWidget {
  const NotificationScreenA({super.key});

  @override
  State<NotificationScreenA> createState() => _NotificationScreenAState();
}

class _NotificationScreenAState extends State<NotificationScreenA> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        backgroundColor: AppColour.white,
        title: const Text('Notifications'),
      ),
    );
  }
}
