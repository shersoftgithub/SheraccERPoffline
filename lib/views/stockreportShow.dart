import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stockDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stocklocalDB.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class ShowStockReport extends StatefulWidget {
  final String? itemcode;
  final String? supplier;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? itemname;
  const ShowStockReport({super.key,this.fromDate,this.itemcode,this.supplier,this.toDate,this.itemname});

  @override
  State<ShowStockReport> createState() => _ShowStockReportState();
}

class _ShowStockReportState extends State<ShowStockReport> {
  List<Map<String, dynamic>> stockData = [];

  @override
  void initState() {
    super.initState();
    _fetchStockData();
    //_fetchStockData2();
  }

  Future<void> _fetchStockData() async {
  try {
    List<Map<String, dynamic>> data = await StockDatabaseHelper.instance.getFilteredStockData(
      itemcode: widget.itemcode??"", 
      supplier: widget.supplier??"", 
      fromDate: widget.fromDate, 
      toDate: widget.toDate,
      itemname: widget.itemname??""
    );

    print('Fetched filtered stock data: $data');
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
    print('Fetched stock data: $data'); 
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
          padding:  EdgeInsets.only(top: screenHeight*0.017),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_sharp,
              color: Colors.white,
              size: screenHeight*0.024,
            ),
          ),
        ),
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: Text(
              "Stock Report",  
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
                width: screenHeight*0.024,
                height: screenHeight*0.024,
                child: Image.asset("assets/images/setting (2).png"),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding:  EdgeInsets.only(top: screenHeight*0.01),
          child: SingleChildScrollView(
            child: Table(
              border: TableBorder.all(
                color: Colors.black,
                width: 1.0,
              ),
              columnWidths: {
                0: FixedColumnWidth(40), 
                1: FixedColumnWidth(55), 
                2: FixedColumnWidth(120),
                3: FixedColumnWidth(60),
                4: FixedColumnWidth(70),
                5: FixedColumnWidth(80),
              },
              children: [
                TableRow(
                  children: [
                    _buildHeaderCell('SlNo'),
                    _buildHeaderCell('ItemId'),
                    _buildHeaderCell('ItemName'),
                    _buildHeaderCell('Qty'),
                    _buildHeaderCell('Disc'),
                    _buildHeaderCell('Amount'),
                  ],
                ),
                ...stockData.map((data) {
                  return TableRow(
                    children: [
                      _buildDataCell(data['id'].toString()), 
                      _buildDataCell(data['ItemId'] ?? 'N/A'), 
                      _buildDataCell(data['itemname'] ?? 'N/A'), 
                      _buildDataCell(data['Qty'].toString() ?? '0'), 
                      _buildDataCell(data['Disc'].toString() ?? '0'), 
                      _buildDataCell(data['Amount'].toString() ?? '0'), 
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
  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      color: Colors.blue,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: getFonts(11, Colors.black),
      ),
    );
  }

  Widget _buildDataCell(String text) {
   return Container(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        text,
        style: getFonts(10, Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }
}
