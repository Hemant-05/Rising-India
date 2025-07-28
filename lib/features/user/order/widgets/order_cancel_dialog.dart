import 'package:flutter/material.dart';
import 'package:raising_india/comman/bold_text_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';

Future<void> showCancelOrderDialog(BuildContext context, void Function(String reason) onCancel) async {
  final TextEditingController reasonController = TextEditingController();

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text('Cancel Order',style: bold_text_style(),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'If you cancel the order, you will be refunded the full amount except the platform fee (₹4).',
              style: TextStyle(fontFamily: 'Sen', fontSize: 14),
            ),
            SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Cancellation Reason',
                hintStyle: simple_text_style(color: AppColour.lightGrey),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColour.primary)),
                border: OutlineInputBorder(borderSide: BorderSide(color: AppColour.primary))
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Back',style: simple_text_style(),),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Cancel Order',style: simple_text_style(color: Colors.red,fontWeight: FontWeight.bold)),
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                Navigator.of(context).pop();
                onCancel(reason);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill the reason..'),));
              }
            },
          ),
        ],
      );
    },
  );
}
