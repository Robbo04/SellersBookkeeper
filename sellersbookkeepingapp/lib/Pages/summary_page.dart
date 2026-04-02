import 'package:flutter/material.dart';
import '../Services/storage_service.dart';
import '../Classes/item.dart';

class SummaryPage extends StatefulWidget {
  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  List<Item> allItems = [];
  
  @override
  void initState() {
    super.initState();
    _loadItems();
  }
  
  void _loadItems() {
    setState(() {
      allItems = StorageService.getAllItems();
    });
  }
  
  // Calculate total sold items
  int get totalSoldItems => allItems.where((item) => item.isSold).length;
  
  // Calculate total revenue
  double get totalRevenue => allItems.fold(0.0, (sum, item) => sum + item.soldPrice);
  
  // Calculate total spent
  double get totalSpent => allItems.fold(0.0, (sum, item) => sum + item.costPrice);
  
  // Calculate total profit
  double get totalProfit => allItems.where((item) => item.isSold).fold(0.0, (sum, item) => sum + item.profit);
  
  // Calculate remaining listed items
  int get remainingListedItems => allItems.where((item) => !item.isSold && !item.isLost).length;
  
  // Calculate items lost
  int get itemsLost => allItems.where((item) => item.isLost).length;
  
  // Calculate average days to sell
  double get averageDaysToSell {
    final soldItems = allItems.where((item) => item.isSold && item.daysToSell != null).toList();
    if (soldItems.isEmpty) return 0.0;
    final totalDays = soldItems.fold(0, (sum, item) => sum + (item.daysToSell ?? 0));
    return totalDays / soldItems.length;
  }
  
  // Get sold items by month
  Map<String, int> get soldItemsByMonth {
    Map<String, int> monthlyData = {};
    const monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    for (var item in allItems.where((item) => item.soldDate != null)) {
      final key = '${monthNames[item.soldDate!.month]} ${item.soldDate!.year}';
      monthlyData[key] = (monthlyData[key] ?? 0) + 1;
    }
    
    return monthlyData;
  }
  
  // Get profit by month
  Map<String, double> get profitByMonth {
    Map<String, double> monthlyProfit = {};
    const monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    for (var item in allItems.where((item) => item.soldDate != null)) {
      final key = '${monthNames[item.soldDate!.month]} ${item.soldDate!.year}';
      monthlyProfit[key] = (monthlyProfit[key] ?? 0.0) + item.profit;
    }
    
    return monthlyProfit;
  }
  
  // Calculate current streak (consecutive days with sales)
  int get currentStreak {
    if (allItems.isEmpty) return 0;
    
    final soldItems = allItems.where((item) => item.soldDate != null).toList();
    if (soldItems.isEmpty) return 0;
    
    soldItems.sort((a, b) => b.soldDate!.compareTo(a.soldDate!));
    
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    int streak = 0;
    Set<DateTime> saleDays = {};
    
    for (var item in soldItems) {
      final saleDate = DateTime(item.soldDate!.year, item.soldDate!.month, item.soldDate!.day);
      saleDays.add(saleDate);
    }
    
    var checkDate = todayDate;
    while (saleDays.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(Duration(days: 1));
    }
    
    return streak;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.addchart, size: 24),
            SizedBox(width: 8),
            Text('Summary'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadItems,
          ),
        ],
      ),
      body: allItems.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(Duration(milliseconds: 500));
                _loadItems();
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Stats
                    _buildSectionTitle('Overview'),
                    SizedBox(height: 12),
                    _buildOverviewCards(),
                    
                    SizedBox(height: 24),
                    
                    // Financial Summary
                    _buildSectionTitle('Financial Summary'),
                    SizedBox(height: 12),
                    _buildFinancialCards(),
                    
                    SizedBox(height: 24),
                    
                    // Performance Metrics
                    _buildSectionTitle('Performance'),
                    SizedBox(height: 12),
                    _buildPerformanceCards(),
                    
                    SizedBox(height: 24),
                    
                    // Monthly Breakdown
                    _buildSectionTitle('Monthly Breakdown'),
                    SizedBox(height: 12),
                    _buildMonthlyBreakdown(),
                    
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.summarize_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            'No data yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some items to see your summary',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }
  
  Widget _buildOverviewCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Items',
                allItems.length.toString(),
                Icons.inventory_2,
                Colors.blue,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Sold',
                totalSoldItems.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Listed',
                remainingListedItems.toString(),
                Icons.storefront,
                Colors.orange,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Lost',
                itemsLost.toString(),
                Icons.error_outline,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildFinancialCards() {
    final profitColor = totalProfit >= 0 ? Colors.green : Colors.red;
    final profitMargin = totalSpent > 0 ? (totalProfit / totalSpent * 100) : 0.0;
    
    return Column(
      children: [
        _buildLargeStatCard(
          'Total Profit',
          '\$${totalProfit.toStringAsFixed(2)}',
          Icons.trending_up,
          profitColor,
          subtitle: '${profitMargin.toStringAsFixed(1)}% margin',
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Revenue',
                '\$${totalRevenue.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.teal,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Spent',
                '\$${totalSpent.toStringAsFixed(2)}',
                Icons.shopping_cart,
                Colors.indigo,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPerformanceCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Avg Days to Sell',
                averageDaysToSell.toStringAsFixed(1),
                Icons.timelapse,
                Colors.purple,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Sales Streak',
                '$currentStreak days',
                Icons.local_fire_department,
                currentStreak > 0 ? Colors.deepOrange : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(76), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLargeStatCard(String label, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(76), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMonthlyBreakdown() {
    final salesByMonth = soldItemsByMonth;
    final profitData = profitByMonth;
    
    if (salesByMonth.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No sales yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }
    
    // Sort by most recent
    final sortedMonths = salesByMonth.keys.toList()
      ..sort((a, b) {
        // Simple reverse sort - most recent first
        return b.compareTo(a);
      });
    
    final maxSales = salesByMonth.values.reduce((a, b) => a > b ? a : b);
    final maxProfit = profitData.values.map((v) => v.abs()).reduce((a, b) => a > b ? a : b);
    
    return Column(
      children: sortedMonths.take(6).map((month) {
        final sales = salesByMonth[month] ?? 0;
        final profit = profitData[month] ?? 0.0;
        final salesPercent = maxSales > 0 ? sales / maxSales : 0.0;
        final profitPercent = maxProfit > 0 ? profit.abs() / maxProfit : 0.0;
        final profitColor = profit >= 0 ? Colors.green : Colors.red;
        
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(25),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    month,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$sales sold',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '\$${profit.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: profitColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              
              // Sales bar
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      'Sales',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: salesPercent,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              
              // Profit bar
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      'Profit',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: profitPercent,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: profitColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}