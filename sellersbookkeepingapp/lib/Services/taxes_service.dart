import '../Classes/tax.dart';
import 'storage_service.dart';

class TaxesService
{
  double income;
  late List<Tax> taxes;
    
  TaxesService(this.income) {
    // Load taxes from database instead of hardcoding
    taxes = StorageService.getAllTaxes();
  }

  List<Tax> getTaxes() {
    return taxes;
  }
  
  double getTotalTax() {
    return taxes.fold(0.0, (sum, tax) => sum + tax.calculateTax(income));
  }
}

