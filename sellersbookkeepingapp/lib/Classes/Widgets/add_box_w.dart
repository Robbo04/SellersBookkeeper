import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildAddBoxWidget() {
  return Container(
    padding: EdgeInsets.all(16.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'Box Name'),
          keyboardType: TextInputType.text,
        ),
        TextField (
          decoration: InputDecoration(labelText: 'Description'),
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            // Handle box addition logic here
          },
          child: Text('Add Box'),
        ),
      ],
    ),
  );
}