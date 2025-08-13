part of 'sales_analytics_bloc.dart';

// lib/blocs/sales_analytics/sales_analytics_event.dart
abstract class SalesAnalyticsEvent {}

class LoadSalesAnalytics extends SalesAnalyticsEvent {}

class ChangeSalesTimePeriod extends SalesAnalyticsEvent {
  final SalesTimePeriod period;
  ChangeSalesTimePeriod(this.period);
}

class RefreshSalesData extends SalesAnalyticsEvent {}

class LoadCustomPeriodSales extends SalesAnalyticsEvent {
  final DateTime startDate;
  final DateTime endDate;
  final SalesTimePeriod period;

  LoadCustomPeriodSales({
    required this.startDate,
    required this.endDate,
    required this.period,
  });
}
