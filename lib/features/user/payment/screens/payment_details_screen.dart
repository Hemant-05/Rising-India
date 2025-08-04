import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/features/user/order/bloc/order_bloc.dart';
import 'package:raising_india/features/user/payment/screens/place_order_screen.dart';
import 'package:raising_india/features/user/product_details/bloc/product_funtction_bloc/product_fun_bloc.dart';
import 'package:raising_india/models/order_model.dart';
import 'package:raising_india/models/product_model.dart';
import 'package:raising_india/features/user/payment/screens/payment_result_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';

class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({
    super.key,
    required this.address,
    required this.addressCode,
    required this.total,
    required this.name,
    required this.contact,
    required this.email,
    required this.cartProductList,
  });
  final String address;
  final LatLng addressCode;
  final String total;
  final String name;
  final String contact;
  final String email;
  final List<Map<String, dynamic>> cartProductList;

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  late Razorpay _razorpay;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isCOD = false;

  void _openCheckOut() {
    final razorpayKeyId = dotenv.env['RAZORPAY_KEY_ID'];
    String amount = (int.parse(widget.total) * 100).toString();
    String name = widget.name;
    String contact = widget.contact;
    String email = widget.email;

    var options = {
      'key': razorpayKeyId,
      'amount': amount,
      'name': name,
      'description': 'Shopping From Raising India',
      'prefill': {'contact': contact, 'email': email},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      print('=================${e.toString()}');
    }
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    placeOrder(false, true, response.paymentId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentResultScreen(
          isSuccess: true,
          transactionId: response.paymentId!,
        ),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    placeOrder(false, false, null);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentResultScreen(
          isSuccess: false,
          transactionId: response.message!,
        ),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print(response.walletName);
  }

  void placeOrder(
    bool isCod,
    bool isPaymentSuccess,
    String? transactionId,
  ) async {
    List<Map<String, dynamic>> list = widget.cartProductList.map((map) {
      return {
        'productId': map['productId'],
        'name' : (map['product'] as ProductModel).name,
        'image' : (map['product'] as ProductModel).photos_list[0],
        'quantity': map['quantity'].toString(),
      };
    }).toList();
    final newOrder = OrderModel(
      orderId: Uuid().v4(),
      userId: auth.currentUser!.uid,
      createdAt: DateTime.now(),
      items: list,
      subtotal: double.parse(widget.total),
      deliveryFee: 0,
      transactionId: isPaymentSuccess ? transactionId : 'NA',
      total: double.parse(widget.total),
      paymentMethod: isCod ? PayMethodCOD : PayMethodPrepaid,
      paymentStatus: isCod
          ? PayStatusPending
          : isPaymentSuccess
          ? PayStatusPaid
          : PayStatusFailed,
      orderStatus: OrderStatusCreated,
      address: DeliveryAddress(
        widget.address,
        widget.contact,
        GeoPoint(widget.addressCode.latitude, widget.addressCode.longitude),
      ),
    );
    context.read<OrderBloc>().add(PlaceOrderEvent(model: newOrder));
    if (isPaymentSuccess) {
      context.read<ProductFunBloc>().add(ClearCartPressed());
    }
    if (isCod) {
      context.read<ProductFunBloc>().add(ClearCartPressed());
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrderPlacedScreen()),
      );
    }
  }

  @override
  void dispose() {
    _razorpay.clear(); // Removes all listeners
    super.dispose();
  }

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
            Text("Payment & Details", style: simple_text_style(fontSize: 20)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Note :- ', style: simple_text_style()),
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
              child: Text(
                'Don\'t use wallet !!!',
                style: simple_text_style(color: AppColour.red),
              ),
            ),
            const SizedBox(height: 20),
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
              child: Text(widget.address, style: simple_text_style()),
            ),
            const SizedBox(height: 20),
            Text('Payment Method', style: simple_text_style()),
            const SizedBox(height: 4),
            SizedBox(
              height: 100,
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isCOD = !isCOD;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        margin: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColour.white,
                          borderRadius: BorderRadius.circular(10),
                          border: !isCOD
                              ? null
                              : Border.all(color: AppColour.primary, width: 2),
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
                        child: Column(
                          children: [
                            Expanded(child: Image.asset(cod_png)),
                            Text(
                              'Cash On Delivery',
                              style: simple_text_style(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isCOD = !isCOD;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        margin: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColour.white,
                          borderRadius: BorderRadius.circular(10),
                          border: isCOD
                              ? null
                              : Border.all(color: AppColour.primary, width: 2),
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
                        child: Column(
                          children: [
                            Expanded(child: Image.asset(pay_now_png)),
                            Text(
                              "Pay Now",
                              style: simple_text_style(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Products Details', style: simple_text_style()),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartProductList.length,
                itemBuilder: (context, index) {
                  ProductModel product =
                      widget.cartProductList[index]['product'];
                  int quantity = widget.cartProductList[index]['quantity'];
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    margin: EdgeInsets.symmetric(vertical: 8,horizontal: 4),
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
                isCOD ? placeOrder(true, false, null) : _openCheckOut();
              },
              child: Text(
                isCOD ? "PLACE ORDER" : "PROCEED & PAY ₹${widget.total}",
                style: simple_text_style(
                  color: AppColour.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
