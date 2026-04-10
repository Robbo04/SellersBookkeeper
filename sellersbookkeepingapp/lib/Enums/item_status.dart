import 'package:hive/hive.dart';

part 'item_status.g.dart';

@HiveType(typeId: 2)
enum ItemStatus {
  @HiveField(0)
  listed,
  
  @HiveField(1)
  sold,
  
  @HiveField(2)
  lost,
}
