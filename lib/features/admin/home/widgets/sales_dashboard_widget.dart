// lib/widgets/admin/sales_dashboard_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/admin/sales_analytics/bloc/sales_analytics_bloc.dart';
import 'package:raising_india/features/admin/sales_analytics/widget/sales_chart_widget.dart';
import 'package:raising_india/models/period_stats_model.dart';
import 'package:raising_india/models/sales_data_model.dart';

class SalesDashboardWidget extends StatelessWidget {
  const SalesDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesAnalyticsBloc, SalesAnalyticsState>(
      builder: (context, state) {
        if (state is SalesAnalyticsLoading) {
          return _buildLoadingWidget();
        } else if (state is SalesAnalyticsLoaded) {
          return _buildLoadedWidget(state);
        } else if (state is SalesAnalyticsError) {
          return _buildErrorWidget(state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 400,
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColour.primary),
            const SizedBox(height: 16),
            Text(
              'Loading sales data...',
              style: simple_text_style(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      height: 400,
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error loading sales data',
              style: simple_text_style(
                color: Colors.red.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: simple_text_style(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedWidget(SalesAnalyticsLoaded state) {
    return Column(
      children: [
        // Stats Cards
        _buildStatsRow(state.currentPeriodStats),
        const SizedBox(height: 20),

        // Chart with Period Selector
        _buildChartSection(state),
      ],
    );
  }

  Widget _buildStatsRow(PeriodStatsModel periodStats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Revenue',
                value: '₹${_formatNumber(periodStats.totalRevenue)}',
                icon: Icons.attach_money,
                color: Colors.green,
                subtitle: periodStats.periodLabel,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Total Orders',
                value: periodStats.totalOrders.toString(),
                icon: Icons.shopping_cart,
                color: Colors.blue,
                subtitle: periodStats.periodLabel,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Avg Order Value',
                value: '₹${_formatNumber(periodStats.averageOrderValue)}',
                icon: Icons.trending_up,
                color: Colors.orange,
                subtitle: 'Per order',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Growth',
                value: '${periodStats.growthPercentage.toStringAsFixed(1)}%',
                icon: periodStats.growthPercentage >= 0
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: periodStats.growthPercentage >= 0 ? Colors.green : Colors.red,
                subtitle: 'vs previous period',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: simple_text_style(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: simple_text_style(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            subtitle,
            style: simple_text_style(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(SalesAnalyticsLoaded state) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Overview',
            style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12,),
          _buildPeriodSelector(state),
          SizedBox(height: 8,),

          // Chart
          SalesChartWidget(
            salesData: state.currentPeriodData,
            period: state.currentPeriod,
            isBarChart: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(SalesAnalyticsLoaded state) {
    return Row(
      children: [
        _buildPeriodButton('Day', SalesTimePeriod.day, state.currentPeriod),
        const SizedBox(width: 8),
        _buildPeriodButton('Week', SalesTimePeriod.week, state.currentPeriod),
        const SizedBox(width: 8),
        _buildPeriodButton('Month', SalesTimePeriod.month, state.currentPeriod),
      ],
    );
  }

  Widget _buildPeriodButton(
    String label,
    SalesTimePeriod period,
    SalesTimePeriod currentPeriod,
  ) {
    final isSelected = period == currentPeriod;

    return BlocBuilder<SalesAnalyticsBloc, SalesAnalyticsState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            context.read<SalesAnalyticsBloc>().add(
              ChangeSalesTimePeriod(period),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColour.primary : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColour.primary : Colors.grey.shade300,
              ),
            ),
            child: Text(
              label,
              style: simple_text_style(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
