import 'package:flutter/material.dart';
import '../Classes/Widgets/add_item_w.dart';
import '../Classes/Widgets/add_box_w.dart';
import '../Classes/Widgets/add_expense_w.dart';
import '../Classes/Widgets/item_card.dart';
import '../Classes/Widgets/expense_card.dart';
import '../Classes/item.dart';
import '../Classes/expense.dart';
import '../Services/storage_service.dart';

class ManageItemsPage extends StatefulWidget {
  @override
  _ManageItemsPageState createState() => _ManageItemsPageState();
}

class _ManageItemsPageState extends State<ManageItemsPage> with SingleTickerProviderStateMixin {
  List<Item> items = [];
  List<Expense> expenses = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _loadItems();
  }
  
  void _loadItems() {
    setState(() {
      items = StorageService.getAllItemsIncludingBoxes();
      expenses = StorageService.getAllExpenses();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshItems() async {
    await Future.delayed(Duration(milliseconds: 500));
    _loadItems();
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Clear All Data'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete all items and boxes? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _clearAllData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearAllData() async {
    try {
      await StorageService.clearAllItems();
      await StorageService.clearAllBoxes();
      await StorageService.clearAllExpenses();
      _loadItems();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('All data cleared successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to clear data: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.inventory_2, size: 24),
            SizedBox(width: 8),
            Text('Manage Items'),
            if (items.isNotEmpty || expenses.isNotEmpty) ...[
              SizedBox(width: 8),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (items.isNotEmpty)
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    if (items.isNotEmpty && expenses.isNotEmpty)
                      SizedBox(width: 4),
                    if (expenses.isNotEmpty)
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${expenses.length} ${expenses.length == 1 ? 'expense' : 'expenses'}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            tooltip: 'Developer Tools',
            onSelected: (value) {
              if (value == 'clear_all') {
                _showClearAllConfirmation();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Clear All Data', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      
      
      body: items.isEmpty && expenses.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _refreshItems,
              child: CustomScrollView(
                slivers: [
                  // Expenses Section
                  if (expenses.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Icon(Icons.receipt_long, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Expenses',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${expenses.length}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return ExpenseCard(
                              expense: expenses[index], 
                              index: index,
                              onExpenseUpdated: _loadItems,
                            );
                          },
                          childCount: expenses.length,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                  
                  // Items Section
                  if (items.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Row(
                          children: [
                            Icon(Icons.inventory_2, color: Theme.of(context).colorScheme.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Items',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${items.length}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(left: 12, right: 12, bottom: 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return ItemCard(item: items[index], index: index);
                          },
                          childCount: items.length,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
      
      
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: "AddExpense",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: buildAddExpenseWidget(
                      onExpenseAdded: () {
                        _loadItems();
                      },
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.add),
            label: Text('Expense'),
            backgroundColor: Colors.orange,
          ),
          SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: "AddItem",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: buildAddItemWidget(
                      onItemAdded: (newItem) async {
                        // Save to storage
                        await StorageService.addItem(newItem);
                        // Reload items from storage
                        _loadItems();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Item added successfully!'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.add),
            label: Text('Item'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 12),
          
          
          FloatingActionButton.extended(
            heroTag: "addBox",
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: buildAddBoxWidget(
                      onBoxAdded: () {
                        _loadItems();
                      },
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.add),
            label: Text('Box'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            'No items or expenses yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add items, expenses, or boxes to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}