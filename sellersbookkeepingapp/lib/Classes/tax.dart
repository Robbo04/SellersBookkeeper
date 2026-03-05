class Tax 
{
  String name;
  double rate;
  double minimumIncomeRequired;
  double? maxTaxedincome; // Made nullable

  double calculateTax(double income) {
    if (income < minimumIncomeRequired) {
      return 0.0; // No tax if income is below the minimum threshold
    }
    
    // Calculate taxable income above the minimum
    double taxableIncome = income - minimumIncomeRequired;
    
    // Cap the taxable income if maxTaxedincome is set
    if (maxTaxedincome != null) {
      double maxTaxable = maxTaxedincome! - minimumIncomeRequired;
      taxableIncome = taxableIncome > maxTaxable ? maxTaxable : taxableIncome;
    }
    
    return taxableIncome * rate;
  }

  Tax(this.name, this.rate, this.minimumIncomeRequired, [this.maxTaxedincome]);
}