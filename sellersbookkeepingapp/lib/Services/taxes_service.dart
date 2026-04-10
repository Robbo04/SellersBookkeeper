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
  late Tax studentLoan;
    
  TaxesService(this.income) {
    // Initialize tax objects
    
    basicTax = Tax('Basic Tax (£12,570 < income <= £52,750)', 0.20, 12570, 52750);
    higherTax = Tax('Higher Tax (income > £52,750)', 0.40, 52750, null);
    nationalInsurance = Tax('National Insurance (£12,570 < income <= £50,270)', 0.06, 12570, 50270);
    nationalInsurance2 = Tax('National Insurance 2 (income > £50,270)', 0.02, 50270);
    studentLoan = Tax('Student Loan (income > £28,470)', 0.09, 28470);
    
    // Add them to the list
    taxes = [
      basicTax,
      higherTax,
      nationalInsurance,
      nationalInsurance2,
      studentLoan
    ];
  }

  List<Tax> getTaxes() {
    return taxes;
  }
}

