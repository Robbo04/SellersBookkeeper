import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../item.dart';

Widget buildAddItemWidget() {
  return Container(
    padding: EdgeInsets.all(16.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'Item Name'),
          keyboardType: TextInputType.text,
        ),
        TextField (
          decoration: InputDecoration(labelText: 'Description'),
          keyboardType: TextInputType.text,
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Purchased From'),
          keyboardType: TextInputType.text,
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Paid Price'),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Listed Price'),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            // Handle item addition logic here
          },
          child: Text('Add Item'),
        ),
      ],
    ),
  );
}