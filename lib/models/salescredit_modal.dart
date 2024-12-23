class SalesCredit {
  final int? invoiceId;
  final String date;
  final double salesRate;
  final String customer;
  final String phoneNo;
  final String itemName;
  final double qty;
  final String unit;
  final double rate;
  final double tax;
  final double totalAmt;

  SalesCredit({
    this.invoiceId,
    required this.date,
    required this.salesRate,
    required this.customer,
    required this.phoneNo,
    required this.itemName,
    required this.qty,
    required this.unit,
    required this.rate,
    required this.tax,
    required this.totalAmt,
  });

  // Convert SalesCredit object to a map
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'sales_rate': salesRate,
      'customer': customer,
      'phoneNo': phoneNo,
      'item_name': itemName,
      'qty': qty,
      'unit': unit,
      'rate': rate,
      'tax': tax,
      'total_amt': totalAmt,
    };
  }

  // Convert a map to SalesCredit object
  static SalesCredit fromMap(Map<String, dynamic> map) {
    return SalesCredit(
      invoiceId: map['invoiceid'],
      date: map['date'],
      salesRate: map['sales_rate'],
      customer: map['customer'],
      phoneNo: map['phoneNo'],
      itemName: map['item_name'],
      qty: map['qty'],
      unit: map['unit'],
      rate: map['rate'],
      tax: map['tax'],
      totalAmt: map['tatal_amt'],
    );
  }
}
