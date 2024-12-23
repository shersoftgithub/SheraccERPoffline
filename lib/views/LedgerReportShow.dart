import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/newLedgerDBhelper.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class ShowLedger extends StatefulWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? ledgerName;

  const ShowLedger({super.key, this.fromDate, this.toDate, this.ledgerName});

  @override
  State<ShowLedger> createState() => _ShowSalesReportState();
}

class _ShowSalesReportState extends State<ShowLedger> {
  List<Map<String, dynamic>> ledgerData = [];
  double totalOpeningBalance = 0.0;  // Variable to hold the total opening balance

  @override
  void initState() {
    super.initState();
    _fetchLedgerData();
    _fetchLedgerData2();
  }

  Future<void> _fetchLedgerData() async {
    List<Map<String, dynamic>> data = await DatabaseHelper.instance.queryAllRows();
    if (widget.ledgerName!.isNotEmpty) {
      data = data.where((ledger) => ledger['ledger_name'].toLowerCase().contains(widget.ledgerName!.toLowerCase())).toList();
    }
    if (widget.fromDate != null && widget.toDate != null) {
      data = data.where((ledger) {
        DateTime ledgerDate = DateTime.parse(ledger['date']); 
        return ledgerDate.isAfter(widget.fromDate!) && ledgerDate.isBefore(widget.toDate!);
      }).toList();
    }

    // Calculate the total opening balance
    setState(() {
      ledgerData = data;
      totalOpeningBalance = ledgerData.fold(0.0, (sum, item) {
        double openingBalance = double.tryParse(item['opening_balance']?.toString() ?? '0') ?? 0.0;
        return sum + openingBalance;
      });
    });
  }

  Future<void> _fetchLedgerData2() async {
    List<Map<String, dynamic>> data = await DatabaseHelper.instance.queryFilteredRows(
      widget.fromDate,
      widget.toDate,
      widget.ledgerName ?? "",
    );

    // Calculate the total opening balance for filtered data
    setState(() {
      ledgerData = data;
      totalOpeningBalance = ledgerData.fold(0.0, (sum, item) {
        double openingBalance = double.tryParse(item['opening_balance']?.toString() ?? '0') ?? 0.0;
        return sum + openingBalance;
      });
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
              "Ledger Report",
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
            scrollDirection: Axis.vertical,
            child: Table(
              border: TableBorder.all(
                color: Colors.black,
                width: 1.0,
              ),
              columnWidths: {
                0: FixedColumnWidth(120), 
                1: FixedColumnWidth(120), 
                2: FixedColumnWidth(120),
                3: FixedColumnWidth(120),
                4: FixedColumnWidth(120),
                5: FixedColumnWidth(120),
                6: FixedColumnWidth(120),
                7: FixedColumnWidth(120),
                8: FixedColumnWidth(120),
                9: FixedColumnWidth(120),
                10: FixedColumnWidth(120),
              },
              children: [
                // Table Header Row
                TableRow(
                  children: [
                    _buildHeaderCell('Ledger Name'),
                    _buildHeaderCell('Address'),
                    _buildHeaderCell('Contact'),
                    _buildHeaderCell('Email'),
                    _buildHeaderCell('Tax No'),
                    _buildHeaderCell('Price Level'),
                    _buildHeaderCell('Balance'),
                    _buildHeaderCell('Opening Balance'),
                    _buildHeaderCell('Received Balance'),
                    _buildHeaderCell('Pay Amount'),
                    _buildHeaderCell('Under'),
                  ],
                ),
                // Data Rows
                ...ledgerData.map((data) {
                  return TableRow(
                    children: [
                      _buildDataCell(data['ledger_name'] ?? 'N/A'),
                      _buildDataCell(data['address'] ?? 'N/A'),
                      _buildDataCell(data['contact'] ?? 'N/A'),
                      _buildDataCell(data['mail'] ?? 'N/A'),
                      _buildDataCell(data['tax_no'] ?? 'N/A'),
                      _buildDataCell(data['price_level'] ?? 'N/A'),
                      _buildDataCell(data['balance']?.toString() ?? 'N/A'),
                      _buildDataCell(data['opening_balance']?.toString() ?? 'N/A'),
                      _buildDataCell(data['received_balance']?.toString() ?? 'N/A'),
                      _buildDataCell(data['pay_amount']?.toString() ?? 'N/A'),
                      _buildDataCell(data['under'] ?? 'N/A'),
                    ],
                  );
                }).toList(),
                // Total Row
                TableRow(
                  children: [
                    _buildDataCell(''),
                    _buildDataCell(''),
                    _buildDataCell(''),
                    _buildDataCell(''),
                    _buildDataCell(''),
                    _buildDataCell(''),
                    _buildDataCell2('Total'),
                    _buildDataCell2(totalOpeningBalance.toStringAsFixed(2)), // Display total opening balance
                    _buildDataCell(''),
                    _buildDataCell(''),
                    _buildDataCell(''),
                  ],
                ),
              ],
            ),
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
   Widget _buildDataCell2(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: getFonts(12, Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }
}
