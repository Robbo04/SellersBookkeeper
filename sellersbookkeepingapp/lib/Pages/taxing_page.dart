import 'package:flutter/material.dart';
import '../Classes/item.dart';
import '../Services/taxes_service.dart';
import '../Services/generate_tax_service.dart';
import '../Services/storage_service.dart';

class TaxingPage extends StatefulWidget {
  @override
  State<TaxingPage> createState() => _TaxingPageState();
}

class _TaxingPageState extends State<TaxingPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  TaxesService? _taxesService;
  bool _calculated = false;
  List<Item> _filteredItems = [];
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
    final allItems = StorageService.getAllItems();
    
    // Filter items sold within the date range
    final filtered = allItems.where((item) {
      if (item.soldDate == null) return false;
      
      final soldDate = DateTime(
        item.soldDate!.year,
        item.soldDate!.month,
        item.soldDate!.day,
      );
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
      
      return (soldDate.isAfter(startDate) || soldDate.isAtSameMomentAs(startDate)) &&
             (soldDate.isBefore(endDate) || soldDate.isAtSameMomentAs(endDate));
    }).toList();
    
    // Calculate total profit (income for tax purposes)
    final income = filtered.fold(0.0, (sum, item) => sum + item.profit);
    
    setState(() {
      _filteredItems = filtered;
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
                        '${_filteredItems.length}',
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
                await generateTaxReport(_taxesService!);
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
