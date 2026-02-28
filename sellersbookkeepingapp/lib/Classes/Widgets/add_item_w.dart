import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../item.dart';

Widget buildAddItemWidget({Function(Item)? onItemAdded}) {
  return AddItemWidget(onItemAdded: onItemAdded);
}

class AddItemWidget extends StatefulWidget {
  final Function(Item)? onItemAdded;

  const AddItemWidget({Key? key, this.onItemAdded}) : super(key: key);

  @override
  _AddItemWidgetState createState() => _AddItemWidgetState();
}

class _AddItemWidgetState extends State<AddItemWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _purchasedFromController = TextEditingController();
  final TextEditingController _paidPriceController = TextEditingController();
  final TextEditingController _listedPriceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _purchasedFromController.dispose();
    _paidPriceController.dispose();
    _listedPriceController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an item name')),
      );
      return;
    }

    final newItem = Item(
      name: _nameController.text.trim(),
      boughtFrom: _purchasedFromController.text.trim(),
      costPrice: double.tryParse(_paidPriceController.text) ?? 0.0,
      sellingPrice: double.tryParse(_listedPriceController.text) ?? 0.0,
      boughtDate: DateTime.now(),
    );
    
    if (widget.onItemAdded != null) {
      widget.onItemAdded!(newItem);
    }
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Item Name'),
            keyboardType: TextInputType.text,
          ),
          TextField(
            controller: _purchasedFromController,
            decoration: InputDecoration(labelText: 'Purchased From'),
            keyboardType: TextInputType.text,
          ),
          TextField(
            controller: _paidPriceController,
            decoration: InputDecoration(labelText: 'Paid Price'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          TextField(
            controller: _listedPriceController,
            decoration: InputDecoration(labelText: 'Listed Price'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _addItem,
            child: Text('Add Item'),
          ),
        ],
      ),
    );
  }
}