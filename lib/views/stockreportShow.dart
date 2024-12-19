import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class ShowStockReport extends StatefulWidget {
  const ShowStockReport({super.key});

  @override
  State<ShowStockReport> createState() => _ShowStockReportState();
}

class _ShowStockReportState extends State<ShowStockReport> {
  // Stock data with correct keys
  List<Map<String, String>> stockData = [
    {
      'SlNo': '1',
      'Itemcode': '12345',
      'ItemName': 'Product A',
      'Qty': '10',
      'Rate': '50',
      'Total': '500',
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
              "Stock Report",  // Updated title to reflect the correct report
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
              0: FixedColumnWidth(60), // Adjust the first column width (SlNo)
              1: FixedColumnWidth(80), // Adjust other column widths
              2: FixedColumnWidth(120),
              3: FixedColumnWidth(80),
              4: FixedColumnWidth(80),
              5: FixedColumnWidth(80),
            },
            children: [
              // Table header row
              TableRow(
                children: [
                  _buildHeaderCell('SlNo'),
                  _buildHeaderCell('Item Code'),
                  _buildHeaderCell('Item Name'),
                  _buildHeaderCell('Qty'),
                  _buildHeaderCell('Rate'),
                  _buildHeaderCell('Total'),
                ],
              ),
              // Table data rows
              ...stockData.map((data) {
                return TableRow(
                  children: [
                    _buildDataCell(data['SlNo']!),
                    _buildDataCell(data['Itemcode']!),
                    _buildDataCell(data['ItemName']!),
                    _buildDataCell(data['Qty']!),
                    _buildDataCell(data['Rate']!),
                    _buildDataCell(data['Total']!),
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
