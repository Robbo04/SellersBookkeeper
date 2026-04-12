import 'package:flutter/material.dart';
import '../Classes/item.dart';
import '../Classes/expense.dart';
import '../Classes/pye_box.dart';
import '../Services/taxes_service.dart';
import '../Services/generate_tax_service.dart';
import '../Services/storage_service.dart';
import '../Classes/Widgets/tax_management_dialog.dart';

class TaxingPage extends StatefulWidget {
  @override
  State<TaxingPage> createState() => _TaxingPageState();
}

class _TaxingPageState extends State<TaxingPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  TaxesService? _taxesService;
  bool _calculated = false;
  List<Item> _itemsSold = [];
  List<Item> _itemsBought = [];
  List<PyeBox> _boxesBought = [];
  List<Expense> _filteredExpenses = [];
  double _totalRevenue = 0.0;
  double _totalCosts = 0.0;
  double _totalExpenses = 0.0;
  double _totalIncome = 0.0;

  void _calculateTax() {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both start and end dates'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('End date must be after start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get all items
    final allItems = StorageService.getAllItemsIncludingBoxes();
    
    final startDate = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
    );
    final endDate = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
    );
    
    // Filter items sold within the date range (for revenue)
    final itemsSold = allItems.where((item) {
      // Only include items that are currently marked as sold
      if (!item.isSold || item.soldDate == null) return false;
      
      final soldDate = DateTime(
        item.soldDate!.year,
        item.soldDate!.month,
        item.soldDate!.day,
      );
      
      return (soldDate.isAfter(startDate) || soldDate.isAtSameMomentAs(startDate)) &&
             (soldDate.isBefore(endDate) || soldDate.isAtSameMomentAs(endDate));
    }).toList();
    
    // Filter items bought within the date range (for costs)
    final itemsBought = allItems.where((item) {
      final boughtDate = DateTime(
        item.boughtDate.year,
        item.boughtDate.month,
        item.boughtDate.day,
      );
      
      return (boughtDate.isAfter(startDate) || boughtDate.isAtSameMomentAs(startDate)) &&
             (boughtDate.isBefore(endDate) || boughtDate.isAtSameMomentAs(endDate));
    }).toList();
    
    // Calculate total revenue (money made from sales)
    final totalRevenue = itemsSold.fold(0.0, (sum, item) => sum + item.soldPrice);
    
    // Calculate total costs (money spent on purchases)
    // For standalone items, use their cost price
    final standaloneItemsCost = itemsBought
        .where((item) => item.boxName == null || item.boxName!.isEmpty)
        .fold(0.0, (sum, item) => sum + item.costPrice);
    
    // For boxes, get all boxes bought in the date range and add their totalPaidPrice
    final allBoxes = StorageService.getAllBoxes();
    final boxesBought = allBoxes.where((box) {
      final boxDate = DateTime(
        box.date.year,
        box.date.month,
        box.date.day,
      );
      
      return (boxDate.isAfter(startDate) || boxDate.isAtSameMomentAs(startDate)) &&
             (boxDate.isBefore(endDate) || boxDate.isAtSameMomentAs(endDate));
    }).toList();
    
    final boxCosts = boxesBought.fold(0.0, (sum, box) => sum + box.totalPaidPrice);
    
    final totalCosts = standaloneItemsCost + boxCosts;
    
    // Add other expenses within the date range
    final expenses = StorageService.getAllExpenses();
    final filteredExpenses = expenses.where((expense) {
      final expenseDate = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      
      return (expenseDate.isAfter(startDate) || expenseDate.isAtSameMomentAs(startDate)) &&
             (expenseDate.isBefore(endDate) || expenseDate.isAtSameMomentAs(endDate));
    }).toList();
    
    final totalExpenses = filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    
    // Taxable income = revenue - (costs + expenses)
    final income = totalRevenue - totalCosts - totalExpenses;
    
    setState(() {
      _itemsSold = itemsSold;
      _itemsBought = itemsBought;
      _boxesBought = boxesBought;
      _filteredExpenses = filteredExpenses;
      _totalRevenue = totalRevenue;
      _totalCosts = totalCosts;
      _totalExpenses = totalExpenses;
      _totalIncome = income;
      _taxesService = TaxesService(income);
      _calculated = true;
    });
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime(now.year, 1, 1),
      firstDate: DateTime(2000),
      lastDate: now,
    );
    
    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    
    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    const monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${monthNames[date.month]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.attach_money_rounded, size: 24),
            SizedBox(width: 8),
            Text('Taxing'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Manage Taxes',
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => TaxManagementDialog(),
              );
              // Recalculate if taxes were changed
              if (_calculated) {
                _calculateTax();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            'Tax Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Select a date range to calculate tax on profits from items sold during that period.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          
          // Date Range Selection
          Text(
            'Date Range',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          SizedBox(height: 12),
          
          // Start Date
          GestureDetector(
            onTap: _selectStartDate,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatDate(_startDate),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _startDate != null ? FontWeight.w500 : FontWeight.normal,
                          color: _startDate != null ? Colors.black87 : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          
          // End Date
          GestureDetector(
            onTap: _selectEndDate,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Icon(Icons.event, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Date',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatDate(_endDate),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _endDate != null ? FontWeight.w500 : FontWeight.normal,
                          color: _endDate != null ? Colors.black87 : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateTax,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Calculate Tax', style: TextStyle(fontSize: 16)),
          ),
          SizedBox(height: 24),
          
          if (_calculated && _taxesService != null) ...[
            // Summary Card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withAlpha(76)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items Sold',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      Text(
                        '${_itemsSold.length}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Profit (Income)',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      Text(
                        '£${_totalIncome.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _totalIncome >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Detailed Breakdown
            Card(
              elevation: 2,
              child: ExpansionTile(
                title: Text(
                  'Detailed Calculation Breakdown',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Items Sold Section
                        Text(
                          'Items Sold (Revenue):',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        if (_itemsSold.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: 16, bottom: 8),
                            child: Text(
                              'No items sold in this period',
                              style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                            ),
                          )
                        else
                          ..._itemsSold.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(left: 16, bottom: 4),
                              child: Text(
                                '${index + 1}) ${item.name}: £${item.soldPrice.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                        Padding(
                          padding: EdgeInsets.only(left: 16, top: 4, bottom: 16),
                          child: Text(
                            'Total Revenue: £${_totalRevenue.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                        
                        Divider(),
                        
                        // Items Bought Section
                        Text(
                          'Items Bought (Costs):',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        if (_itemsBought.isEmpty && _boxesBought.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: 16, bottom: 8),
                            child: Text(
                              'No items bought in this period',
                              style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                            ),
                          )
                        else ...[                          
                          // Standalone items
                          ..._itemsBought
                              .where((item) => item.boxName == null || item.boxName!.isEmpty)
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(left: 16, bottom: 4),
                              child: Text(
                                '${index + 1}) ${item.name}: £${item.costPrice.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          // Boxes
                          ..._boxesBought.asMap().entries.map((entry) {
                            final standaloneCount = _itemsBought.where((item) => item.boxName == null || item.boxName!.isEmpty).length;
                            final index = entry.key;
                            final box = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(left: 16, bottom: 4),
                              child: Text(
                                '${standaloneCount + index + 1}) ${box.name ?? "Box"} (${box.items.length} items): £${box.totalPaidPrice.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.purple[700]),
                              ),
                            );
                          }).toList(),
                        ],
                        Padding(
                          padding: EdgeInsets.only(left: 16, top: 4, bottom: 16),
                          child: Text(
                            'Total Costs: £${_totalCosts.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                        
                        Divider(),
                        
                        // Expenses Section
                        Text(
                          'Other Expenses:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        if (_filteredExpenses.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: 16, bottom: 8),
                            child: Text(
                              'No expenses in this period',
                              style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                            ),
                          )
                        else
                          ..._filteredExpenses.asMap().entries.map((entry) {
                            final index = entry.key;
                            final expense = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(left: 16, bottom: 4),
                              child: Text(
                                '${index + 1}) ${expense.name}: £${expense.amount.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                        Padding(
                          padding: EdgeInsets.only(left: 16, top: 4, bottom: 16),
                          child: Text(
                            'Total Expenses: £${_totalExpenses.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                        
                        Divider(thickness: 2),
                        SizedBox(height: 8),
                        
                        // Final Calculation
                        Text(
                          'Calculation:',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Revenue: £${_totalRevenue.toStringAsFixed(2)}'),
                              Text('- Costs: £${_totalCosts.toStringAsFixed(2)}'),
                              Text('- Expenses: £${_totalExpenses.toStringAsFixed(2)}'),
                              Divider(),
                              Text(
                                'Taxable Income: £${_totalIncome.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _totalIncome >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tax Breakdown',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    ..._taxesService!.getTaxes().map((tax) {
                      final amount = tax.calculateTax(_taxesService!.income);
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tax.name,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '${(tax.rate * 100).toStringAsFixed(0)}% rate',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '£${amount.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    Divider(thickness: 2),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Tax',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '£${_taxesService!.getTaxes().fold(0.0, (sum, tax) => sum + tax.calculateTax(_taxesService!.income)).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await generateTaxReport(
                  _taxesService!,
                  _startDate!,
                  _endDate!,
                  StorageService.getAllItemsIncludingBoxes(),
                );
              },
              icon: Icon(Icons.picture_as_pdf),
              label: Text('Generate PDF Report'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
//april the 6th - april the 5th is a tax year, so if you select april the 6th 2023 to april the 5th 2024, it should calculate tax for that year