import 'package:flutter/material.dart';

class ProductDetailsA extends StatefulWidget {
  const ProductDetailsA({super.key});

  @override
  State<ProductDetailsA> createState() => _ProductDetailsAState();
}

class _ProductDetailsAState extends State<ProductDetailsA> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
    );
  }
}
