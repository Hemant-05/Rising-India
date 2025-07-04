import 'package:flutter/material.dart';

class AllProductListA extends StatefulWidget {
  const AllProductListA({super.key});

  @override
  State<AllProductListA> createState() => _AllProductListAState();
}

class _AllProductListAState extends State<AllProductListA> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
        title: const Text('All Products'),
      ),
    );
  }
}
