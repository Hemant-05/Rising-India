class PeriodStatsModel {
  final double totalRevenue;
  final int totalOrders;
  final double averageOrderValue;
  final double growthPercentage;
  final String periodLabel;

  PeriodStatsModel({
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.growthPercentage,
    required this.periodLabel,
  });
}