import 'package:flutter/material.dart';

class MyTablePage extends StatelessWidget {
  final TextEditingController _itemnameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _DiscountController = TextEditingController();
  final String _selectedRate = '50'; // Example rate, replace with your actual rate logic
  final double finalAmt = 200.0; // Example amount, replace with your actual final amount logic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table with Scrolling and Column Widths'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Enables horizontal scrolling
          child: Table(
            border: TableBorder.all(color: Colors.black), // Border for the table
            children: [
              // Header Row
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100], // Background color for header
                ),
                children: [
                  _tableHeaderCell('Item Name', width: 120),
                  _tableHeaderCell('Qty', width: 80),
                  _tableHeaderCell('Unit', width: 100),
                  _tableHeaderCell('Rate', width: 100),
                  _tableHeaderCell('Tax', width: 100),
                  _tableHeaderCell('Discount', width: 100),
                  _tableHeaderCell('Total Amt', width: 120),
                ],
              ),
              // Data Row
              TableRow(
                children: [
                  _tableCell('${_itemnameController.text}', width: 120),
                  _tableCell('${_qtyController.text}', width: 80),
                  _tableCell('${_unitController.text}', width: 100),
                  _tableCell('${_selectedRate}', width: 100),
                  _tableCell('${_taxController.text}', width: 100),
                  _tableCell('${_DiscountController.text}', width: 100),
                  _tableCell('${finalAmt.toString()}', width: 120),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create header cells with a custom width
  Widget _tableHeaderCell(String text, {double width = 100}) {
    return Container(
      width: width,
      padding: EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper method to create data cells with a custom width
  Widget _tableCell(String text, {double width = 100}) {
    return Container(
      width: width,
      padding: EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyTablePage(),
  ));
}
