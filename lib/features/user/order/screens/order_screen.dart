import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/order/bloc/order_bloc.dart';
import 'package:raising_india/models/order_model.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int index = 1;

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(LoadUserCompletedOrderEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('My Orders', style: simple_text_style(fontSize: 20)),
            const Spacer(),
          ],
        ),
        backgroundColor: AppColour.white,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          return Column(
            children: [
              Container(
                height: 50,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          index = 0;
                          context.read<OrderBloc>().add(
                            LoadUserOngoingOrderEvent(),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Ongoing',
                            style: simple_text_style(
                              color: index == 0
                                  ? AppColour.primary
                                  : AppColour.lightGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          index = 1;
                          context.read<OrderBloc>().add(
                            LoadUserCompletedOrderEvent(),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'History',
                            style: simple_text_style(
                              color: index == 1
                                  ? AppColour.primary
                                  : AppColour.lightGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: AppColour.lightGrey.withOpacity(0.5)),
              state is OrderLoadedState
                  ? index == 0
                        ? onGoingPage(state.orderList)
                        : onCompletedPage(state.orderList)
                  : Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColour.primary,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget onGoingPage(List<OrderModel> list) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        alignment: Alignment.center,
        child: list.isEmpty
            ? Center(child: Text('No ongoing orders..'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return Column(
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
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Apple, Banana',
                                style: simple_text_style(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    '${list[index].total}',
                                    style: simple_text_style(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    height: 14,
                                    width: 2,
                                    color: AppColour.lightGrey,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${list[index].items.length}',
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
                                DateFormat('hh:mm a').format(list[index].createdAt),
                                style: simple_text_style(
                                  color: AppColour.lightGrey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: elevated_button_style(),
                        onPressed: () {},
                        child: Text(
                          'Cancel',
                          style: simple_text_style(
                            color: AppColour.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget onCompletedPage(List<OrderModel> list) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(12),
        child: list.isEmpty
            ? Center(child: Text('No History Orders..'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return Container(child: Text('Completed'));
                },
              ),
      ),
    );
  }
}
