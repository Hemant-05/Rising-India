import 'package:flutter/material.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';

class PaymentResultScreen extends StatelessWidget {
  final bool isSuccess;
  final String transactionId;

  const PaymentResultScreen({
    super.key,
    required this.isSuccess,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(isSuccess ? "Payment Success" : "Payment Failed"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
              size: 100,
            ),
            SizedBox(height: 16),
            Text(
              isSuccess ? "Payment Successful!" : "Payment Failed!",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text("Transaction ID: $transactionId"),
            SizedBox(height: 24),
            ElevatedButton(
              style: elevated_button_style(),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text("Back to Home",style: simple_text_style(),),
            ),
          ],
        ),
      ),
    );
  }
}
