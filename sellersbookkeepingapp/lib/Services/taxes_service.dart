import 'package:flutter/material.dart';
import '../Classes/tax.dart';

class TaxesService
{
  double income;
  late List<Tax> taxes;
  late Tax basicTax;
  late double basicTaxAmount;
  late Tax higherTax;
  late Tax nationalInsurance;
  late Tax nationalInsurance2;
    
  TaxesService(this.income) {
    // Initialize tax objects
    
    basicTax = Tax('Basic Tax', 0.20, 12570, 52750);
    higherTax = Tax('Higher Tax', 0.40, 52750, double.infinity);
    nationalInsurance = Tax('National Insurance', 0.06, 12570, 50270);
    nationalInsurance2 = Tax('National Insurance 2', 0.02, 50270);
    
    // Add them to the list
    taxes = [
      basicTax,
      higherTax,
      nationalInsurance,
      nationalInsurance2
    ];
  }

  List<Tax> getTaxes() {
    return taxes;
  }
}

