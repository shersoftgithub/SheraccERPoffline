import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class ShowSalesReport extends StatefulWidget {
  const ShowSalesReport({super.key});

  @override
  State<ShowSalesReport> createState() => _ShowSalesReportState();
}

class _ShowSalesReportState extends State<ShowSalesReport> {
  List<Map<String, String>> salesData = [
    {
      'SiNo': 'data 1',
      'Date': 'Data 2',
      'EntryNo': 'Data 3',
      'InvoiceNo': 'Data 4',
      'Customer': 'Data 5',
      'Sub total': 'Data 6',
      'Discount': 'Data 7',
      'Tax': 'Data 8',
      'Total': 'Data 9',
      'SalesMan': 'Data 10',
      'Form': 'Data 11',
      'Cash Model': 'Data 12',
    },
  ];

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
              "Sales Report",
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
              11: FixedColumnWidth(80),
                },
                children: [
          TableRow(
            children: [
              _buildHeaderCell('SiNo'),
              _buildHeaderCell('Date'),
              _buildHeaderCell('EntryNo'),
              _buildHeaderCell('InvoiceNo'),
              _buildHeaderCell('Customer'),
              _buildHeaderCell('Sub total'),
              _buildHeaderCell('Discount'),
              _buildHeaderCell('Tax'),
              _buildHeaderCell('Total'),
              _buildHeaderCell('SalesMan'),
              _buildHeaderCell('Form'),
              _buildHeaderCell('Cash Model'),
            ],
          ),
          // Table data rows
          ...salesData.map((data) {
            return TableRow(
              children: [
                _buildDataCell(data['SiNo']!),
                _buildDataCell(data['Date']!),
                _buildDataCell(data['EntryNo']!),
                _buildDataCell(data['InvoiceNo']!),
                _buildDataCell(data['Customer']!),
                _buildDataCell(data['Sub total']!),
                _buildDataCell(data['Discount']!),
                _buildDataCell(data['Tax']!),
                _buildDataCell(data['Total']!),
                _buildDataCell(data['SalesMan']!),
                _buildDataCell(data['Form']!),
                _buildDataCell(data['Cash Model']!),
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
