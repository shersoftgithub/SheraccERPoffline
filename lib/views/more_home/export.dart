import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/more_home/update.dart';

class Import extends StatefulWidget {
  const Import({super.key});

  @override
  State<Import> createState() => _ImportState();
}

class _ImportState extends State<Import> {
  bool _isLoading = false;
  Future<void> backupAndSyncData() async {
    await LedgerTransactionsDatabaseHelper.instance.syncLedgerNamesToMSSQL();
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
            padding: EdgeInsets.only(
              top: screenHeight * 0.02,
              right: screenHeight * 0.01,
            ),
            child: Text(
              "Export Data",
              style: appbarFonts(screenWidth * 0.04, Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.02,
              right: screenHeight * 0.02,
            ),
            child: GestureDetector(
              onTap: () {

              },
              child: Icon(
                Icons.more_vert,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
              onTap: () {   
              Update update = Update();
          // update.syncRVInformationToMSSQL();
         // update.syncRVParticularsToMSSQL();
         //update.syncPVInformationToMSSQL();
         //update.syncPVParticularsToMSSQL();
         update.syncSalesParticularsToMSSQL();
        update.syncSalesInformationToMSSQL2();
       // update.syncAccount_transactionToMSSQL();
        // update.syncStockQtyToMSSQL();
        //backupAndSyncData();
              },
              child:  Container(
            height: screenHeight * 0.07,
            width: screenWidth * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Appcolors().maincolor,
            ),
            child: Center(
              child: _isLoading
                  ? CircularProgressIndicator() // Show loading indicator when _isLoading is true
                  : Text(
                      "Export Data",
                      style: getFonts(14, Colors.white),
                    ),
            ),
                  ),
            ),
      ),
    );
  }
}