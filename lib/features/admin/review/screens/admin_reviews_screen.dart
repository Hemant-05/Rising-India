import 'package:flutter/material.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/features/admin/review/bloc/admin_review_bloc.dart';
import 'package:raising_india/models/review_model.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen>
    with TickerProviderStateMixin {

  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _filterOptions = [
    'all',
    'high_rating',
    'low_rating',
    'recent'
  ];

  final List<String> _filterLabels = [
    'All Reviews',
    'High Ratings (4+)',
    'Low Ratings (≤2)',
    'Recent (7 days)'
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Load reviews
    context.read<AdminReviewBloc>().add(LoadAllReviews());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: BlocConsumer<AdminReviewBloc, AdminReviewState>(
        listener: (context, state) {
          if (state is AdminReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminReviewLoading) {
            return _buildLoadingState();
          } else if (state is AdminReviewLoaded) {
            return _buildLoadedState(state);
          } else if (state is AdminReviewError) {
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
          Text('Reviews', style: simple_text_style(fontSize: 20)),
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
            'Loading reviews...',
            style: simple_text_style(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
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
            'Something went wrong',
            style: simple_text_style(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: simple_text_style(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<AdminReviewBloc>().add(LoadAllReviews());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColour.primary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(AdminReviewLoaded state) {
    return RefreshIndicator(
      color: AppColour.primary,
      backgroundColor: AppColour.white,
      onRefresh: () async{
        context.read<AdminReviewBloc>().add(RefreshReviews());
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Statistics Header
            _buildStatsHeader(state),

            // Search and Filter Section
            _buildSearchAndFilterSection(state),

            // Reviews List
            Expanded(
              child: _buildReviewsList(state.filteredReviews),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(AdminReviewLoaded state) {
    return Container(
      margin: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Total Reviews',
                state.summary.totalReviews.toString(),
                Icons.rate_review,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withOpacity(0.3),
            ),
            Expanded(
              child: _buildStatItem(
                'Service Rating',
                state.summary.averageServiceRating.toStringAsFixed(1),
                Icons.room_service,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withOpacity(0.3),
            ),
            Expanded(
              child: _buildStatItem(
                'Product Rating',
                state.summary.averageProductRating.toStringAsFixed(1),
                Icons.shopping_basket,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: simple_text_style(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: simple_text_style(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterSection(AdminReviewLoaded state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<AdminReviewBloc>().add(SearchReviews(value));
              },
              decoration: InputDecoration(
                hintText: 'Search reviews, users, or order IDs...',
                prefixIcon: Icon(Icons.search, color: AppColour.primary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: simple_text_style(fontSize: 14),
            ),
          ),

          const SizedBox(height: 12),

          // Filter Chips and Sort Options
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filterOptions.length,
                    itemBuilder: (context, index) {
                      final isSelected = state.currentFilter == _filterOptions[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            _filterLabels[index],
                            style: simple_text_style(
                              color: isSelected ? Colors.white : AppColour.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            context.read<AdminReviewBloc>().add(FilterReviews(_filterOptions[index]));
                          },
                          backgroundColor: Colors.white,
                          selectedColor: AppColour.primary,
                          checkmarkColor: Colors.white,
                          side: BorderSide(color: AppColour.primary),
                        ),
                      );
                    },
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  final parts = value.split(' ');
                  final sortBy = parts[0];
                  final ascending = parts[1] == 'asc';
                  context.read<AdminReviewBloc>().add(
                    SortReviews(sortBy: sortBy, ascending: ascending),
                  );
                },
                color: AppColour.white,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'date desc',
                    child: Text('Sort by: Newest First',style: simple_text_style(),),
                  ),
                  PopupMenuItem(
                    value: 'date asc',
                    child: Text('Sort by: Oldest First',style: simple_text_style(),),
                  ),
                  PopupMenuItem(
                    value: 'user_name asc',
                    child: Text('Sort by: User Name (A-Z)',style: simple_text_style(),),
                  ),
                  PopupMenuItem(
                    value: 'user_name desc',
                    child: Text('Sort by: User Name (Z-A)',style: simple_text_style(),),
                  ),
                  PopupMenuItem(
                    value: 'service_rating desc',
                    child: Text('Sort by: Higher Service Rating',style: simple_text_style(),),
                  ),
                  PopupMenuItem(
                    value: 'product_rating desc',
                    child: Text('Sort by: Higher Product Rating',style: simple_text_style(),),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColour.primary),
                  ),
                  child: Icon(Icons.sort, color: AppColour.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(List<ReviewModel> reviews) {
    if (reviews.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return _buildReviewCard(review, index);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews found',
            style: simple_text_style(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reviews will appear here when customers submit them',
            style: simple_text_style(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with user info and ratings
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColour.primary.withOpacity(0.1),
                        AppColour.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User and Order Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColour.primary,
                            child: Text(
                              review.userName.isNotEmpty
                                  ? review.userName[0].toUpperCase()
                                  : 'U',
                              style: simple_text_style(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.userName.isEmpty? 'Unknown User' : review.userName,
                                  style: simple_text_style(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.receipt, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Id #${review.orderId.substring(0, 8)}',
                                      style: simple_text_style(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('d/M/yy, hh:mm a').format(review.createdAt),
                                      style: simple_text_style(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Ratings Section
                      Row(
                        children: [
                          Expanded(
                            child: _buildRatingSection(
                              'Service',
                              review.serviceRating,
                              Icons.room_service,
                              Colors.blue,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: _buildRatingSection(
                              'Product',
                              review.productRating,
                              Icons.shopping_basket,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Reviews Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (review.serviceReview.isNotEmpty) ...[
                        _buildReviewSection(
                          'Service Review',
                          review.serviceReview,
                          Icons.room_service,
                          Colors.blue,
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (review.productReview.isNotEmpty) ...[
                        _buildReviewSection(
                          'Product Review',
                          review.productReview,
                          Icons.shopping_basket,
                          Colors.green,
                        ),
                      ],

                      if (review.serviceReview.isEmpty && review.productReview.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'No written review provided',
                            style: TextStyle(
                              fontFamily: 'Sen',
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingSection(String title, double rating, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: simple_text_style(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          title,
          style: simple_text_style(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: simple_text_style(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(
            content,
            style: simple_text_style(
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
