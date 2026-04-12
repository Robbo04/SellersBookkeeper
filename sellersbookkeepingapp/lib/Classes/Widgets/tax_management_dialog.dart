import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tax.dart';
import '../../Services/storage_service.dart';

class TaxManagementDialog extends StatefulWidget {
  @override
  _TaxManagementDialogState createState() => _TaxManagementDialogState();
}

class _TaxManagementDialogState extends State<TaxManagementDialog> {
  List<Tax> _taxes = [];

  @override
  void initState() {
    super.initState();
    _loadTaxes();
  }

  void _loadTaxes() {
    setState(() {
      _taxes = StorageService.getAllTaxes();
    });
  }

  Future<void> _showAddEditDialog({Tax? existingTax, int? index}) async {
    final nameController = TextEditingController(text: existingTax?.name ?? '');
    final rateController = TextEditingController(
      text: existingTax != null ? (existingTax.rate * 100).toString() : '',
    );
    final minIncomeController = TextEditingController(
      text: existingTax?.minimumIncomeRequired.toString() ?? '',
    );
    final maxIncomeController = TextEditingController(
      text: existingTax?.maxTaxedincome?.toString() ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingTax == null ? 'Add Tax' : 'Edit Tax'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tax Name',
                  hintText: 'e.g., Income Tax (20%)',
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: rateController,
                decoration: InputDecoration(
                  labelText: 'Tax Rate (%)',
                  hintText: 'e.g., 20',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              SizedBox(height: 12),
              TextField(
                controller: minIncomeController,
                decoration: InputDecoration(
                  labelText: 'Minimum Income (£)',
                  hintText: 'e.g., 12570',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              SizedBox(height: 12),
              TextField(
                controller: maxIncomeController,
                decoration: InputDecoration(
                  labelText: 'Maximum Income (£) - Optional',
                  hintText: 'Leave empty for no limit',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final rateText = rateController.text.trim();
              final minIncomeText = minIncomeController.text.trim();
              final maxIncomeText = maxIncomeController.text.trim();

              if (name.isEmpty || rateText.isEmpty || minIncomeText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill in all required fields'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final rate = double.tryParse(rateText);
              final minIncome = double.tryParse(minIncomeText);
              final maxIncome = maxIncomeText.isEmpty ? null : double.tryParse(maxIncomeText);

              if (rate == null || minIncome == null || (maxIncomeText.isNotEmpty && maxIncome == null)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter valid numbers'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final tax = Tax(name, rate / 100, minIncome, maxIncome);

              if (existingTax == null) {
                await StorageService.addTax(tax);
              } else if (index != null) {
                await StorageService.updateTax(index, tax);
              }

              Navigator.pop(context, true);
            },
            child: Text(existingTax == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadTaxes();
    }
  }

  Future<void> _deleteTax(int index, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Tax'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteTax(index);
      _loadTaxes();
    }
  }

  Future<void> _resetToDefaults() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset to Defaults'),
        content: Text('This will delete all custom taxes and restore UK default tax rates. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.resetToDefaultTaxes();
      _loadTaxes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Taxes reset to UK defaults')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Manage Taxes',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _taxes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No taxes configured',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _resetToDefaults,
                            icon: Icon(Icons.restore),
                            label: Text('Load UK Defaults'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _taxes.length,
                      itemBuilder: (context, index) {
                        final tax = _taxes[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              tax.name,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text('Rate: ${(tax.rate * 100).toStringAsFixed(1)}%'),
                                Text('Min Income: £${tax.minimumIncomeRequired.toStringAsFixed(0)}'),
                                if (tax.maxTaxedincome != null)
                                  Text('Max Income: £${tax.maxTaxedincome!.toStringAsFixed(0)}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showAddEditDialog(
                                    existingTax: tax,
                                    index: index,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteTax(index, tax.name),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            // Footer buttons
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetToDefaults,
                      icon: Icon(Icons.restore),
                      label: Text('Reset to Defaults'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(),
                      icon: Icon(Icons.add),
                      label: Text('Add Tax'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
