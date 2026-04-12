import 'package:flutter/material.dart';
import '../Pages/manage_items_page.dart';
import '../Pages/taxing_page.dart';
import '../Pages/summary_page.dart';

class MainTabScaffold extends StatefulWidget {
  @override
  _MainTabScaffoldState createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ManageItemsPage(),
    TaxingPage(),
    SummaryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 184, 55, 182),
        unselectedItemColor: Colors.black,
        selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Items'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money_rounded), label: 'Taxing'),
          BottomNavigationBarItem(icon: Icon(Icons.addchart), label: 'Summary'),
        ],
      ),
    );
  }
}
