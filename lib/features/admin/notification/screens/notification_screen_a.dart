import 'package:flutter/material.dart';

class NotificationScreenA extends StatefulWidget {
  const NotificationScreenA({super.key});

  @override
  State<NotificationScreenA> createState() => _NotificationScreenAState();
}

class _NotificationScreenAState extends State<NotificationScreenA> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
    );
  }
}
