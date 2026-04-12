import 'package:flutter/material.dart';
import '../Classes/Widgets/add_item_w.dart';
import '../Classes/Widgets/add_box_w.dart';
import '../Classes/Widgets/add_expense_w.dart';
import '../Classes/Widgets/item_card.dart';
import '../Classes/Widgets/expense_card.dart';
import '../Classes/item.dart';
import '../Classes/expense.dart';
import '../Services/storage_service.dart';
import '../Enums/date_filter_type.dart';

class ManageItemsPage extends StatefulWidget {
  @override
  _ManageItemsPageState createState() => _ManageItemsPageState();
}

class _ManageItemsPageState extends State<ManageItemsPage> with SingleTickerProviderStateMixin {
  List<Item> items = [];
  List<Expense> expenses = [];
  late AnimationController _animationController;
  
  // Filter state
  DateFilterType _dateFilter = DateFilterType.all;
  DateTime _selectedDate = DateTime.now();

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
      final allItems = StorageService.getAllItemsIncludingBoxes();
      final allExpenses = StorageService.getAllExpenses();
      
      // Apply filters
      items = _applyFilters(allItems);
      expenses = _applyExpenseFilters(allExpenses);
    });
  }
  
  List<Item> _applyFilters(List<Item> allItems) {
    var filtered = allItems;
    
    // Date filter
    if (_dateFilter != DateFilterType.all) {
      filtered = filtered.where((item) {
        bool matchesBoughtDate = _dateMatches(item.boughtDate, _selectedDate, _dateFilter);
        bool matchesSoldDate = item.isSold && item.soldDate != null && 
                               _dateMatches(item.soldDate!, _selectedDate, _dateFilter);
        return matchesBoughtDate || matchesSoldDate;
      }).toList();
    }
    
    return filtered;
  }
  
  List<Expense> _applyExpenseFilters(List<Expense> allExpenses) {
    if (_dateFilter == DateFilterType.all) {
      return allExpenses;
    }
    
    return allExpenses.where((expense) {
      return _dateMatches(expense.date, _selectedDate, _dateFilter);
    }).toList();
  }
  
  bool _dateMatches(DateTime date, DateTime selected, DateFilterType filterType) {
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
      
      
      body: items.isEmpty && expenses.isEmpty && _dateFilter == DateFilterType.all
          ? _buildEmptyState()
          : Column(
              children: [
                // Filter Section
                _buildFilterSection(),
                
                // Items List
                Expanded(
                  child: RefreshIndicator(
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
                        
                        // Empty state for filtered results
                        if (items.isEmpty && expenses.isEmpty) ...[
                          SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 80,
                                    color: Colors.grey[300],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No items match filters',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Try adjusting your filters',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
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

  Widget _buildFilterSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.grey[700]),
                SizedBox(width: 8),
                Text(
                  'Date Filter:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                _buildDateFilterChip('All', DateFilterType.all),
                SizedBox(width: 6),
                _buildDateFilterChip('Day', DateFilterType.day),
                SizedBox(width: 6),
                _buildDateFilterChip('Month', DateFilterType.month),
                SizedBox(width: 6),
                _buildDateFilterChip('Year', DateFilterType.year),
              ],
            ),
            if (_dateFilter != DateFilterType.all) ...[
              SizedBox(height: 12),
              _buildDatePicker(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterChip(String label, DateFilterType type) {
    final isSelected = _dateFilter == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _dateFilter = type;
            _loadItems();
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[400]!,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    String dateText = _getDateRangeText();
    
    return GestureDetector(
      onTap: () async {
        if (_dateFilter == DateFilterType.day) {
          final now = DateTime.now();
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: _selectedDate.isAfter(now) ? now : _selectedDate,
            firstDate: DateTime(2000),
            lastDate: now,
          );
          if (pickedDate != null) {
            setState(() {
              _selectedDate = pickedDate;
              _loadItems();
            });
          }
        } else if (_dateFilter == DateFilterType.month) {
          await _showMonthPicker();
        } else if (_dateFilter == DateFilterType.year) {
          await _showYearPicker();
        }
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 12),
            Text(
              dateText,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Spacer(),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  String _getDateRangeText() {
    const monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    switch (_dateFilter) {
      case DateFilterType.day:
        return '${monthNames[_selectedDate.month]} ${_selectedDate.day}, ${_selectedDate.year}';
      case DateFilterType.month:
        return '${monthNames[_selectedDate.month]} ${_selectedDate.year}';
      case DateFilterType.year:
        return '${_selectedDate.year}';
      default:
        return 'All Time';
    }
  }

  Future<void> _showMonthPicker() async {
    final now = DateTime.now();
    int selectedYear = _selectedDate.year;
    int selectedMonth = _selectedDate.month;
    
    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            const monthNames = [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];
            
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed: selectedYear > 2000 ? () {
                      setDialogState(() {
                        selectedYear--;
                      });
                    } : null,
                  ),
                  Text('$selectedYear'),
                  IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed: selectedYear < now.year ? () {
                      setDialogState(() {
                        selectedYear++;
                      });
                    } : null,
                  ),
                ],
              ),
              content: Container(
                width: 300,
                height: 280,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final monthIndex = index + 1;
                    final isCurrentMonth = monthIndex == selectedMonth && selectedYear == _selectedDate.year;
                    final isFutureMonth = selectedYear == now.year && monthIndex > now.month;
                    
                    return ElevatedButton(
                      onPressed: isFutureMonth ? null : () {
                        Navigator.pop(context, DateTime(selectedYear, monthIndex, 1));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCurrentMonth 
                            ? Theme.of(context).colorScheme.primary 
                            : Colors.grey[200],
                        foregroundColor: isCurrentMonth ? Colors.white : Colors.black87,
                        disabledBackgroundColor: Colors.grey[100],
                        disabledForegroundColor: Colors.grey[400],
                      ),
                      child: Text(monthNames[index]),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
    
    if (result != null) {
      setState(() {
        _selectedDate = result;
        _loadItems();
      });
    }
  }

  Future<void> _showYearPicker() async {
    final pickedYear = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Year'),
          content: Container(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              selectedDate: _selectedDate,
              onChanged: (DateTime dateTime) {
                Navigator.pop(context, dateTime.year);
              },
            ),
          ),
        );
      },
    );
    
    if (pickedYear != null) {
      setState(() {
        _selectedDate = DateTime(pickedYear, 1, 1);
        _loadItems();
      });
    }
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