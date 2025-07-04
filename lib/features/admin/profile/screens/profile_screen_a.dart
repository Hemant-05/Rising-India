import 'package:flutter/material.dart';
class ProfileScreenA extends StatefulWidget {
  const ProfileScreenA({super.key});

  @override
  State<ProfileScreenA> createState() => _ProfileScreenAState();
}

class _ProfileScreenAState extends State<ProfileScreenA> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Screen'),
      ),
    );
  }
}
