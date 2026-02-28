import 'package:hive/hive.dart';
import 'item.dart';

part 'pye_box.g.dart';

@HiveType(typeId: 1)
class PyeBox extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final DateTime date;
  
  @HiveField(2)
  final List<Item> items;

  @HiveField(3)
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