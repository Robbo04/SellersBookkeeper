import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'taxes_service.dart';
import '../Classes/item.dart';
import 'storage_service.dart';

class MonthlyData {
  final String month;
  final double revenue;
  final double amountSpent;
  final double monthlyProfit;
  final double runningProfit;

  MonthlyData({
    required this.month,
    required this.revenue,
    required this.amountSpent,
    required this.monthlyProfit,
    required this.runningProfit,
  });
}

List<MonthlyData> _calculateMonthlyData(DateTime startDate, DateTime endDate, List<Item> allItems) {
  List<MonthlyData> monthlyDataList = [];
  double runningProfit = 0.0;
  
  // Get all expenses
  final allExpenses = StorageService.getAllExpenses();
  
  // Get the first month and year
  DateTime currentMonth = DateTime(startDate.year, startDate.month, 1);
  DateTime endMonth = DateTime(endDate.year, endDate.month, 1);
  
  while (currentMonth.isBefore(endMonth) || currentMonth.isAtSameMomentAs(endMonth)) {
    // Determine the actual start and end dates for this month
    DateTime monthStart = currentMonth;
    DateTime monthEnd = DateTime(currentMonth.year, currentMonth.month + 1, 0); // Last day of current month
    
    // Adjust for partial months
    if (currentMonth.year == startDate.year && currentMonth.month == startDate.month) {
      monthStart = startDate;
    }
    if (currentMonth.year == endDate.year && currentMonth.month == endDate.month) {
      monthEnd = endDate;
    }
    
    // Filter items SOLD in this month (for revenue)
    final itemsSold = allItems.where((item) {
      if (item.soldDate == null) return false;
      
      final soldDate = DateTime(
        item.soldDate!.year,
        item.soldDate!.month,
        item.soldDate!.day,
      );
      
      return (soldDate.isAfter(monthStart) || soldDate.isAtSameMomentAs(monthStart)) &&
             (soldDate.isBefore(monthEnd) || soldDate.isAtSameMomentAs(monthEnd));
    }).toList();
    
    // Filter items BOUGHT in this month (for costs)
    final itemsBought = allItems.where((item) {
      final boughtDate = DateTime(
        item.boughtDate.year,
        item.boughtDate.month,
        item.boughtDate.day,
      );
      
      return (boughtDate.isAfter(monthStart) || boughtDate.isAtSameMomentAs(monthStart)) &&
             (boughtDate.isBefore(monthEnd) || boughtDate.isAtSameMomentAs(monthEnd));
    }).toList();
    
    // Filter expenses in this month
    final monthExpenses = allExpenses.where((expense) {
      final expenseDate = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      
      return (expenseDate.isAfter(monthStart) || expenseDate.isAtSameMomentAs(monthStart)) &&
             (expenseDate.isBefore(monthEnd) || expenseDate.isAtSameMomentAs(monthEnd));
    }).toList();
    
    // Calculate revenue (money made from sales) and costs (money spent on purchases + expenses)
    double revenue = itemsSold.fold(0.0, (sum, item) => sum + item.soldPrice);
    double itemCosts = itemsBought.fold(0.0, (sum, item) => sum + item.costPrice);
    double expenseCosts = monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    double amountSpent = itemCosts + expenseCosts;
    double monthlyProfit = revenue - amountSpent;
    runningProfit += monthlyProfit;
    
    // Format month name
    const monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String monthName = '${monthNames[currentMonth.month]} ${currentMonth.year}';
    
    monthlyDataList.add(MonthlyData(
      month: monthName,
      revenue: revenue,
      amountSpent: amountSpent,
      monthlyProfit: monthlyProfit,
      runningProfit: runningProfit,
    ));
    
    // Move to next month
    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
  }
  
  return monthlyDataList;
}

Future<void> generateTaxReport(
  TaxesService taxService,
  DateTime startDate,
  DateTime endDate,
  List<Item> allItems,
) async {
  final monthlyData = _calculateMonthlyData(startDate, endDate, allItems);
  final pdf = pw.Document();
  
  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text('Tax Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
        
        pw.Text('Monthly Breakdown:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        
        // Monthly Breakdown Table
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Month', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Revenue', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Amount Spent', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Monthly Profit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Running Profit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            // Monthly data rows
            ...monthlyData.map((data) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(data.month),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('£${data.revenue.toStringAsFixed(2)}'),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('£${data.amountSpent.toStringAsFixed(2)}'),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '£${data.monthlyProfit.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      color: data.monthlyProfit >= 0 ? PdfColors.green : PdfColors.red,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '£${data.runningProfit.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      color: data.runningProfit >= 0 ? PdfColors.green : PdfColors.red,
                    ),
                  ),
                ),
              ],
            )),
          ],
        ),
        
        pw.SizedBox(height: 20),
        pw.Text('Tax Breakdown:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        // Tax Table
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Tax Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Rate', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            // Data rows
            ...taxService.getTaxes().map((tax) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(tax.name),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('${(tax.rate * 100).toStringAsFixed(0)}%'),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('£${tax.calculateTax(taxService.income).toStringAsFixed(2)}'),
                ),
              ],
            )),
            // Total row
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text('Total Tax', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(''),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '£${taxService.getTaxes().fold<double>(0, (sum, tax) => sum + tax.calculateTax(taxService.income)).toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
  
  // Save or share
  await Printing.sharePdf(bytes: await pdf.save(), filename: 'tax-report.pdf');
}