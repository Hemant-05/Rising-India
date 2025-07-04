import 'package:flutter/material.dart';

class ReviewScreenA extends StatefulWidget {
  const ReviewScreenA({super.key});

  @override
  State<ReviewScreenA> createState() => _ReviewScreenAState();
}

class _ReviewScreenAState extends State<ReviewScreenA> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
    );
  }
}
