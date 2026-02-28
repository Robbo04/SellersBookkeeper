class Item {
  final String name;
  String boughtFrom = '';
  DateTime boughtDate;

  bool isSold = false;
  double sellingPrice = 0.0;
  double retailPrice;
  double costPrice = 0.0;
  double soldPrice = 0.0;
  DateTime? soldDate;
  int? daysToSell = 0;

  double get profit => soldPrice - costPrice;

  Item({
    required this.name,
    this.boughtFrom = '',
    this.sellingPrice = 0.0,
    this.retailPrice = 0.0,
    this.costPrice = 0.0,
    this.soldPrice = 0.0,
    required this.boughtDate,
    this.soldDate,
  });

  dynamic soldItem() {
    if (!isSold) {
      soldPrice = sellingPrice;
      isSold = true;
      soldDate = DateTime.now();
      daysToSell = soldDate!.difference(boughtDate).inDays;
    }
  }

  changeSellingPrice(double newPrice) {
   if (!isSold) {
    if (newPrice <= 0) {
      // Show a warning dialog or message to the user
      print('Error: Selling price must be greater than zero.');
    }
    else {
      sellingPrice = newPrice;
    }
   }
   else {
    print('Error: Cannot change selling price of a sold item.');
   }
  }
}