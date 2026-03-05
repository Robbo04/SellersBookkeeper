import 'package:flutter/material.dart';
import '../Classes/tax.dart';
import '../Services/taxes_service.dart';

class TaxingPage extends StatefulWidget {
  @override
  State<TaxingPage> createState() => _TaxingPageState();
}

class _TaxingPageState extends State<TaxingPage> {
  final TextEditingController _incomeController = TextEditingController();
  TaxesService? _taxesService;
  bool _calculated = false;

  void _calculateTax() {
    final income = double.tryParse(_incomeController.text);
    if (income != null) {
      setState(() {
        _taxesService = TaxesService(income);
        _calculated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Taxing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            'Tax Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _incomeController,
            decoration: InputDecoration(
              labelText: 'Income',
              border: OutlineInputBorder(),
              prefixText: '£',
            ),
            keyboardType: TextInputType.number,
          ),
          Text(
            'Enter your income to calculate the tax based on the defined tax rates.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _calculateTax,
            child: Text('Calculate Tax'),
          ),
          SizedBox(height: 16),
          if (_calculated && _taxesService != null) ...[
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tax Breakdown',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ..._taxesService!.getTaxes().map((tax) {
                      final amount = tax.calculateTax(_taxesService!.income);
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tax.name),
                            Text('£${amount.toStringAsFixed(2)}'),
                          ],
                        ),
                      );
                    }).toList(),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Tax',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '£${_taxesService!.getTaxes().fold(0.0, (sum, tax) => sum + tax.calculateTax(_taxesService!.income)).toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }
}
