import 'package:flutter/material.dart';
import 'package:sellersbookkeepingapp/Pages/manage_items_page.dart';
import '../item.dart';
import '../../Services/storage_service.dart';

class ItemDetailSheet extends StatelessWidget {
  final Item item;
  final int index;
  final VoidCallback onItemUpdated;

  const ItemDetailSheet({
    required this.item,
    required this.index,
    required this.onItemUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            item.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 12),
          
          
          _buildActionButton(
            context,
            icon: Icons.check_circle_outline,
            label: 'Mark as Sold',
            color: Colors.green,
            onPressed: () {
              item.soldItem();
              StorageService.updateItem(index, item);
              onItemUpdated();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Item marked as sold'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          SizedBox(height: 8),


          _buildActionButton(
            context,
            icon: Icons.edit,
            label: 'Change Listing Price',
            color: Colors.blue,
            onPressed: () => _showPriceDialog(context, item, index),
          ),
          SizedBox(height: 8),


          _buildActionButton(
            context,
            icon: Icons.delete_outline,
            label: 'Mark as Lost',
            color: Colors.red,
            onPressed: () {
              item.lostItem();
              StorageService.updateItem(index, item);
              onItemUpdated();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Item marked as lost'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  void _showPriceDialog(BuildContext context, Item item, int index) {
    final controller = TextEditingController(text: item.sellingPrice.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Listing Price'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter new price',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              item.changeSellingPrice(double.parse(controller.text));
              StorageService.updateItem(index, item);
              onItemUpdated();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}