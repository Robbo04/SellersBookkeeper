import 'package:hive_flutter/hive_flutter.dart';
import '../Classes/item.dart';
import '../Classes/pye_box.dart';

class StorageService {
  static const String itemsBoxName = 'items';
  static const String boxesBoxName = 'boxes';
  
  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(ItemAdapter());
    Hive.registerAdapter(PyeBoxAdapter());
    
    // Open boxes
    await Hive.openBox<Item>(itemsBoxName);
    await Hive.openBox<PyeBox>(boxesBoxName);
  }
  
  // Get boxes
  static Box<Item> get itemsBox => Hive.box<Item>(itemsBoxName);
  static Box<PyeBox> get boxesBox => Hive.box<PyeBox>(boxesBoxName);
  
  // ===== ITEMS OPERATIONS =====
  
  /// Get all items as a list
  static List<Item> getAllItems() {
    return itemsBox.values.toList();
  }
  
  /// Add a new item
  static Future<void> addItem(Item item) async {
    await itemsBox.add(item);
  }
  
  /// Update an existing item
  static Future<void> updateItem(int index, Item item) async {
    await itemsBox.putAt(index, item);
  }
  
  /// Delete an item by index
  static Future<void> deleteItem(int index) async {
    await itemsBox.deleteAt(index);
  }
  
  /// Delete an item by key
  static Future<void> deleteItemByKey(dynamic key) async {
    await itemsBox.delete(key);
  }
  
  /// Clear all items
  static Future<void> clearAllItems() async {
    await itemsBox.clear();
  }
  
  // ===== BOXES OPERATIONS =====
  
  /// Get all boxes as a list
  static List<PyeBox> getAllBoxes() {
    return boxesBox.values.toList();
  }
  
  /// Add a new box
  static Future<void> addBox(PyeBox box) async {
    await boxesBox.add(box);
  }
  
  /// Update an existing box
  static Future<void> updateBox(int index, PyeBox box) async {
    await boxesBox.putAt(index, box);
  }
  
  /// Delete a box by index
  static Future<void> deleteBox(int index) async {
    await boxesBox.deleteAt(index);
  }
  
  /// Delete a box by key
  static Future<void> deleteBoxByKey(dynamic key) async {
    await boxesBox.delete(key);
  }
  
  /// Clear all boxes
  static Future<void> clearAllBoxes() async {
    await boxesBox.clear();
  }
  
  // ===== UTILITY OPERATIONS =====
  
  /// Get total number of items
  static int getTotalItemsCount() {
    return itemsBox.length;
  }
  
  /// Get total number of boxes
  static int getTotalBoxesCount() {
    return boxesBox.length;
  }
  
  /// Get count of sold items
  static int getSoldItemsCount() {
    return itemsBox.values.where((item) => item.isSold).length;
  }
  
  /// Close all boxes (call when app closes)
  static Future<void> closeAll() async {
    await itemsBox.close();
    await boxesBox.close();
  }
}
