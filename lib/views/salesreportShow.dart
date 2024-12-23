import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/salesDBHelper.dart'; // Adjust with your actual import
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class ShowSalesReport extends StatefulWidget {
  const ShowSalesReport({super.key});

  @override
  State<ShowSalesReport> createState() => _ShowPaymentReportState();
}

class _ShowPaymentReportState extends State<ShowSalesReport> {
  List<Map<String, dynamic>> paymentData = []; 

  @override
  void initState() {
    super.initState();
    _fetchPaymentData(); 
  }

  Future<void> _fetchPaymentData() async {
    List<Map<String, dynamic>> data =
        await SaleDatabaseHelper.instance.queryAllRows(); 
    setState(() {
      paymentData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Appcolors().scafoldcolor,
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.1,
        backgroundColor: Appcolors().maincolor,
        leading: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_sharp,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: Text(
              "Payment Report",
              style: appbarFonts(screenHeight * 0.02, Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight * 0.02),
            child: GestureDetector(
              onTap: () {},
              child: SizedBox(
                width: 20,
                height: 20,
                child: Image.asset("assets/images/setting (2).png"),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Table(
            border: TableBorder.all(
              color: Colors.black,
              width: 1.0,
            ),
            columnWidths: {
              0: FixedColumnWidth(60), 
              1: FixedColumnWidth(80),
              2: FixedColumnWidth(80), 
              3: FixedColumnWidth(80), 
              4: FixedColumnWidth(80), 
              5: FixedColumnWidth(80), 
              6: FixedColumnWidth(80), 
              7: FixedColumnWidth(80), 
              8: FixedColumnWidth(80), 
              9: FixedColumnWidth(80), 
              10: FixedColumnWidth(80), 
            },
            children: [
              TableRow(
                children: [
                  _buildHeaderCell('Invoice No'),
                  _buildHeaderCell('Date'),
                  _buildHeaderCell('Sale Rate'),
                  _buildHeaderCell('Customer'),
                  _buildHeaderCell('Phone No'),
                  _buildHeaderCell('Item Name'),
                  _buildHeaderCell('Quantity'),
                  _buildHeaderCell('Unit'),
                  _buildHeaderCell('Rate'),
                  _buildHeaderCell('Tax'),
                  _buildHeaderCell('Total Amt'),
                ],
              ),
              // Table data rows
              ...paymentData.map((data) {
                return TableRow(
                  children: [
                    _buildDataCell(data[SaleDatabaseHelper.columnId].toString()), // Invoice No
                    _buildDataCell(data[SaleDatabaseHelper.columnDate]),
                    _buildDataCell(data[SaleDatabaseHelper.columnSaleRate].toString()), // Sale Rate
                    _buildDataCell(data[SaleDatabaseHelper.columnCustomer]), // Customer
                    _buildDataCell(data[SaleDatabaseHelper.columnPhoneNo]), // Phone No
                    _buildDataCell(data[SaleDatabaseHelper.columnItemName]), // Item Name
                    _buildDataCell(data[SaleDatabaseHelper.columnQTY].toString()), // Quantity
                    _buildDataCell(data[SaleDatabaseHelper.columnUnit]), // Unit
                    _buildDataCell(data[SaleDatabaseHelper.columnRate].toString()), // Rate
                    _buildDataCell(data[SaleDatabaseHelper.columnTax].toString()), // Tax
                    _buildDataCell(data[SaleDatabaseHelper.columnTotalAmt].toString()), // Total Amount
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
