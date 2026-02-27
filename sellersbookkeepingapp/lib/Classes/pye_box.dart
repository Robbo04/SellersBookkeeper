import 'item.dart';

class PyeBox {
  final int id;
  final DateTime date;
  final List<Item> items;

  final double totalPaidPrice;
  
  double get totalEarned => items.fold(0.00, (sum, item) => sum + item.sellingPrice);
  double get totalProfit => totalEarned - totalPaidPrice;

  int get totalItems => items.length;
  int get totalSoldItems => items.where((item) => item.isSold).length;
  bool get allSold => totalItems > 0 && totalItems == totalSoldItems;

  PyeBox({
    required this.id,
    required this.totalPaidPrice,
    required this.date,
    required this.items,
  });
}