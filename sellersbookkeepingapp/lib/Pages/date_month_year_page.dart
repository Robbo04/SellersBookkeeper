import 'package:flutter/material.dart';
import '../Services/storage_service.dart';
import '../Enums/date_filter_type.dart';
import '../Classes/item.dart';
import '../Classes/Widgets/item_card.dart';

class DateMonthYearPage extends StatefulWidget {
  @override
  _DateMonthYearPageState createState() => _DateMonthYearPageState();
}

class _DateMonthYearPageState extends State<DateMonthYearPage> {
  DateFilterType _selectedFilter = DateFilterType.all;
  DateTime _selectedDate = DateTime.now();
  
  List<Item> _boughtItems = [];
  List<Item> _soldItems = [];
  
  bool _boughtExpanded = true;
  bool _soldExpanded = true;
  
  @override
  void initState() {
    super.initState();
    _loadFilteredItems();
  }
  
  void _loadFilteredItems() {
    setState(() {
      _boughtItems = StorageService.getItemsBought(
        _selectedFilter,
        _selectedFilter == DateFilterType.all ? null : _selectedDate,
      );
      _soldItems = StorageService.getItemsSold(
        _selectedFilter,
        _selectedFilter == DateFilterType.all ? null : _selectedDate,
      );
    });
  }
  
  String _getDateRangeText() {
    if (_selectedFilter == DateFilterType.all) {
      return 'All Time';
    }
    
    const monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    switch (_selectedFilter) {
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
  
  double _getTotalProfit() {
    return _soldItems.fold(0.0, (sum, item) => sum + item.profit);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Date Filter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Filter Type Selector
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter By',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 12),
                _buildFilterSelector(),
                SizedBox(height: 16),
                if (_selectedFilter != DateFilterType.all) _buildDatePicker(),
              ],
            ),
          ),
          
          // Summary Statistics
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDateRangeText(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                _buildSummaryCards(),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Items List
          Expanded(
            child: _buildItemsList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterSelector() {
    return Row(
      children: [
        _buildFilterChip('Day', DateFilterType.day),
        SizedBox(width: 8),
        _buildFilterChip('Month', DateFilterType.month),
        SizedBox(width: 8),
        _buildFilterChip('Year', DateFilterType.year),
        SizedBox(width: 8),
        _buildFilterChip('All', DateFilterType.all),
      ],
    );
  }
  
  Widget _buildFilterChip(String label, DateFilterType type) {
    final isSelected = _selectedFilter == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = type;
            _loadFilteredItems();
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        if (_selectedFilter == DateFilterType.day) {
          final now = DateTime.now();
          final initialDate = _selectedDate.isAfter(now) ? now : _selectedDate;
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(2000),
            lastDate: now,
          );
          if (pickedDate != null) {
            setState(() {
              _selectedDate = pickedDate;
              _loadFilteredItems();
            });
          }
        } else if (_selectedFilter == DateFilterType.month) {
          await _showMonthPicker();
        } else if (_selectedFilter == DateFilterType.year) {
          await _showYearPicker();
        }
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 12),
            Text(
              _getDateRangeText(),
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
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
        _loadFilteredItems();
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
        _loadFilteredItems();
      });
    }
  }
  
  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Bought',
            _boughtItems.length.toString(),
            Icons.shopping_cart,
            Colors.blue,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Sold',
            _soldItems.length.toString(),
            Icons.attach_money,
            Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Profit',
            '\$${_getTotalProfit().toStringAsFixed(2)}',
            Icons.trending_up,
            _getTotalProfit() >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildItemsList() {
    if (_boughtItems.isEmpty && _soldItems.isEmpty) {
      return Center(
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
              'No items found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try selecting a different date range',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Bought Items Section
        if (_boughtItems.isNotEmpty) _buildCollapsibleSection(
          'Bought Items',
          _boughtItems,
          _boughtExpanded,
          () {
            setState(() {
              _boughtExpanded = !_boughtExpanded;
            });
          },
          Colors.blue,
        ),
        
        SizedBox(height: 16),
        
        // Sold Items Section
        if (_soldItems.isNotEmpty) _buildCollapsibleSection(
          'Sold Items',
          _soldItems,
          _soldExpanded,
          () {
            setState(() {
              _soldExpanded = !_soldExpanded;
            });
          },
          Colors.green,
        ),
        
        SizedBox(height: 100),
      ],
    );
  }
  
  Widget _buildCollapsibleSection(
    String title,
    List<Item> items,
    bool isExpanded,
    VoidCallback onToggle,
    Color color,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  color: color,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (isExpanded) ...[
          SizedBox(height: 8),
          ...items.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: ItemCard(item: entry.value, index: entry.key),
            );
          }).toList(),
        ],
      ],
    );
  }
}
