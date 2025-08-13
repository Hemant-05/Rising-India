// lib/screens/user/review/review_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/review/bloc/review_bloc.dart';
import 'package:raising_india/models/order_model.dart';

import '../../../../comman/simple_text_style.dart' show simple_text_style;

class ReviewScreen extends StatefulWidget {
  final String orderId;

  const ReviewScreen({super.key, required this.orderId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _serviceReviewController =
      TextEditingController();
  final TextEditingController _productReviewController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    // Load order for review
    context.read<ReviewBloc>().add(LoadOrderForReview(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is ReviewSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.pop(context);
          } else if (state is ReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ReviewLoading) {
            return _buildLoadingState();
          } else if (state is OrderLoadedForReview) {
            return _buildReviewForm(state);
          } else if (state is ReviewSubmitting) {
            return _buildSubmittingState();
          } else if (state is ReviewError) {
            return _buildErrorState(state.message);
          }
          return Container();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: AppColour.white,
      title: Row(
        children: [
          back_button(),
          const SizedBox(width: 8),
          Text('Review', style: simple_text_style(fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColour.primary),
          const SizedBox(height: 16),
          Text(
            'Loading order details...',
            style: simple_text_style(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColour.primary),
          const SizedBox(height: 16),
          Text(
            'Submitting your review...',
            style: simple_text_style(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: simple_text_style(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: simple_text_style(color: Colors.grey.shade600, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<ReviewBloc>().add(
                LoadOrderForReview(widget.orderId),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColour.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Try Again',
              style: simple_text_style(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewForm(OrderLoadedForReview state) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummaryCard(state.order),
              const SizedBox(height: 20),
              _buildServiceRatingSection(state),
              const SizedBox(height: 20),
              _buildProductRatingSection(state),
              const SizedBox(height: 30),
              _buildSubmitButton(state),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColour.primary, AppColour.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColour.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderId.substring(0, 8)}',
                        style: simple_text_style(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Delivered Successfully',
                        style: simple_text_style(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${order.items.length} items',
                    style: simple_text_style(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Help us improve by sharing your experience!',
              style: simple_text_style(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRatingSection(OrderLoadedForReview state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.room_service,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Quality',
                        style: simple_text_style(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rate our delivery and customer service',
                        style: simple_text_style(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Star Rating for Service
            _buildStarRating(
              rating: state.serviceRating,
              onRatingUpdate: (rating) {
                context.read<ReviewBloc>().add(UpdateServiceRating(rating));
              },
            ),

            const SizedBox(height: 16),

            // Service Review Text Field
            _buildReviewTextField(
              controller: _serviceReviewController,
              hintText: 'Tell us about our service quality (optional)',
              initialValue: state.serviceReview,
              onChanged: (value) {
                print('helll----------');
                context.read<ReviewBloc>().add(UpdateServiceReview(value));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRatingSection(OrderLoadedForReview state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.shopping_basket,
                    color: Colors.green.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Quality',
                        style: simple_text_style(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rate the quality of products you received',
                        style: simple_text_style(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Star Rating for Products
            _buildStarRating(
              rating: state.productRating,
              onRatingUpdate: (rating) {
                context.read<ReviewBloc>().add(UpdateProductRating(rating));
              },
            ),

            const SizedBox(height: 16),

            // Product Review Text Field
            _buildReviewTextField(
              controller: _productReviewController,
              hintText: 'Tell us about the product quality (optional)',
              initialValue: state.productReview,
              onChanged: (value) {
                context.read<ReviewBloc>().add(UpdateProductReview(value));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating({
    required double rating,
    required Function(double) onRatingUpdate,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRatingUpdate((index + 1).toDouble()),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              index < rating ? Icons.star : Icons.star_border,
              size: 40,
              color: index < rating ? Colors.amber : Colors.grey.shade400,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildReviewTextField({
    required TextEditingController controller,
    required String hintText,
    required String initialValue,
    required Function(String) onChanged,
  }) {
    if (controller.text != initialValue) {
      controller.text = initialValue;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: simple_text_style(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: simple_text_style(fontSize: 14),
      ),
    );
  }

  Widget _buildSubmitButton(OrderLoadedForReview state) {
    final bool canSubmit = state.serviceRating > 0 && state.productRating > 0;
    final bool isUpdate = state.hasExistingReview;

    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: canSubmit
            ? LinearGradient(
          colors: [AppColour.primary, AppColour.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: canSubmit ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        boxShadow: canSubmit ? [
          BoxShadow(
            color: AppColour.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ] : null,
      ),
      child: ElevatedButton(
        onPressed: canSubmit ? () => _submitReview(state) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpdate ? Icons.update : Icons.send_rounded, // ✅ Different icons
              color: canSubmit ? Colors.white : Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              isUpdate ? 'Update Review' : 'Submit Review', // ✅ Different text
              style: simple_text_style(
                color: canSubmit ? Colors.white : Colors.grey.shade500,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview(OrderLoadedForReview state) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final productIds = state.order.items
        .map((item) => item['productId'] as String)
        .toList();
    var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final name = doc.data()!['name'];
    if (state.hasExistingReview && state.existingReviewId != null) {
      context.read<ReviewBloc>().add(
        UpdateExistingReview(
          reviewId: state.existingReviewId!,
          orderId: widget.orderId,
          userId: user.uid,
          userName: name,
          productIds: productIds,
        ),
      );
    } else {
      context.read<ReviewBloc>().add(
        SubmitReview(
          orderId: widget.orderId,
          userId: user.uid,
          userName: name,
          productIds: productIds,
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _serviceReviewController.dispose();
    _productReviewController.dispose();
    super.dispose();
  }
}
