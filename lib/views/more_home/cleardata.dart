import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stockDB.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/Home.dart';

class ClearDatabase extends StatefulWidget {
  const ClearDatabase({super.key});

  @override
  State<ClearDatabase> createState() => _ClearDatabaseState();
}

class _ClearDatabaseState extends State<ClearDatabase> {
  bool _isLoadingCompany = false;

  Future<void> _clearDatabase() async {
    setState(() {
      _isLoadingCompany = true;
    });

    try {
      await StockDatabaseHelper.instance.clearPregTable();
      await StockDatabaseHelper.instance.clearStockTable();
      await LedgerTransactionsDatabaseHelper.instance.clearPvinfo();
      await LedgerTransactionsDatabaseHelper.instance.clearPvperti();
      await LedgerTransactionsDatabaseHelper.instance.clearRvinfo();
      await LedgerTransactionsDatabaseHelper.instance.clearRvperti();
      await LedgerTransactionsDatabaseHelper.instance.clearledger();
      await LedgerTransactionsDatabaseHelper.instance.clearAcccTrans();
      Fluttertoast.showToast(
        msg: "Data Cleared Successfully!",
        
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to clear data: $e",
        
      );
    } finally {
      setState(() {
        _isLoadingCompany = false; 
      });
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
            onPressed: () => Navigator.push(context,MaterialPageRoute(builder: (context)=>HomePageERP())),
            icon: Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white, size: 20),
          ),
        ),
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight * 0.01),
            child: Text("Clear Database", style: appbarFonts(screenWidth * 0.04, Colors.white)),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight * 0.02),
            child: GestureDetector(
              onTap: () {},
              child: Icon(Icons.more_vert, color: Colors.white, size: screenHeight * 0.03),
            ),
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onTap: _clearDatabase,
          child: Container(
            height: screenHeight * 0.07,
            width: screenWidth * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: _isLoadingCompany ? Colors.grey : Appcolors().maincolor,
            ),
            child: Center(
              child: _isLoadingCompany
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Clear Data", style: getFonts(14, Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
