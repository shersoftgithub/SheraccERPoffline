import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stockDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stocklocalDB.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class ShowStockReport extends StatefulWidget {
  const ShowStockReport({super.key});

  @override
  State<ShowStockReport> createState() => _ShowStockReportState();
}

class _ShowStockReportState extends State<ShowStockReport> {
  // Stock data will be fetched from the database
  List<Map<String, dynamic>> stockData = [];

  @override
  void initState() {
    super.initState();
    _fetchStockData();
    _fetchStockData2();
  }

  Future<void> _fetchStockData() async {
  try {
    List<Map<String, dynamic>> data = await StockDatabaseHelper.instance.getAllProductRegistration();
    print('Fetched stock data: $data'); // Debug fetched data
    setState(() {
      stockData = data;
    });
  } catch (e) {
    print('Error fetching stock data: $e');
  }
}
Future<void> _fetchStockData2() async {
  try {
    List<Map<String, dynamic>> data = await StockDatabaseHelper.instance.getAllProducts();
    print('Fetched stock data: $data'); // Debug fetched data
    setState(() {
      stockData = data;
    });
  } catch (e) {
    print('Error fetching stock data: $e');
  }
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
          child: SingleChildScrollView(
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
                    _buildHeaderCell('ItemId'),
                    _buildHeaderCell('supplier'),
                    _buildHeaderCell('Qty'),
                    _buildHeaderCell('Disc'),
                    _buildHeaderCell('Amount'),
                  ],
                ),
                // Table data rows
                ...stockData.map((data) {
                  return TableRow(
                    children: [
                      _buildDataCell(data['id'].toString()), // Assuming id is present in the database
                      _buildDataCell(data['itemcode'] ?? 'N/A'), // Adjust as needed based on your DB schema
                      _buildDataCell(data['itemname'] ?? 'N/A'), // Assuming column name is `item_name`
                      _buildDataCell(data['Qty'].toString() ?? '0'), // Assuming column name is `quantity`
                      _buildDataCell(data['Disc'].toString() ?? '0'), // Assuming column name is `rate`
                      _buildDataCell(data['Amount'].toString() ?? '0'), // Assuming column name is `total`
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header cell builder
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

  // Data cell builder
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
