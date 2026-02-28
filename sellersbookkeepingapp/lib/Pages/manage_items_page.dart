import 'package:flutter/material.dart';
import '../Classes/Widgets/add_item_w.dart';
import '../Classes/Widgets/add_box_w.dart';
import '../Classes/Widgets/item_card.dart';
import '../Classes/item.dart';
import '../Services/storage_service.dart';

class ManageItemsPage extends StatefulWidget {
  @override
  _ManageItemsPageState createState() => _ManageItemsPageState();
}

class _ManageItemsPageState extends State<ManageItemsPage> with SingleTickerProviderStateMixin {
  List<Item> items = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _loadItems();
  }
  
  void _loadItems() {
    setState(() {
      items = StorageService.getAllItems();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshItems() async {
    await Future.delayed(Duration(milliseconds: 500));
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.inventory_2, size: 24),
            SizedBox(width: 8),
            Text('Manage Items'),
            if (items.isNotEmpty) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      
      
      body: items.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _refreshItems,
              child: ListView.builder(
                padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 100),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ItemCard(item: items[index], index: index);
                },
              ),
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
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: buildAddItemWidget(
                      onItemAdded: (newItem) async {
                        // Save to storage
                        await StorageService.addItem(newItem);
                        // Reload items from storage
                        _loadItems();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Item added successfully!'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.add),
            label: Text('Add Item'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 16),
          
          
          FloatingActionButton.extended(
            heroTag: "addBox",
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: buildAddBoxWidget(),
                  );
                },
              );
            },
            icon: Icon(Icons.add_box),
            label: Text('Add Box'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            'No items yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the "Add Item" button to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}