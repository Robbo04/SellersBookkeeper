import 'package:hive_flutter/hive_flutter.dart';
import '../Classes/item.dart';
import '../Classes/pye_box.dart';
import '../Classes/expense.dart';
import '../Enums/date_filter_type.dart';
import '../Enums/item_status.dart';

class StorageService {
  static const String itemsBoxName = 'items';
  static const String boxesBoxName = 'boxes';
  static const String expensesBoxName = 'expenses';
  
  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(ItemAdapter());
    Hive.registerAdapter(PyeBoxAdapter());
    Hive.registerAdapter(ItemStatusAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    
    // Check if we need to migrate old data format
    await _migrateOldDataFormat();
    
    // Open boxes
    await Hive.openBox<Item>(itemsBoxName);
    await Hive.openBox<PyeBox>(boxesBoxName);
    await Hive.openBox<Expense>(expensesBoxName);
  }
  
  // Migrate old boolean format to new enum format
  static Future<void> _migrateOldDataFormat() async {
    try {
      // Try to open and read the box with old format
      final tempBox = await Hive.openBox(itemsBoxName);
      
      // Try to access the data - if this succeeds with new format, we're good
      // If it fails, we'll catch the error and delete
      if (tempBox.isNotEmpty) {
        // Try to read first item to check compatibility
        tempBox.getAt(0);
      }
      
      await tempBox.close();
    } catch (e) {
      // If we get a type error, delete the old incompatible boxes
      print('Detected old data format, clearing to migrate to new enum format...');
      print('Error: $e');
      
      // Delete the box files to clear old data
      await Hive.deleteBoxFromDisk(itemsBoxName);
      await Hive.deleteBoxFromDisk(boxesBoxName);
      
      print('Migration complete - old data cleared');
    }
  }
  
  // Get boxes
  static Box<Item> get itemsBox => Hive.box<Item>(itemsBoxName);
  static Box<PyeBox> get boxesBox => Hive.box<PyeBox>(boxesBoxName);
  static Box<Expense> get expensesBox => Hive.box<Expense>(expensesBoxName);
  
  // ===== ITEMS OPERATIONS =====
  
  /// Get all items as a list
  static List<Item> getAllItems() {
    return itemsBox.values.toList();
  }
  
  /// Get all items including items from boxes
  static List<Item> getAllItemsIncludingBoxes() {
    final standaloneItems = itemsBox.values.toList();
    final boxes = boxesBox.values.toList();
    
    // Get all items from all boxes
    final boxItems = <Item>[];
    for (var box in boxes) {
      boxItems.addAll(box.items);
    }
    
    // Combine standalone items and box items
    return [...standaloneItems, ...boxItems];
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
  
  // ===== EXPENSES OPERATIONS =====
  
  /// Get all expenses as a list
  static List<Expense> getAllExpenses() {
    return expensesBox.values.toList();
  }
  
  /// Add a new expense
  static Future<void> addExpense(Expense expense) async {
    await expensesBox.add(expense);
  }
  
  /// Update an existing expense
  static Future<void> updateExpense(int index, Expense expense) async {
    await expensesBox.putAt(index, expense);
  }
  
  /// Delete an expense by index
  static Future<void> deleteExpense(int index) async {
    await expensesBox.deleteAt(index);
  }
  
  /// Delete an expense by key
  static Future<void> deleteExpenseByKey(dynamic key) async {
    await expensesBox.delete(key);
  }
  
  /// Clear all expenses
  static Future<void> clearAllExpenses() async {
    await expensesBox.clear();
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
  
  // ===== DATE FILTERING OPERATIONS =====
  
  /// Get items filtered by date
  static List<Item> getItemsByDateFilter(
    DateFilterType filterType,
    DateTime? selectedDate,
  ) {
    if (filterType == DateFilterType.all) {
      return getAllItems();
    }
    
    if (selectedDate == null) {
      return getAllItems();
    }
    
    final allItems = getAllItems();
    
    return allItems.where((item) {
      bool matchesBoughtDate = _dateMatches(item.boughtDate, selectedDate, filterType);
      bool matchesSoldDate = item.soldDate != null && 
                             _dateMatches(item.soldDate!, selectedDate, filterType);
      
      return matchesBoughtDate || matchesSoldDate;
    }).toList();
  }
  
  /// Helper method to check if a date matches the filter
  static bool _dateMatches(DateTime date, DateTime selected, DateFilterType filterType) {
    switch (filterType) {
      case DateFilterType.day:
        return date.year == selected.year &&
               date.month == selected.month &&
               date.day == selected.day;
      case DateFilterType.month:
        return date.year == selected.year &&
               date.month == selected.month;
      case DateFilterType.year:
        return date.year == selected.year;
      case DateFilterType.all:
        return true;
    }
  }
  
  /// Get items bought in the specified date range
  static List<Item> getItemsBought(
    DateFilterType filterType,
    DateTime? selectedDate,
  ) {
    final filteredItems = getItemsByDateFilter(filterType, selectedDate);
    
    if (filterType == DateFilterType.all) {
      return filteredItems;
    }
    
    if (selectedDate == null) {
      return filteredItems;
    }
    
    return filteredItems.where((item) {
      return _dateMatches(item.boughtDate, selectedDate, filterType);
    }).toList();
  }
  
  /// Get items sold in the specified date range
  static List<Item> getItemsSold(
    DateFilterType filterType,
    DateTime? selectedDate,
  ) {
    final filteredItems = getItemsByDateFilter(filterType, selectedDate);
    
    if (filterType == DateFilterType.all) {
      return filteredItems.where((item) => item.soldDate != null).toList();
    }
    
    if (selectedDate == null) {
      return filteredItems.where((item) => item.soldDate != null).toList();
    }
    
    return filteredItems.where((item) {
      return item.soldDate != null && 
             _dateMatches(item.soldDate!, selectedDate, filterType);
    }).toList();
  }
  
  /// Get count of sold items
  static int getSoldItemsCount() {
    return itemsBox.values.where((item) => item.isSold).length;
  }
  
  /// Close all boxes (call when app closes)
  static Future<void> closeAll() async {
    await itemsBox.close();
    await boxesBox.close();
    await expensesBox.close();
  }
}
