import 'package:flutter/material.dart';
import 'package:raising_india/constant/AppColour.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        title: const Text('All Categories'),
        backgroundColor: AppColour.white,
      ),
      body: Center(
        child: Text(
          'All Categories will be displayed here',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
