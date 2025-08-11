import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/order/bloc/order_bloc.dart';
import 'package:raising_india/features/user/order/screens/order_details_screen.dart';
import 'package:raising_india/features/user/order/screens/order_tracking_screen.dart';
import 'package:raising_india/features/user/order/widgets/order_cancel_dialog.dart';
import 'package:raising_india/models/order_model.dart';

Widget onGoingWidget(List<OrderModel> list) {
  return Expanded(
    child: Container(
      padding: EdgeInsets.all(12),
      alignment: Alignment.center,
      child: list.isEmpty
          ? Center(child: Text('No ongoing orders..'))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                String title = '';
                List imageList = [];
                List itemList = list[index].items;
                for (int i = 0; i < itemList.length; i++) {
                  var element = itemList[i];
                  title +=
                      (element['name']?? 'Not define') +
                      ((i < itemList.length - 1) ? ', ' : ' ');
                  element['image'] != null? imageList.add(element['image']) : print('Image not found');
                }
                return InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: list[index]),));
                  },
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 80,
                            width: 80,
                            margin: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColour.lightGrey,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: imageList.isNotEmpty
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Image.network(
                                          imageList[0],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Visibility(
                                        visible: list[index].items.length > 1,
                                        child: Container(
                                          height: 20,
                                          width: 80,
                                          alignment: Alignment.center,
                                          color: AppColour.lightGrey,
                                          child: Text('+${list[index].items.length - 1} more',style: simple_text_style(fontSize: 12),),
                                        ),
                                      ),
                                    ],
                                ),
                            )
                                : Center(
                                    child: Text(
                                      'Error',
                                      style: simple_text_style(),
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title ?? 'Not Define',
                                  style: simple_text_style(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      '₹${list[index].total.toStringAsFixed(0)}',
                                      style: simple_text_style(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Container(
                                      height: 14,
                                      width: 2,
                                      color: AppColour.lightGrey,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '${list[index].items.length} Items',
                                      style: simple_text_style(
                                        color: AppColour.lightGrey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Container(
                                      height: 14,
                                      width: 2,
                                      color: AppColour.lightGrey,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      DateFormat(
                                        'hh:mm a',
                                      ).format(list[index].createdAt),
                                      style: simple_text_style(
                                        color: AppColour.lightGrey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Status : ${list[index].orderStatus}',
                                  style: simple_text_style(
                                    color: AppColour.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: elevated_button_style(),
                              onPressed: () {
                                showCancelOrderDialog(context, (reason) {
                                  context.read<OrderBloc>().add(
                                    CancelOrderEvent(
                                      orderId: list[index].orderId,
                                      cancellationReason: reason,
                                    ),
                                  );
                                });
                              },
                              child: Text(
                                'Cancel',
                                style: simple_text_style(
                                  color: AppColour.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12,),
                          Expanded(
                            child: ElevatedButton(
                              style: elevated_button_style(),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => OrderTrackingScreen(orderId: list[index].orderId),));
                              },
                              child: Text(
                                'Track',
                                style: simple_text_style(
                                  color: AppColour.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    ),
  );
}
