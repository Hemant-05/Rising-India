import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/review/bloc/admin_review_bloc.dart';

class ReviewAnalyticsWidget extends StatelessWidget {
  const ReviewAnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminReviewBloc, AdminReviewState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
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
          child: state is AdminReviewLoaded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Review Analytics',
                          style: simple_text_style(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            context.read<AdminReviewBloc>().add(
                              LoadAllReviews(),
                            );
                          },
                          child: Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickStat(
                            'Total Reviews',
                            state.summary.totalReviews.toString(),
                            Icons.rate_review,
                            Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: _buildQuickStat(
                            'Avg Rating',
                            ((state.summary.averageServiceRating +
                                        state.summary.averageProductRating) /
                                    2)
                                .toStringAsFixed(1),
                            Icons.star,
                            Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(color: AppColour.primary),
                ),
        );
      },
    );
  }

  Widget _buildQuickStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: simple_text_style(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: simple_text_style(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
