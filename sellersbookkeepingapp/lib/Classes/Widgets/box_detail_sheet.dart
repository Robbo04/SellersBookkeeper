import 'package:flutter/material.dart';
import '../pye_box.dart';
import 'item_detail_sheet.dart';
import '../../Services/storage_service.dart';

class BoxDetailSheet extends StatefulWidget {
  final PyeBox box;
  final VoidCallback onBoxUpdated;

  const BoxDetailSheet({
    Key? key,
    required this.box,
    required this.onBoxUpdated,
  }) : super(key: key);

  @override
  _BoxDetailSheetState createState() => _BoxDetailSheetState();
}

class _BoxDetailSheetState extends State<BoxDetailSheet> {
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final boxDate = DateTime(date.year, date.month, date.day);

    if (boxDate == today) {
      return 'Today';
    } else if (boxDate == yesterday) {
      return 'Yesterday';
    } else if (boxDate.isAfter(today.subtract(Duration(days: 7)))) {
      final daysAgo = today.difference(boxDate).inDays;
      return '$daysAgo days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profitColor = widget.box.totalProfit >= 0 ? Colors.green : Colors.red;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: Colors.purple[700],
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.box.name ?? 'Unnamed Box',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatDate(widget.box.date),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Paid',
                        '£${widget.box.totalPaidPrice.toStringAsFixed(2)}',
                        Icons.shopping_cart_outlined,
                        Colors.orange,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Total Earned',
                        '£${widget.box.totalEarned.toStringAsFixed(2)}',
                        Icons.attach_money,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Profit',
                        '£${widget.box.totalProfit.toStringAsFixed(2)}',
                        Icons.trending_up,
                        profitColor,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Items',
                        '${widget.box.totalSoldItems}/${widget.box.totalItems} sold',
                        Icons.inventory,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 8),
                
                // Items Section Header
                Text(
                  'Items in Box',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
          
          // Items List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.box.items.length,
              itemBuilder: (context, index) {
                final item = widget.box.items[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () {
                      // Get the actual index of this item in the global items list
                      final allItems = StorageService.getAllItems();
                      final itemIndex = allItems.indexWhere((i) => i.name == item.name && i.boughtDate == item.boughtDate);
                      
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => ItemDetailSheet(
                          item: item,
                          index: itemIndex,
                          onItemUpdated: () {
                            setState(() {
                              // Refresh the box view
                            });
                            widget.onBoxUpdated();
                          },
                        ),
                      );
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.isLost
                            ? Colors.grey[400]
                            : item.isSold
                                ? Colors.green[400]
                                : Colors.blue[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.isLost
                            ? Icons.warning
                            : item.isSold
                                ? Icons.check_circle
                                : Icons.inventory_2,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'List: £${item.sellingPrice.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 12),
                        ),
                        if (item.isSold)
                          Text(
                            'Profit: £${item.profit.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: item.profit >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    trailing: item.isLost
                        ? Chip(
                            label: Text('LOST', style: TextStyle(fontSize: 10)),
                            backgroundColor: Colors.grey[200],
                            padding: EdgeInsets.zero,
                          )
                        : item.isSold
                            ? Chip(
                                label: Text('SOLD', style: TextStyle(fontSize: 10)),
                                backgroundColor: Colors.green[100],
                                padding: EdgeInsets.zero,
                              )
                            : null,
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
