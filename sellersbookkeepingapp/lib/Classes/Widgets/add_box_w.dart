import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../item.dart';
import '../pye_box.dart';
import '../../Services/storage_service.dart';

Widget buildAddBoxWidget({Function()? onBoxAdded}) {
  return AddBoxWidget(onBoxAdded: onBoxAdded);
}

class AddBoxWidget extends StatefulWidget {
  final Function()? onBoxAdded;

  const AddBoxWidget({Key? key, this.onBoxAdded}) : super(key: key);

  @override
  _AddBoxWidgetState createState() => _AddBoxWidgetState();
}

class _AddBoxWidgetState extends State<AddBoxWidget> {
  final TextEditingController _boxNameController = TextEditingController();
  final TextEditingController _totalPaidController = TextEditingController();
  final List<Item> _itemsInBox = [];

  @override
  void dispose() {
    _boxNameController.dispose();
    _totalPaidController.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final retailPriceController = TextEditingController();
    final listedPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Item to Box'),
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
                controller: retailPriceController,
                decoration: InputDecoration(
                  labelText: 'Retail Price',
                  border: OutlineInputBorder(),
                  prefixText: '£',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              SizedBox(height: 12),
              TextField(
                controller: listedPriceController,
                decoration: InputDecoration(
                  labelText: 'Listed Price',
                  border: OutlineInputBorder(),
                  prefixText: '£',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter an item name')),
                );
                return;
              }

              final newItem = Item(
                name: nameController.text.trim(),
                sellingPrice: double.tryParse(listedPriceController.text) ?? 0.0,
                retailPrice: double.tryParse(retailPriceController.text) ?? 0.0,
                boughtDate: DateTime.now(),
                boxName: _boxNameController.text.trim(),
              );

              setState(() {
                _itemsInBox.add(newItem);
              });

              Navigator.pop(context);
            },
            child: Text('Add to Box'),
          ),
        ],
      ),
    );
  }

  void _createBox() async {
    if (_boxNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a box name')),
      );
      return;
    }

    if (_itemsInBox.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one item to the box')),
      );
      return;
    }

    double totalPaid = double.tryParse(_totalPaidController.text) ?? 0.0;

    final newBox = PyeBox(
      id: DateTime.now().millisecondsSinceEpoch,
      totalPaidPrice: totalPaid,
      date: DateTime.now(),
      items: _itemsInBox,
      name: _boxNameController.text.trim(),
    );

    // Save box to storage
    await StorageService.addBox(newBox);

    // Also save each item individually to the items collection
    for (var item in _itemsInBox) {
      await StorageService.addItem(item);
    }

    widget.onBoxAdded?.call();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Box created with ${_itemsInBox.length} item(s)!'),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New Box',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          // Box Name Field
          TextField(
            controller: _boxNameController,
            decoration: InputDecoration(
              labelText: 'Box Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
          ),
          SizedBox(height: 12),
          
          // Total Paid Price Field
          TextField(
            controller: _totalPaidController,
            decoration: InputDecoration(
              labelText: 'Total Paid Price for Box',
              border: OutlineInputBorder(),
              prefixText: '\£',
              helperText: 'Total amount paid for all items in this box',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          SizedBox(height: 16),
          
          // Items Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items in Box (${_itemsInBox.length})',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showAddItemDialog,
                icon: Icon(Icons.add, size: 18),
                label: Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          
          // Items List
          Expanded(
            child: _itemsInBox.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
                        SizedBox(height: 8),
                        Text(
                          'No items yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          'Tap "Add Item" to start',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _itemsInBox.length,
                    itemBuilder: (context, index) {
                      final item = _itemsInBox[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.boughtFrom.isNotEmpty)
                                Text('From: ${item.boughtFrom}'),
                              Text(
                                'Retail: £${item.retailPrice.toStringAsFixed(2)} | '
                                'Selling: £${item.sellingPrice.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _itemsInBox.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: 16),
          
          // Create Box Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _createBox,
              icon: Icon(Icons.add_box),
              label: Text('Create Box'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}