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
  final TextEditingController _retailPriceController = TextEditingController();
  final TextEditingController _listedPriceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _purchasedFromController.dispose();
    _paidPriceController.dispose();
    _retailPriceController.dispose();
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
      retailPrice: double.tryParse(_retailPriceController.text) ?? 0.0,
      boughtDate: DateTime.now(),
    );
    
    if (widget.onItemAdded != null) {
      widget.onItemAdded!(newItem);
    }
    
    Navigator.pop(context);
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color.fromARGB(110, 227, 154, 209),
      labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
    );
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
            decoration: _buildInputDecoration('Item Name'),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16),
          
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _purchasedFromController,
                  decoration: _buildInputDecoration('Purchased From'),
                  keyboardType: TextInputType.text,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _paidPriceController,
                  decoration: _buildInputDecoration('Paid Price'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          TextField(
            controller: _retailPriceController,
            decoration: _buildInputDecoration('Retail Price'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          SizedBox(height: 16.0),

          TextField(
            controller: _listedPriceController,
            decoration: _buildInputDecoration('Listed Price'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          
          
          ElevatedButton(
            onPressed: _addItem,
            child: Text('Add Item'),
          ),
        ],
      ),
    );
  }
}