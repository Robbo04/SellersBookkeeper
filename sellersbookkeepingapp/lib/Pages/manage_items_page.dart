import 'package:flutter/material.dart';
import '../Classes/Widgets/add_item_w.dart';
import '../Classes/Widgets/add_box_w.dart';
import '../Classes/item.dart';

class ManageItemsPage extends StatefulWidget {
  @override
  _ManageItemsPageState createState() => _ManageItemsPageState();
}

class _ManageItemsPageState extends State<ManageItemsPage> {
  List<Item> items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text('Manage Items'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      
      
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.inventory)),
              title: Text(item.name),
              subtitle: Text('Purchased on: ${item.boughtDate.day}/${item.boughtDate.month}/${item.boughtDate.year}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Cost: \$${item.costPrice.toStringAsFixed(2)}'),
                  Text('Listing Price: \$${item.sellingPrice.toStringAsFixed(2)}', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(item.isSold ? 'Sold: \$${item.soldPrice.toStringAsFixed(2)}' : 'Not Sold', 
                    style: TextStyle(
                      color: item.isSold ? Colors.green : Colors.red, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
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
                  return buildAddItemWidget(
                    onItemAdded: (newItem) {
                      setState(() {
                        items.add(newItem);
                      });
                    },
                  );
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