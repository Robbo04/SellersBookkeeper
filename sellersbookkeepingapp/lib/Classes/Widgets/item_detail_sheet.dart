import 'package:flutter/material.dart';
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
              StorageService.updateItemFromCombinedList(item);
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
            label: 'Edit Item',
            color: Colors.blue,
            onPressed: () => _showEditItemDialog(context, item),
          ),
          SizedBox(height: 8),


          _buildActionButton(
            context,
            icon: Icons.delete_outline,
            label: 'Mark as Lost',
            color: Colors.red,
            onPressed: () {
              item.lostItem();
              StorageService.updateItemFromCombinedList(item);
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

  void _showEditItemDialog(BuildContext context, Item item) {
    final nameController = TextEditingController(text: item.name);
    final boughtFromController = TextEditingController(text: item.boughtFrom);
    final costPriceController = TextEditingController(
      text: item.costPrice != null ? item.costPrice.toString() : '',
    );
    final sellingPriceController = TextEditingController(text: item.sellingPrice.toString());
    final retailPriceController = TextEditingController(text: item.retailPrice.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: boughtFromController,
                decoration: InputDecoration(
                  labelText: 'Bought From',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: costPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cost Price (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Leave empty if no cost',
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: sellingPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Selling Price',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: retailPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Retail Price',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Update item fields
              item.name = nameController.text.trim();
              item.boughtFrom = boughtFromController.text.trim();
              item.costPrice = costPriceController.text.trim().isEmpty 
                  ? null 
                  : double.tryParse(costPriceController.text);
              item.sellingPrice = double.tryParse(sellingPriceController.text) ?? item.sellingPrice;
              item.retailPrice = double.tryParse(retailPriceController.text) ?? item.retailPrice;
              
              StorageService.updateItemFromCombinedList(item);
              onItemUpdated();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail sheet
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Item updated successfully'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}