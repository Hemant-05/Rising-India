import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/comman/cart_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/features/auth/services/auth_service.dart';
import 'package:raising_india/features/user/address/screens/select_address_screen.dart';
import 'package:raising_india/features/user/home/bloc/user_product_bloc/category_product_bloc.dart';
import 'package:raising_india/features/user/home/widgets/categories_section.dart';
import 'package:raising_india/features/user/home/widgets/product_grid.dart';
import 'package:raising_india/features/user/home/widgets/search_bar_widget.dart';
import 'package:raising_india/features/user/order/bloc/order_bloc.dart';
import 'package:raising_india/features/user/order/screens/order_details_screen.dart';
import 'package:raising_india/features/user/order/screens/order_screen.dart';
import 'package:raising_india/features/user/order/screens/order_tracking_screen.dart';
import 'package:raising_india/features/user/order/widgets/on_going_widget.dart';
import 'package:raising_india/features/user/profile/bloc/profile_bloc.dart';
import 'package:raising_india/features/user/profile/screens/profile_screen.dart';
import 'package:raising_india/models/order_model.dart';
import '../../../auth/bloc/auth_bloc.dart';

class HomeScreenU extends StatefulWidget {
  const HomeScreenU({super.key});

  @override
  State<HomeScreenU> createState() => _HomeScreenUState();
}

class _HomeScreenUState extends State<HomeScreenU> {
  AuthService authService = AuthService();
  String address = 'Fetching address...';
  String name = 'there';

  @override
  void initState() {
    super.initState();
    BlocProvider.of<CategoryProductBloc>(context).add(FetchBestSellingProducts());
    BlocProvider.of<OrderBloc>(context).add(LoadUserOngoingOrderEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserAuthenticated) {
          address = state.user.addressList.isNotEmpty
              ? state.user.addressList[0].address
              : '';
          name = state.user.name.split(' ').first;
        } else if (state is UserUnauthenticated) {
          return Scaffold(
            body: Center(child: Text('Please log in to continue')),
          );
        } else if (state is UserError) {
          return Scaffold(
            body: Center(child: Text('Error: ${state.message}')),
          );
        }
        return Scaffold(
          backgroundColor: AppColour.white,
          appBar: AppBar(
            backgroundColor: AppColour.white,
            title: Row(
              children: [
                InkWell(
                  onTap: (){
                    context.read<ProfileBloc>().add(OnProfileOpened());
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColour.primary,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(Icons.person, color: AppColour.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DELIVER TO',
                        style: simple_text_style(
                          color: AppColour.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectAddressScreen(
                                isFromProfile: true,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          address.isNotEmpty ? address : 'Tap to add address...',
                          style: simple_text_style(
                            color: AppColour.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                cart_button(),
              ],
            ),
          ),
          body: RefreshIndicator(
            color: AppColour.primary,
            backgroundColor: AppColour.white,
            onRefresh: () async {
              BlocProvider.of<CategoryProductBloc>(context).add(FetchBestSellingProducts());
              context.read<OrderBloc>().add(LoadUserOngoingOrderEvent());
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Section
                    _buildGreetingSection(),
                    const SizedBox(height: 14),

                    // Search Bar
                    search_bar_widget(context),
                    const SizedBox(height: 14),

                    // Categories Section
                    categories_section(context),
                    const SizedBox(height: 20),

                    // Ongoing Orders Section
                    _buildOngoingOrdersSection(),
                    const SizedBox(height: 16),

                    // Best Products Section
                    _buildBestProductsSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreetingSection() {
    return RichText(
      text: TextSpan(
        text: 'Hey $name, ',
        style: simple_text_style(
          color: AppColour.black,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(
            text: 'Welcome to Raising India',
            style: simple_text_style(
              color: AppColour.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOngoingOrdersSection() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state is CompletedOrderLoadedState?'History Orders':
                  'Ongoing Orders',
                  style: simple_text_style(
                    color: AppColour.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Order Content
            if (state is OrderLoadingState)
              _buildOrderLoadingState()
            else if (state is OngoingOrderLoadedState)
              state.orderList.isEmpty
                  ? _buildEmptyOrderState()
                  : _buildOrdersList(state.orderList)
            else if (state is CompletedOrderLoadedState)
                state.orderList.isEmpty
                    ? _buildEmptyOrderState()
                    : _buildOrdersList(state.orderList)
            else if (state is OrderErrorState)
                _buildOrderErrorState(state.error ?? 'Unknown error')
              else
                _buildOrderLoadingState(),
          ],
        );
      },
    );
  }

  Widget _buildOrderLoadingState() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColour.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColour.primary, strokeWidth: 2),
            const SizedBox(height: 12),
            Text(
              'Loading your orders...',
              style: simple_text_style(
                color: AppColour.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrderState() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No ongoing orders',
            style: simple_text_style(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start shopping to see your orders here',
            style: simple_text_style(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderErrorState(String error) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 12),
          Text(
            'Error loading orders',
            style: simple_text_style(
              color: Colors.red.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: simple_text_style(
              color: Colors.red.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              context.read<OrderBloc>().add(LoadUserOngoingOrderEvent());
            },
            child: Text('Retry', style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    Color statusColor = _getStatusColor(order.orderStatus);

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderTrackingScreen(orderId: order.orderId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Order ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${order.orderId.substring(0, 6)}',
                    style: simple_text_style(
                      color: AppColour.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(order.orderStatus),
                      style: simple_text_style(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Items count
              Text(
                '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                style: simple_text_style(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 4),

              // Order date
              Text(
                DateFormat('MMM d, h:mm a').format(order.createdAt),
                style: simple_text_style(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),

              // Total amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: simple_text_style(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₹${order.total.toStringAsFixed(2)}',
                    style: simple_text_style(
                      color: AppColour.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBestProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Best Products',
          style: simple_text_style(
            color: AppColour.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<CategoryProductBloc, CategoryProductState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Container(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: AppColour.primary),
                ),
              );
            } else if (state.bestSellingProducts.isEmpty) {
              return Container(
                height: 200,
                child: Center(
                  child: Text(
                    'No Best Selling Products Available',
                    style: simple_text_style(
                      color: AppColour.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            } else if (state.error != null) {
              return Container(
                height: 200,
                child: Center(child: Text(state.error!)),
              );
            } else {
              return ProductGrid(products: state.bestSellingProducts);
            }
          },
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case OrderStatusCreated:
        return Colors.blue;
      case OrderStatusConfirmed:
        return Colors.green;
      case OrderStatusPreparing:
        return Colors.orange;
      case OrderStatusDispatch:
        return Colors.purple;
      case OrderStatusDeliverd:
        return Colors.green.shade700;
      case OrderStatusCancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case OrderStatusCreated:
        return 'Placed';
      case OrderStatusConfirmed:
        return 'Confirmed';
      case OrderStatusPreparing:
        return 'Preparing';
      case OrderStatusDispatch:
        return 'Dispatched';
      case OrderStatusDeliverd:
        return 'Delivered';
      case OrderStatusCancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }
}
