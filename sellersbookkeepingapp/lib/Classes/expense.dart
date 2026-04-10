import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 3)
class Expense extends HiveObject {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final double amount;
  
  @HiveField(2)
  final DateTime date;

  Expense({
    required this.name,
    required this.amount,
    required this.date,
  });
}
