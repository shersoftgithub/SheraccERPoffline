import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class ShowRecieptReport extends StatefulWidget {
  const ShowRecieptReport({super.key});

  @override
  State<ShowRecieptReport> createState() => _ShowRecieptReportState();
}

class _ShowRecieptReportState extends State<ShowRecieptReport> {
  // Payment data with correct keys
  List<Map<String, String>> paymentData = [
    {
      'No': '1',
      'Date': '2024-12-19',
      'Customer': 'Customer A',
      'Amount': '1000',
      'Narration': 'Payment received',
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
              "Receipt Report",  // Updated title to reflect the correct report
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
              1: FixedColumnWidth(100), 
              2: FixedColumnWidth(120),
              3: FixedColumnWidth(100),
              4: FixedColumnWidth(160), 
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
        overflow: TextOverflow.ellipsis,  // Ensures text does not wrap, uses ellipsis if it's too long
        softWrap: false,  // Ensures no wrapping
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,  // Ensures text does not wrap, uses ellipsis if it's too long
        softWrap: false,  // Ensures no wrapping
      ),
    );
  }
}
