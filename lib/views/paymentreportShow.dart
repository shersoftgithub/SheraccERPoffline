import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class ShowPaymentReport extends StatefulWidget {
  const ShowPaymentReport({super.key});

  @override
  State<ShowPaymentReport> createState() => _ShowPaymentReportState();
}

class _ShowPaymentReportState extends State<ShowPaymentReport> {
  // Sales data with correct keys
  List<Map<String, String>> paymentData = [
    {
      'No': 'Data 1',
      'Date': 'Data 2',
      'Customer': 'Data 5',
      'Amount': 'Data 6',
      'Narration': 'Data 7',
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
              "Payment Report",  // Updated title to reflect the correct report
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
              0: FixedColumnWidth(60), // Adjust the first column width (No)
              1: FixedColumnWidth(80), // Adjust other column widths
              2: FixedColumnWidth(100),
              3: FixedColumnWidth(80),
              4: FixedColumnWidth(100),
            },
            children: [
              // Table header row
              TableRow(
                children: [
                  _buildHeaderCell('No'),
                  _buildHeaderCell('Date'),
                  _buildHeaderCell('Customer'),
                  _buildHeaderCell('Amount'),
                  _buildHeaderCell('Narration'),
                ],
              ),
              // Table data rows
              ...paymentData.map((data) {
                return TableRow(
                  children: [
                    _buildDataCell(data['No']!),
                    _buildDataCell(data['Date']!),
                    _buildDataCell(data['Customer']!),
                    _buildDataCell(data['Amount']!),
                    _buildDataCell(data['Narration']!),
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
      color: Colors.grey[200],
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
