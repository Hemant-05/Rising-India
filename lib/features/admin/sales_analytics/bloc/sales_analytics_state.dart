part of 'sales_analytics_bloc.dart';

// lib/blocs/sales_analytics/sales_analytics_state.dart
abstract class SalesAnalyticsState {}

class SalesAnalyticsInitial extends SalesAnalyticsState {}

class SalesAnalyticsLoading extends SalesAnalyticsState {}

class SalesAnalyticsLoaded extends SalesAnalyticsState {
  final SalesAnalyticsModel analytics;
  final SalesTimePeriod currentPeriod;
  final List<SalesDataModel> currentPeriodData;
  final PeriodStatsModel currentPeriodStats;

  SalesAnalyticsLoaded({
    required this.analytics,
    required this.currentPeriod,
    required this.currentPeriodData,
    required this.currentPeriodStats,
  });

  SalesAnalyticsLoaded copyWith({
    SalesAnalyticsModel? analytics,
    SalesTimePeriod? currentPeriod,
    List<SalesDataModel>? currentPeriodData,
    PeriodStatsModel? currentPeriodStats,
  }) {
    return SalesAnalyticsLoaded(
      analytics: analytics ?? this.analytics,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      currentPeriodData: currentPeriodData ?? this.currentPeriodData,
      currentPeriodStats: currentPeriodStats ?? this.currentPeriodStats,
    );
  }
}

class SalesAnalyticsError extends SalesAnalyticsState {
  final String message;
  SalesAnalyticsError(this.message);
}
