import 'package:flutter/material.dart';
import '../Classes/Widgets/add_item_w.dart';
import '../Classes/Widgets/add_box_w.dart';

class ManageItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Items'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Text('This is the Manage Items Page'),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: "AddItem",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return buildAddItemWidget();
                },
              );
            },
            icon: Icon(Icons.add),
            label: Text('Add Item'),
          ),
          SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: "addBox",
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(content: buildAddBoxWidget(),);
                },
              );
            },
            icon: Icon(Icons.add_box),
            label: Text('Add Box'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}