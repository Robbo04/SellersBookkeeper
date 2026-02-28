import 'package:flutter/material.dart';
import '../item.dart';
import '../Widgets/item_detail_sheet.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final int index;

  const ItemCard({
    Key? key,
    required this.item,
    required this.index,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Today';
    } else if (itemDate == yesterday) {
      return 'Yesterday';
    } else if (itemDate.isAfter(today.subtract(Duration(days: 7)))) {
      final daysAgo = today.difference(itemDate).inDays;
      return '$daysAgo days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profitColor = item.isSold 
        ? (item.profit >= 0 ? Colors.green : Colors.red)
        : Colors.grey;

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 8),
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ItemDetailSheet(
                item: item,
                index: index,
                onItemUpdated: () {
                  // Trigger a rebuild of the parent widget to reflect changes
                  (context as Element).markNeedsBuild();
                },
              ),
            );
            // Handle item tap for details
          },
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: item.isLost
                              ? [Colors.grey[400]!, Colors.grey[600]!]
                              : item.isSold 
                                  ? [Colors.green[400]!, Colors.green[600]!]
                                  : [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
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
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.isLost)
                                Container(
                                  margin: EdgeInsets.only(left: 6),
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[400]!, width: 0.5),
                                  ),
                                  child: Text(
                                    'LOST',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                )
                              else if (item.isSold)
                                Container(
                                  margin: EdgeInsets.only(left: 6),
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green[300]!, width: 0.5),
                                  ),
                                  child: Text(
                                    'SOLD',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text(
                            _formatDate(item.boughtDate),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCompactPrice('Cost', item.costPrice, Icons.shopping_cart_outlined, Colors.orange),
                        if (!item.isLost) ...[
                          SizedBox(height: 4),
                          if (!item.isSold) ...[
                            _buildCompactPrice('Retail', item.retailPrice, Icons.store_outlined, Colors.purple),
                            SizedBox(height: 4),
                          ],
                          _buildCompactPrice('List', item.sellingPrice, Icons.local_offer_outlined, Colors.blue),
                          if (item.isSold) ...[
                            SizedBox(height: 4),
                            _buildCompactPrice('Profit', item.profit, Icons.trending_up, profitColor, isProfit: true),
                          ],
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactPrice(String label, double amount, IconData icon, Color color, {bool isProfit = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 4),
        Text(
          '${isProfit && amount >= 0 ? '+' : ''}\£${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isProfit ? color : Colors.black87,
          ),
        ),
      ],
    );
  }
}
