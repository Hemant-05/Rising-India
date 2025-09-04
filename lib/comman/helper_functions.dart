double calculatePercentage(double? mrp, double price){
  double percent = 0;
  mrp == null? mrp = price + 5 : mrp = mrp;
  double offvalue = mrp - price;
  percent = (offvalue / mrp) * 100;
  return percent.floorToDouble();
}