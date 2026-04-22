import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../Classes/item.dart';
import '../Classes/pye_box.dart';
import '../Classes/expense.dart';
import '../Classes/tax.dart';
import '../Enums/date_filter_type.dart';
import '../Enums/item_status.dart';

class StorageService {
  static const String itemsBoxName = 'items';
  static const String boxesBoxName = 'boxes';
  static const String expensesBoxName = 'expenses';
  static const String taxesBoxName = 'taxes';
  
  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(ItemAdapter());
    Hive.registerAdapter(PyeBoxAdapter());
    Hive.registerAdapter(ItemStatusAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(TaxAdapter());
    
    // Check if we need to migrate old data format
    await _migrateOldDataFormat();
    
    // Open boxes
    await Hive.openBox<Item>(itemsBoxName);
    await Hive.openBox<PyeBox>(boxesBoxName);
    await Hive.openBox<Expense>(expensesBoxName);
    await Hive.openBox<Tax>(taxesBoxName);
    
    // Initialize default taxes if empty
    await _initializeDefaultTaxes();
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
      // If we get a type error, delete the old incompatible boxes to migrate to new enum format
      // Delete the box files to clear old data
      await Hive.deleteBoxFromDisk(itemsBoxName);
      await Hive.deleteBoxFromDisk(boxesBoxName);
    }
  }
  
  // Get boxes
  static Box<Item> get itemsBox => Hive.box<Item>(itemsBoxName);
  static Box<PyeBox> get boxesBox => Hive.box<PyeBox>(boxesBoxName);
  static Box<Expense> get expensesBox => Hive.box<Expense>(expensesBoxName);
  static Box<Tax> get taxesBox => Hive.box<Tax>(taxesBoxName);
  
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
  
  /// Update an item within a box by finding the box and item
  static Future<void> updateItemInBox(String boxName, String itemName, Item updatedItem) async {
    final boxes = getAllBoxes();
    
    for (int i = 0; i < boxes.length; i++) {
      final box = boxes[i];
      if (box.name == boxName) {
        // Find the item in this box
        final itemIndex = box.items.indexWhere((item) => item.name == itemName);
        if (itemIndex != -1) {
          // Update the item in the box
          box.items[itemIndex] = updatedItem;
          // Save the updated box
          await updateBox(i, box);
          return;
        }
      }
    }
  }
  
  /// Update an item from the combined list (handles both standalone and box items)
  static Future<void> updateItemFromCombinedList(Item itemToUpdate) async {
    // Check if item is in a box
    if (itemToUpdate.boxName != null && itemToUpdate.boxName!.isNotEmpty) {
      // Update item in box
      await updateItemInBox(itemToUpdate.boxName!, itemToUpdate.name, itemToUpdate);
    } else {
      // Find the item in standalone items
      final standaloneItems = getAllItems();
      final index = standaloneItems.indexWhere((item) => 
        item.name == itemToUpdate.name && 
        item.boughtDate == itemToUpdate.boughtDate
      );
      
      if (index != -1) {
        await updateItem(index, itemToUpdate);
      }
    }
  }
  
  // ===== EXPENSES OPERATIONS =====
  
  /// Get all expenses as a list
  static List<Expense> getAllExpenses() {
    if (!Hive.isBoxOpen(expensesBoxName)) {
      return [];
    }
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
      bool matchesSoldDate = item.isSold && item.soldDate != null && 
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
      return filteredItems.where((item) => item.isSold && item.soldDate != null).toList();
    }
    
    if (selectedDate == null) {
      return filteredItems.where((item) => item.isSold && item.soldDate != null).toList();
    }
    
    return filteredItems.where((item) {
      return item.isSold && item.soldDate != null && 
             _dateMatches(item.soldDate!, selectedDate, filterType);
    }).toList();
  }
  
  /// Get count of sold items
  static int getSoldItemsCount() {
    return itemsBox.values.where((item) => item.isSold).length;
  }
  
  // ===== TAXES OPERATIONS =====
  
  /// Initialize default UK taxes if the box is empty
  static Future<void> _initializeDefaultTaxes() async {
    if (taxesBox.isEmpty) {
      await resetToDefaultTaxes();
    }
  }
  
  /// Get all taxes as a list
  static List<Tax> getAllTaxes() {
    return taxesBox.values.toList();
  }
  
  /// Add a new tax
  static Future<void> addTax(Tax tax) async {
    await taxesBox.add(tax);
  }
  
  /// Update an existing tax
  static Future<void> updateTax(int index, Tax tax) async {
    await taxesBox.putAt(index, tax);
  }
  
  /// Delete a tax by index
  static Future<void> deleteTax(int index) async {
    await taxesBox.deleteAt(index);
  }
  
  /// Clear all taxes
  static Future<void> clearAllTaxes() async {
    await taxesBox.clear();
  }
  
  /// Reset taxes to UK defaults
  static Future<void> resetToDefaultTaxes() async {
    await taxesBox.clear();
    
    final defaultTaxes = [
      Tax('Basic Tax (£12,570 < income <= £52,750)', 0.20, 12570, 52750),
      Tax('Higher Tax (income > £52,750)', 0.40, 52750, null),
      Tax('National Insurance (£12,570 < income <= £50,270)', 0.06, 12570, 50270),
      Tax('National Insurance 2 (income > £50,270)', 0.02, 50270, null),
      Tax('Student Loan (income > £28,470)', 0.09, 28470, null),
    ];
    
    for (final tax in defaultTaxes) {
      await taxesBox.add(tax);
    }
  }
  
  /// Export all data to JSON file
  static Future<bool> exportToJson() async {
    try {
      // Get all data
      final allItems = getAllItemsIncludingBoxes();
      final boxes = getAllBoxes();
      final expenses = getAllExpenses();
      final taxes = getAllTaxes();
      
      // Filter to get only standalone items (not items inside boxes)
      final standaloneItems = allItems.where((item) => 
        item.boxName == null || item.boxName!.isEmpty
      ).toList();
      
      // Convert to JSON-serializable format
      final data = {
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
        'items': standaloneItems.map((item) => {
          'name': item.name,
          'boughtFrom': item.boughtFrom,
          'boughtDate': item.boughtDate.toIso8601String(),
          'status': item.status.toString(),
          'sellingPrice': item.sellingPrice,
          'retailPrice': item.retailPrice,
          'costPrice': item.costPrice,
          'soldPrice': item.soldPrice,
          'soldDate': item.soldDate?.toIso8601String(),
          'daysToSell': item.daysToSell,
          'boxName': item.boxName,
        }).toList(),
        'boxes': boxes.map((box) => {
          'id': box.id,
          'date': box.date.toIso8601String(),
          'name': box.name,
          'totalPaidPrice': box.totalPaidPrice,
          'items': box.items.map((item) => {
            'name': item.name,
            'boughtFrom': item.boughtFrom,
            'boughtDate': item.boughtDate.toIso8601String(),
            'status': item.status.toString(),
            'sellingPrice': item.sellingPrice,
            'retailPrice': item.retailPrice,
            'costPrice': item.costPrice,
            'soldPrice': item.soldPrice,
            'soldDate': item.soldDate?.toIso8601String(),
            'daysToSell': item.daysToSell,
          }).toList(),
        }).toList(),
        'expenses': expenses.map((expense) => {
          'name': expense.name,
          'amount': expense.amount,
          'date': expense.date.toIso8601String(),
        }).toList(),
        'taxes': taxes.map((tax) => {
          'name': tax.name,
          'rate': tax.rate,
          'minimumIncomeRequired': tax.minimumIncomeRequired,
          'maxTaxedincome': tax.maxTaxedincome,
        }).toList(),
      };
      
      // Convert to JSON string
      final jsonString = JsonEncoder.withIndent('  ').convert(data);
      
      // Let user choose save location
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup',
        fileName: 'sellers_bookkeeper_backup_${DateTime.now().toString().replaceAll(':', '-').split('.')[0]}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null) {
        final file = File(result);
        await file.writeAsString(jsonString);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Import all data from JSON file
  static Future<bool> importFromJson() async {
    try {
      // Let user pick a JSON file
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Backup File',
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        return false; // User cancelled
      }
      
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate basic structure
      if (!data.containsKey('items') || !data.containsKey('boxes') || 
          !data.containsKey('expenses') || !data.containsKey('taxes')) {
        throw Exception('Invalid backup file format');
      }
      
      // Clear existing data
      await clearAllItems();
      await clearAllBoxes();
      await clearAllExpenses();
      await clearAllTaxes();
      
      // Import boxes first
      final boxesData = data['boxes'] as List<dynamic>;
      int boxIdCounter = 0;
      for (var boxData in boxesData) {
        final boxItems = (boxData['items'] as List<dynamic>).map((itemData) {
          return Item(
            name: itemData['name'] as String,
            boughtFrom: itemData['boughtFrom'] as String? ?? '',
            boughtDate: DateTime.parse(itemData['boughtDate'] as String),
            status: _parseItemStatus(itemData['status'] as String),
            sellingPrice: (itemData['sellingPrice'] as num).toDouble(),
            retailPrice: (itemData['retailPrice'] as num).toDouble(),
            costPrice: (itemData['costPrice'] as num).toDouble(),
            soldPrice: (itemData['soldPrice'] as num).toDouble(),
            soldDate: itemData['soldDate'] != null 
                ? DateTime.parse(itemData['soldDate'] as String) 
                : null,
          )..daysToSell = itemData['daysToSell'] as int?;
        }).toList();
        
        // Handle old JSON files that don't have id/date fields
        final boxId = boxData['id'] as int? ?? boxIdCounter++;
        final boxDate = boxData['date'] != null 
            ? DateTime.parse(boxData['date'] as String)
            : DateTime.now();
        
        final box = PyeBox(
          id: boxId,
          date: boxDate,
          name: boxData['name'] as String?,
          totalPaidPrice: (boxData['totalPaidPrice'] as num).toDouble(),
          items: boxItems,
        );
        
        await addBox(box);
      }
      
      // Import standalone items
      final itemsData = data['items'] as List<dynamic>;
      for (var itemData in itemsData) {
        final item = Item(
          name: itemData['name'] as String,
          boughtFrom: itemData['boughtFrom'] as String? ?? '',
          boughtDate: DateTime.parse(itemData['boughtDate'] as String),
          status: _parseItemStatus(itemData['status'] as String),
          sellingPrice: (itemData['sellingPrice'] as num).toDouble(),
          retailPrice: (itemData['retailPrice'] as num).toDouble(),
          costPrice: (itemData['costPrice'] as num).toDouble(),
          soldPrice: (itemData['soldPrice'] as num).toDouble(),
          soldDate: itemData['soldDate'] != null 
              ? DateTime.parse(itemData['soldDate'] as String) 
              : null,
          boxName: itemData['boxName'] as String?,
        )..daysToSell = itemData['daysToSell'] as int?;
        
        await addItem(item);
      }
      
      // Import expenses
      final expensesData = data['expenses'] as List<dynamic>;
      for (var expenseData in expensesData) {
        final expense = Expense(
          name: expenseData['name'] as String,
          amount: (expenseData['amount'] as num).toDouble(),
          date: DateTime.parse(expenseData['date'] as String),
        );
        
        await addExpense(expense);
      }
      
      // Import taxes
      final taxesData = data['taxes'] as List<dynamic>;
      for (var taxData in taxesData) {
        final tax = Tax(
          taxData['name'] as String,
          (taxData['rate'] as num).toDouble(),
          (taxData['minimumIncomeRequired'] as num).toDouble(),
          taxData['maxTaxedincome'] != null 
              ? (taxData['maxTaxedincome'] as num).toDouble() 
              : null,
        );
        
        await taxesBox.add(tax);
      }
      
      return true;
    } catch (e) {
      // If import fails, try to restore default state
      await clearAllItems();
      await clearAllBoxes();
      await clearAllExpenses();
      await resetToDefaultTaxes();
      rethrow;
    }
  }
  
  /// Helper to parse ItemStatus from string
  static ItemStatus _parseItemStatus(String status) {
    if (status.contains('sold')) return ItemStatus.sold;
    if (status.contains('lost')) return ItemStatus.lost;
    return ItemStatus.listed;
  }
  
  /// Close all boxes (call when app closes)
  static Future<void> closeAll() async {
    await itemsBox.close();
    await boxesBox.close();
    await expensesBox.close();
    await taxesBox.close();
  }
}
