import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/features/user/cart/screens/cart_screen.dart';
import 'package:raising_india/features/user/product_details/widgets/details_card.dart';
import 'package:raising_india/models/product_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../bloc/product_funtction_bloc/product_fun_bloc.dart';

class ProductDetailsScreen extends StatelessWidget {
  ProductDetailsScreen({super.key, required this.product});
  final ProductModel product;
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductFunBloc, ProductFunState>(
      builder: (context, state) {
        var totalPrice = product.price * state.quantity;
        return state.isLoadingProductDetails
            ? Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppColour.primary),
                ),
              )
            : Scaffold(
                backgroundColor: AppColour.white,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: AppColour.white,
                  title: Row(
                    children: [
                      back_button(),
                      const SizedBox(width: 10),
                      Text("Details", style: simple_text_style(fontSize: 20)),
                      const Spacer(),
                    ],
                  ),
                ),
                body: Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 250,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: product.photos_list.length,
                                  itemBuilder: (context, index) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Image.network(
                                        product.photos_list[index],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        loadingBuilder:
                                            (context, child, progress) {
                                              if (progress == null) {
                                                return child;
                                              }
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color:
                                                          AppColour.primary,
                                                    ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Center(
                                                  child: Icon(
                                                    Icons.error_outline,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 10),
                              Center(
                                child: SmoothPageIndicator(
                                  controller: _pageController,
                                  count: product.photos_list.length,
                                  effect: ExpandingDotsEffect(
                                    activeDotColor: AppColour.primary,
                                    dotColor: AppColour.lightGrey,
                                    dotHeight: 8,
                                    dotWidth: 8,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                state.product!.name,
                                style: simple_text_style(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                state.product!.description,
                                style: TextStyle(
                                  fontFamily: 'Sen',
                                  fontSize: 16,
                                  color: AppColour.lightGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  SvgPicture.asset(star_svg, width: 16),
                                  SizedBox(width: 5),
                                  Text(
                                    state.product!.rating.toString(),
                                    style: simple_text_style(
                                      color: AppColour.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  details_card(
                                    icon: clock_svg,
                                    title: '20 mins',
                                    isIcon: true,
                                  ),
                                  details_card(
                                    icon: delivery_svg,
                                    title: 'Fast Delivery',
                                    isIcon: true,
                                  ),
                                  details_card(
                                    icon: state.product!.quantity.toString(),
                                    title: state.product!.measurement,
                                    isIcon: false,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: state.isCheckingIsInCart
                          ? Center(
                              child: CircularProgressIndicator(
                                color: AppColour.primary,
                              ),
                            )
                          : Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                color: AppColour.lightGrey.withOpacity(0.2),
                              ),
                              child: state.product!.isAvailable
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '₹ $totalPrice',
                                              style: simple_text_style(
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColour.black,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColour.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 5,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: state.isInCart
                                                  ? Text(
                                                      state.quantity.toString(),
                                                      style: simple_text_style(
                                                        fontSize: 18,
                                                        color: AppColour.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  : Row(
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            context
                                                                .read<
                                                                  ProductFunBloc
                                                                >()
                                                                .add(
                                                                  DecreaseQuantity(),
                                                                );
                                                          },
                                                          child: Icon(
                                                            Icons.remove,
                                                            color:
                                                                AppColour.white,
                                                          ),
                                                        ),
                                                        SizedBox(width: 14),
                                                        Text(
                                                          state.quantity
                                                              .toString(),
                                                          style:
                                                              simple_text_style(
                                                                fontSize: 18,
                                                                color: AppColour
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        SizedBox(width: 14),
                                                        InkWell(
                                                          onTap: () {
                                                            context
                                                                .read<
                                                                  ProductFunBloc
                                                                >()
                                                                .add(
                                                                  IncreaseQuantity(),
                                                                );
                                                          },
                                                          child: Icon(
                                                            Icons.add,
                                                            color:
                                                                AppColour.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        state.isAddingToCart
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                            : ElevatedButton(
                                                style: elevated_button_style(),
                                                onPressed: state.isInCart
                                                    ? () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                CartScreen(),
                                                          ),
                                                        );
                                                      }
                                                    : () {
                                                        context
                                                            .read<
                                                              ProductFunBloc
                                                            >()
                                                            .add(
                                                              AddToCartPressed(
                                                                productId:
                                                                    product.pid,
                                                              ),
                                                            );
                                                        context
                                                            .read<
                                                              ProductFunBloc
                                                            >()
                                                            .add(
                                                              CheckIsInCart(
                                                                productId:
                                                                    product.pid,
                                                              ),
                                                            );
                                                      },
                                                child: Text(
                                                  state.isInCart
                                                      ? "GO TO CART"
                                                      : "ADD TO CART",
                                                  style: simple_text_style(
                                                    color: AppColour.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    )
                                  : Text(
                                      'OUT OF STOCK !!!',
                                      style: simple_text_style(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                            ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}
