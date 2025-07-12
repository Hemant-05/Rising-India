import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/models/product_model.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({
    super.key,
    required this.address,
    required this.addressCode,
    required this.cartProducts,
    required this.total,
  });
  final String address;
  final LatLng addressCode;
  final List<Map<String, dynamic>> cartProducts;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        backgroundColor: AppColour.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 10),
            Text("Payment", style: simple_text_style(fontSize: 20)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address', style: simple_text_style()),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColour.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColour.primary, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Text(address, style: simple_text_style()),
            ),
            /*const SizedBox(height: 20),
            Text('Payment Method', style: simple_text_style()),
            const SizedBox(height: 4),
            SizedBox(
              height: 120,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                return Container(
                  height: 160,
                  width: 160,
                  margin: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColour.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ]
                  ),
                  child: Column(
                    children: [

                    ],
                  ),
                );
              },),
            ),*/
            const SizedBox(height: 20),
            Text('Products Details', style: simple_text_style()),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                itemCount: cartProducts.length,
                itemBuilder: (context, index) {
                  ProductModel product = cartProducts[index]['product'];
                  int quantity = cartProducts[index]['quantity'];
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColour.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(
                            0,
                            3,
                          ), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.photos_list[0],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        product.name,
                        style: simple_text_style(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        '${product.price} x $quantity = ₹${(product.price * quantity).toInt()}',
                        style: simple_text_style(),
                      ),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              style: elevated_button_style(),
              onPressed: () {
                // Implement payment logic here
              },
              child: Text(
                "PROCEED & PAY ₹$total",
                style: simple_text_style(color: AppColour.white,fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
