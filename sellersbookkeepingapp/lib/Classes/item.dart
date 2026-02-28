import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  String boughtFrom = '';
  
  @HiveField(2)
  DateTime boughtDate;

  @HiveField(3)
  bool isSold = false;
  
  @HiveField(4)
  double sellingPrice = 0.0;
  
  @HiveField(5)
  double retailPrice;
  
  @HiveField(6)
  double costPrice = 0.0;
  
  @HiveField(7)
  double soldPrice = 0.0;
  
  @HiveField(8)
  DateTime? soldDate;
  
  @HiveField(9)
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