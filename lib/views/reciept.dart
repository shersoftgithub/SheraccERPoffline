import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sheraaccerpoff/models/paymant_model.dart';
import 'package:sheraaccerpoff/models/recipt_modal.dart';
import 'package:sheraaccerpoff/provider/sherprovider.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/LEDGER_DB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/accountTransactionDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/newLedgerDBhelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/payment_databsehelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/reciept_databasehelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_refer.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/more_home/settings.dart';
import 'package:sheraaccerpoff/views/newLedger.dart';

class Reciept extends StatefulWidget {
  const Reciept({super.key});

  @override
  State<Reciept> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<Reciept> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _narrationController = TextEditingController();
  
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _DiscountController = TextEditingController();
  final TextEditingController _TotalController = TextEditingController();
  final TextEditingController _cashAccController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _selectlnamesController = TextEditingController();
   List <String>_supplierSuggestions=[];
   @override
  void initState() {
    super.initState();
    _fetchfyData();
    _fetchSettings();
   // _fetchLedgerBalances();
   _fetchLedger();
   fetchData();
       _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _DiscountController.addListener(_calculateTotal);
    _amountController.addListener(_calculateTotal);
    _balanceController.addListener(_calculateTotal);
  }

  double _total = 0.0; 
 void _calculateTotal() {
    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final double discount = double.tryParse(_DiscountController.text) ?? 0.0;
    final double balance = double.tryParse(_balanceController.text) ?? 0.0;

    setState(() {
      _total = balance - amount - discount;
    });
  }

List settings=[];
 Future<void> _fetchSettings() async {
    try {
      List<Map<String, dynamic>> data = await SaleReferenceDatabaseHelper.instance.getAllsettings();
      print('Fetched stock data: $data');
      setState(() {
        settings = data;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
    }
  }

    List <String> names=[];

Future<void> _fetchLedger() async {
    List<String> cname = await LedgerTransactionsDatabaseHelper.instance.getAllNames();

  setState(() {
    names=cname;
  });
}
Future<void> _fetchLedgerDetails(String ledgerName) async {
  if (ledgerName.isNotEmpty) {
    Map<String, dynamic>? ledgerDetails = await LedgerTransactionsDatabaseHelper.instance.getLedgerDetailsByName(ledgerName);

    if (ledgerDetails != null) {
      setState(() {
        // Ensure the OpeningBalance is converted to a string
        final openingBalance = ledgerDetails['OpeningBalance'];
        _balanceController.text = openingBalance != null ? openingBalance.toString() : '';
      });
    } else {
      // Optionally clear the fields if no data found
      setState(() {
        _balanceController.clear();
      });
    }
  }
}


// List <String>LedgerPaymant = [];
//     Future<void> _fetchLedgerBalances() async {
//     List<Map<String, dynamic>> LedgerPaymant = await DatabaseHelper.instance.getAllLedgersWithBalances();
//     setState(() {
//       LedgerPaymant = LedgerPaymant;  
//     });
//   }
//     void _fetchBalanceForLedger(String selectedLedgerName) async {
//   DatabaseHelper dbHelper = DatabaseHelper.instance;
//   List<Map<String, dynamic>> ledgerData = await dbHelper.queryAllRows();
//   var selectedLedger = ledgerData.firstWhere(
//     (row) => row[DatabaseHelper.columnLedgerName] == selectedLedgerName,
//     orElse: () => {},
//   );

//   if (selectedLedger.isNotEmpty) {
//     double openingBalance = selectedLedger[DatabaseHelper.columnOpeningBalance] ?? 0.0;
//     double receivedBalance = selectedLedger[DatabaseHelper.columnReceivedBalance] ?? 0.0;
//     double remainingBalance = openingBalance;
//     setState(() {
//       _balanceController.text = remainingBalance.toStringAsFixed(2);
//     });
//   } else {
//     setState(() {
//       _balanceController.text = 'Ledger not found';
//     });
//   }
// }

List<String> cashAcc = [];

Future<void> fetchData() async {
  try {
    List<Map<String, dynamic>> cashAndBankData = await PV_DatabaseHelper.instance.fetchCaccount();
        cashAcc = cashAndBankData.map((row) {
      return row['AccountName'] as String; 
    }).toList();
    cashAcc.forEach((name) {
      print('Ledger Name: $name');
    });
  } catch (e) {
    print('Error fetching Cash and Bank data: $e');
  }
}

 Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

void _saveData() async {
  try {
    
      final db = await LedgerTransactionsDatabaseHelper.instance.database;

   final lastRow = await db.rawQuery(
  'SELECT Auto FROM Account_Transactions ORDER BY Auto DESC LIMIT 1'
);
double newEntryNo = 1.0; 

if (lastRow.isNotEmpty) {
    final lastEntryNo = double.tryParse(lastRow.first['atEntryno']?.toString() ?? '0') ?? 0.0; // FIXED: Correct key lookup

    print("Fetched lastAuto: lastEntryNo: $lastEntryNo"); // Debugging

   
    newEntryNo = lastEntryNo + 1.0; // Ensure increment as double
  }
    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final double balance = double.tryParse(_balanceController.text) ?? 0.0;
    final double discount = double.tryParse(_DiscountController.text) ?? 0.0;
    final double total = balance - amount - discount;

    final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance
        .getLedgerDetailsByName(_selectlnamesController.text);

    final String ledCode = ledgerDetails?['LedId'] ?? 'Unknown';
int selectedFyID = 0; 
String selectedDate = _dateController.text;
for (var fyRecord in fy) {
  DateTime fromDate = DateTime.parse(fyRecord['Frmdate'].toString());  
  DateTime toDate = DateTime.parse(fyRecord['Todate'].toString());  
  DateTime selected = DateTime.parse(selectedDate);  

  if (selected.isAfter(fromDate) && selected.isBefore(toDate)) {
    selectedFyID = int.tryParse(fyRecord['Fyid'].toString()) ?? 0;  
    break;  
  }
}
    final transactionData = {
      'atDate': _dateController.text.isNotEmpty ? _dateController.text : 'Unknown',
      'atLedCode': ledCode,
      'atDebitAmount': amount,
      'atCreditAmount': total,
      'atType': 'RECEIPT',
      'Caccount': _cashAccController.text,
      'atDiscount': _DiscountController.text,
      'atNaration': _narrationController.text,
      'atLedName': _selectlnamesController.text,
      'atEntryno': newEntryNo,
      'atFyID': selectedFyID
    };

    await LedgerTransactionsDatabaseHelper.instance.insertAccTrans(transactionData);

    if (ledgerDetails != null) {
      final double currentBalance = ledgerDetails['OpeningBalance'] as double? ?? 0.0;
      final double updatedBalance = currentBalance - amount - discount;

      await LedgerTransactionsDatabaseHelper.instance.updateLedgerBalance(
        ledCode,
        updatedBalance,
      );
    } else {
      print('Ledger not found for name: ${_selectlnamesController.text}');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved successfully')),
    );
    setState(() {
      _amountController.clear();
      _balanceController.clear();
      _DiscountController.clear();
      _dateController.clear();
      _cashAccController.clear();
      _selectlnamesController.clear();
      _narrationController.clear();
    });
  } catch (e) {
    print('Error while saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: $e')),
    );
  }
}

void _saveDataRV_Perticular() async {
  try {
    final db = await RV_DatabaseHelper.instance.database;

    final lastDateRow = await db.rawQuery(
      'SELECT ddate FROM RV_Particulars ORDER BY ddate DESC LIMIT 1'
    );

    int newAuto = 1;
    double newEntryNo = 1.0;

    if (lastDateRow.isNotEmpty) {
      final lastDate = lastDateRow.first['ddate']?.toString() ?? '';

      try {
        DateTime.parse(lastDate);
        
        final lastRow = await db.rawQuery(
          'SELECT auto, EntryNo FROM RV_Particulars WHERE ddate = ? ORDER BY auto DESC LIMIT 1',
          [lastDate]
        );

        if (lastRow.isNotEmpty) {
          final lastAuto = int.tryParse(lastRow.first['auto']?.toString() ?? '0') ?? 0;
          final lastEntryNo = double.tryParse(lastRow.first['EntryNo']?.toString() ?? '0') ?? 0.0;

          newAuto = lastAuto + 1;
          newEntryNo = lastEntryNo + 1.0;
        }
      } catch (e) {
        print('Invalid date format in database: $lastDate');
      }
    }

    print("Generated newAuto: $newAuto, newEntryNo: $newEntryNo");

    String selectedDate = _dateController.text.trim();
    try {
      DateTime.parse(selectedDate);
    } catch (e) {
      print('Invalid date format: $selectedDate');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid date format. Please enter YYYY-MM-DD')),
      );
      return;
    }

    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final double balance = double.tryParse(_balanceController.text) ?? 0.0;
    final double discount = double.tryParse(_DiscountController.text) ?? 0.0;
    final double total = balance - amount - discount;

    final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance
        .getLedgerDetailsByName(_selectlnamesController.text);

    final String ledCode = ledgerDetails?['LedId'] ?? 'Unknown';
    int selectedFyID = 0;

    for (var fyRecord in fy) {
      try {
        DateTime fromDate = DateTime.parse(fyRecord['Frmdate'].toString());
        DateTime toDate = DateTime.parse(fyRecord['Todate'].toString());
        DateTime selected = DateTime.parse(selectedDate);

        if (selected.isAfter(fromDate) && selected.isBefore(toDate)) {
          selectedFyID = int.tryParse(fyRecord['Fyid'].toString()) ?? 0;
          break;
        }
      } catch (e) {
        print('Invalid date format in fyRecord: $fyRecord');
      }
    }

    final transactionData = {
      'auto': newAuto.toString(),
      'EntryNo': newEntryNo.toString(),
      'ddate': selectedDate,
      'Amount': amount,
      'Total': total,
      'CashAccount': _cashAccController.text,
      'Discount': _DiscountController.text,
      'Narration': _narrationController.text,
      'Name': ledCode,
      'FyID': selectedFyID,
      'FrmID': 2,
    };

    await RV_DatabaseHelper.instance.insertRVParticulars(transactionData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved successfully')),
    );

    setState(() {
      _amountController.clear();
      _balanceController.clear();
      _DiscountController.clear();
      _dateController.clear();
      _cashAccController.clear();
      _selectlnamesController.clear();
      _narrationController.clear();
    });
  } catch (e) {
    print('Error while saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: $e')),
    );
  }
}


List fy=[];
 Future<void> _fetchfyData() async {
    try {
            List<Map<String, dynamic>> data = await SaleReferenceDatabaseHelper.instance.getAllfyid();
      print('Fetched stock data: $data');
      setState(() {
      fy   = data;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
    }
  }

void _saveDataRV_Information() async {
  try {
    final db = await RV_DatabaseHelper.instance.database;

    final lastRow = await db.rawQuery(
      'SELECT * FROM RV_Information ORDER BY RealEntryNo DESC LIMIT 1'
    );

    int newEntryNo = 1;
    String lastTakeUser = '';
    int lastLocation = 0;
    int lastProject = 0;
    int lastSalesMan = 0;
    int lastApp = 0;
    int lastTransferStatus = 0;
    int lastFyID = 0;
    int lastFrmID = 0;
    int lastPviCurrency = 0;
    int lastPviCurrencyValue = 0;

    if (lastRow.isNotEmpty) {
      final lastData = lastRow.first;

      newEntryNo = int.tryParse(lastData['EntryNo'].toString()) ??  1;
lastLocation = int.tryParse(lastData['Location'].toString()) ?? 0;
lastProject = int.tryParse(lastData['Project'].toString()) ?? 0;
lastSalesMan = int.tryParse(lastData['SalesMan'].toString()) ?? 0;
lastApp = int.tryParse(lastData['app'].toString()) ?? 0;
lastTransferStatus = int.tryParse(lastData['Transfer_Status'].toString()) ?? 0;
lastFyID = int.tryParse(lastData['FyID'].toString()) ?? 0;
lastFrmID = int.tryParse(lastData['FrmID'].toString()) ?? 0;
lastPviCurrency = int.tryParse(lastData['pviCurrency'].toString()) ?? 0;
lastPviCurrencyValue = int.tryParse(lastData['pviCurrencyValue'].toString()) ?? 0;

    }

    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final double balance = double.tryParse(_balanceController.text) ?? 0.0;
    final double discount = double.tryParse(_DiscountController.text) ?? 0.0;
    final double total = balance - amount - discount;

    final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance
        .getLedgerDetailsByName(_selectlnamesController.text);

    final String ledCode = ledgerDetails?['LedId'] ?? 'Unknown';
 final newEntryNo2=newEntryNo+1;
  String selectedDate = _dateController.text;
int selectedFyID = 0; 

for (var fyRecord in fy) {
  DateTime fromDate = DateTime.parse(fyRecord['Frmdate'].toString());  
  DateTime toDate = DateTime.parse(fyRecord['Todate'].toString());  
  DateTime selected = DateTime.parse(selectedDate);  

  if (selected.isAfter(fromDate) && selected.isBefore(toDate)) {
    selectedFyID = int.tryParse(fyRecord['Fyid'].toString()) ?? 0;  
    break;  
  }
}
    final transactionData = {
      'DDATE': _dateController.text.isNotEmpty ? _dateController.text : 'Unknown',
      'AMOUNT': amount,
      'Discount': discount,
      'Total': total,
      'DEBITACCOUNT': ledCode,
      'takeuser': lastTakeUser,  
      'Location': lastLocation, 
      'Project': lastProject,    
      'SalesMan': lastSalesMan,  
      'MonthDate': _dateController.text.isNotEmpty ? _dateController.text : 'Unknown',
      'app': lastApp,            
      'Transfer_Status': lastTransferStatus, 
      'FyID': selectedFyID,          
      'EntryNo': newEntryNo2,     
      'FrmID': lastFrmID,        
      'pviCurrency': lastPviCurrency,  
      'pviCurrencyValue': lastPviCurrencyValue, 
      'pdate': _dateController.text.isNotEmpty ? _dateController.text : 'Unknown',
    };

    await RV_DatabaseHelper.instance.insertRVInformation(transactionData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved successfully')),
    );

    setState(() {
      _amountController.clear();
      _balanceController.clear();
      _DiscountController.clear();
      _dateController.clear();
      _cashAccController.clear();
      _selectlnamesController.clear();
      _narrationController.clear();
    });
  } catch (e) {
    print('Error while saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: $e')),
    );
  }
}

 bool _isKeyLockSaleRateEnabled() {
  return settings.any((element) =>
      element['Name'] == 'KEY MULTI RV-PV' && element['Status'] == '1');
}

bool _isKeyLockCashAccSelected = false;

void _settingCashAccChanged(String value) {
  bool isKeyLock = settings.any((element) =>
      element['Name'] == 'KEY LOCK CASH ACCOUNT' && element['Status'] == '1');

  if (isKeyLock && value == 'KEY LOCK CASH ACCOUNT') {
    setState(() {
      _isKeyLockCashAccSelected = true;
      _cashAccController.text = value; 
    });
  } else if (!_isKeyLockCashAccSelected) {
    _cashAccController.text = value;
  }
}
 List<Map<String, dynamic>> temporaryData = [];
 void _addDataToTemporaryList() {
    if (_amountController.text.isNotEmpty && _DiscountController.text.isNotEmpty) {
      setState(() {
        temporaryData.add({
          'date':_dateController.text,
          'name': _selectlnamesController.text,
          'total': _total.toString(),
          'amount': _amountController.text,
          'discount': _DiscountController.text,
          'narration': _narrationController.text,
        });
      });

      _amountController.clear();
      _DiscountController.clear();
      _narrationController.clear();
      _TotalController.clear();
      _selectlnamesController.clear();
    }
  }

  void _saveDataRV_Perticular2() async {
  try {
    final db = await PV_DatabaseHelper.instance.database;

    final lastDateRow = await db.rawQuery(
      'SELECT ddate FROM RV_Particulars ORDER BY ddate DESC LIMIT 1'
    );

    int newAuto = 1;
    double newEntryNo = 1.0;

    if (lastDateRow.isNotEmpty) {
      final lastDate = lastDateRow.first['ddate']?.toString() ?? '';

      final lastRow = await db.rawQuery(
        'SELECT auto, EntryNo FROM RV_Particulars WHERE ddate = ? ORDER BY auto DESC LIMIT 1',
        [lastDate]
      );

      if (lastRow.isNotEmpty) {
        final lastAuto = int.tryParse(lastRow.first['auto']?.toString() ?? '0') ?? 0;
        final lastEntryNo = double.tryParse(lastRow.first['EntryNo']?.toString() ?? '0') ?? 0.0;

        newAuto = lastAuto + 1;
        newEntryNo = lastEntryNo + 1.0;
      }
    }

    final batch = db.batch(); // Start a batch transaction

    for (var item in temporaryData) {
      final double amount = double.tryParse(item['amount'].toString()) ?? 0.0;
      final double discount = double.tryParse(item['discount'].toString()) ?? 0.0;
      final double total = amount - discount;

      final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance
          .getLedgerDetailsByName(item['name'].toString());

      final String ledCode = ledgerDetails?['LedId'] ?? 'Unknown';
      String selectedDate = item['date'].toString();
      int selectedFyID = 0;

      for (var fyRecord in fy) {
        DateTime fromDate = DateTime.parse(fyRecord['Frmdate'].toString());
        DateTime toDate = DateTime.parse(fyRecord['Todate'].toString());
        DateTime selected = DateTime.parse(selectedDate);

        if (selected.isAfter(fromDate) && selected.isBefore(toDate)) {
          selectedFyID = int.tryParse(fyRecord['Fyid'].toString()) ?? 0;
          break;
        }
      }

      final transactionData = {
        'auto': newAuto.toString(),
        'EntryNo': newEntryNo.toString(),
        'ddate': selectedDate.isNotEmpty ? selectedDate : 'Unknown',
        'Amount':item['amt'].toString(),
        'Total': item['total'].toString(),
        'CashAccount': _cashAccController.text,
        'Discount': item['discount'].toString(),
        'Narration': item['narration'].toString(),
        'Name': ledCode,
        'FyID': selectedFyID,
        'FrmID': 1,
      };

      batch.insert('RV_Particulars', transactionData);

      newAuto++; // Increment auto for the next record
      newEntryNo++; // Increment entry number for the next record
    }

    await batch.commit(noResult: true); // Execute batch insert

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved successfully'))
    );

    setState(() {
      temporaryData.clear(); // Clear temporary list after saving
      _amountController.clear();
      _balanceController.clear();
      _DiscountController.clear();
      _dateController.clear();
      _cashAccController.clear();
      _selectlnamesController.clear();
      _narrationController.clear();
    });
  } catch (e) {
    print('Error while saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: $e'))
    );
  }
}
void _saveDataRV_Information2() async {
  try {
    final db = await PV_DatabaseHelper.instance.database;

    final lastRow = await db.rawQuery(
      'SELECT * FROM RV_Particulars ORDER BY RealEntryNo DESC LIMIT 1'
    );

    int newEntryNo = 1;
    String lastTakeUser = '';
    int lastLocation = 0;
    int lastProject = 0;
    int lastSalesMan = 0;
    int lastApp = 0;
    int lastTransferStatus = 0;
    int lastFyID = 0;
    int lastFrmID = 0;
    int lastPviCurrency = 0;
    int lastPviCurrencyValue = 0;

    if (lastRow.isNotEmpty) {
      final lastData = lastRow.first;

      newEntryNo = (lastData['RealEntryNo'] as int? ?? 0) + 1;  // Increment EntryNo correctly
      lastTakeUser = lastData['takeuser'] as String? ?? '';
      lastLocation = lastData['Location'] as int? ?? 0;
      lastProject = lastData['Project'] as int? ?? 0;
      lastSalesMan = lastData['SalesMan'] as int? ?? 0;
      lastApp = lastData['app'] as int? ?? 0;
      lastTransferStatus = lastData['Transfer_Status'] as int? ?? 0;
      lastFyID = lastData['FyID'] as int? ?? 0;
      lastFrmID = lastData['FrmID'] as int? ?? 0;
      lastPviCurrency = lastData['pviCurrency'] as int? ?? 0;
      lastPviCurrencyValue = lastData['pviCurrencyValue'] as int? ?? 0;
    }

    // Use a batch operation for efficiency
    final batch = db.batch();

    for (var entry in temporaryData) {
      final double amount = double.tryParse(entry['amount'].toString()) ?? 0.0;
      final double discount = double.tryParse(entry['discount'].toString()) ?? 0.0;
      final double total = double.tryParse(entry['total'].toString()) ?? 0.0;

      final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance
          .getLedgerDetailsByName(entry['name'].toString());

      final String ledCode = ledgerDetails?['LedId'] ?? 'Unknown';

      String selectedDate = entry['date'] ?? '';
      int selectedFyID = 0;

      for (var fyRecord in fy) {
        DateTime fromDate = DateTime.parse(fyRecord['Frmdate'].toString());
        DateTime toDate = DateTime.parse(fyRecord['Todate'].toString());
        DateTime selected = DateTime.parse(selectedDate);

        if (selected.isAfter(fromDate) && selected.isBefore(toDate)) {
          selectedFyID = int.tryParse(fyRecord['Fyid'].toString()) ?? 0;
          break;
        }
      }

      final transactionData = {
        'DDATE': selectedDate.isNotEmpty ? selectedDate : 'Unknown',
        'AMOUNT': amount,
        'Discount': discount,
        'Total': total,
        'CreditAccount': ledCode,
        'takeuser': lastTakeUser,
        'Location': lastLocation,
        'Project': lastProject,
        'SalesMan': lastSalesMan,
        'MonthDate': selectedDate.isNotEmpty ? selectedDate : 'Unknown',
        'app': lastApp,
        'Transfer_Status': lastTransferStatus,
        'FyID': selectedFyID,
        'EntryNo': newEntryNo++,  
        'FrmID': lastFrmID,
        'pviCurrency': lastPviCurrency,
        'pviCurrencyValue': lastPviCurrencyValue,
        'pdate': selectedDate.isNotEmpty ? selectedDate : 'Unknown',
      };

      batch.insert('RV_Particulars', transactionData);
    }

    await batch.commit(noResult: true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data saved successfully!')),
    );

    setState(() {
      temporaryData.clear();
    });

  } catch (e) {
    print('Error while saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
double total = (double.tryParse(_balanceController.text) ?? 0.0) - (double.tryParse(_amountController.text) ?? 0.0);
print('Total: $total');
double _TotalController=_total;
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
            padding: EdgeInsets.only(top: screenHeight * 0.02,right: screenHeight*0.01),
            child: Text(
              "Reciept",
              style: appbarFonts(screenWidth * 0.04, Colors.white),
            ),
          ),
        ),
        actions: [
          //   Padding(
          //   padding: EdgeInsets.only(top: screenHeight * 0.020, right: screenHeight*0.02),
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Settings()));
          //     },
          //     child: SizedBox(
          //       width: 20,
          //       height: 20,
          //       child: Image.asset("assets/images/setting (2).png"),
          //     ),
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight*0.02),
            child: GestureDetector(
              onTap: () {

                   if (_isKeyLockSaleRateEnabled()) {
             _saveDataRV_Perticular2();
            _saveDataRV_Information2();
              } else {
                 _saveData();
                _saveDataRV_Perticular();
                _saveDataRV_Information();
              }
              
              },
              child: SizedBox(
                width: 20,
                height: 20,
                child: Image.asset("assets/images/save-instagram.png"),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: screenHeight*0.02,),
        Container(
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                 Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
                
                'Cash Account',
                style: formFonts(14, Colors.black),
              ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            height: screenHeight * 0.042, 
              width: screenWidth * 0.42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
            ),
            child:  SingleChildScrollView(
             child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 5),
               child: EasyAutocomplete(
                   controller: _cashAccController,
                   suggestions: cashAcc,
                      inputTextStyle: getFontsinput(14, Colors.black),
                  
                   decoration: InputDecoration(
                     border: InputBorder.none,
                     contentPadding: EdgeInsets.only(bottom: 20)
                   ),
                   suggestionBackgroundColor: Appcolors().Scfold,
                 ),
             ),
           ),
          ),
        ],
      ),
    ),
              Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
                
                'Date',
                style: formFonts(14, Colors.black),
              ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            padding: EdgeInsets.symmetric(vertical: 3),
                 height: screenHeight * 0.042, 
              width: screenWidth * 0.42,
                                    decoration: BoxDecoration(
                                       border: Border.all(color: Appcolors().searchTextcolor),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child:  TextField(
                                      style: getFontsinput(14, Colors.black),
           readOnly: true,
          controller: _dateController,
           decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              ),
        ),
                                  ),
        ],
      ),
    ),
           
     
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
      Container(
        padding: EdgeInsets.symmetric(horizontal: screenHeight*0.025),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Select Ledger Name",
                style: formFonts(14, Colors.black),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            height: screenHeight * 0.06,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: Row(
                children: [
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: EasyAutocomplete(
                      suggestionBackgroundColor: Appcolors().Scfold,
                        controller: _selectlnamesController,
                        suggestions: names,
                          inputTextStyle: getFontsinput(14, Colors.black), 
                        onSubmitted: (value) {
                _fetchLedgerDetails(value); 
              },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
   
     GestureDetector(
        onTap: () {
          Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Newledger()));
        },
        child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.03),
          child: Container(
            height: screenHeight * 0.05,
            width: screenWidth * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color(0xFF0A1EBE),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add,color: Colors.white,size: 17,),
                  Text(
                    "Add New Ledger",
                    style: getFonts(14, Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    
    Padding(
      padding: const EdgeInsets.only(right: 190),
      child: Container(padding: EdgeInsets.symmetric(horizontal: screenHeight*0.02),
        child: Row(children: [
          Text("Balance : ",style: getFonts(14, Appcolors().maincolor),),
          Text("${_balanceController.text}",style: getFonts(14, Colors.black),)
        ],),
      ),
    ),
    SizedBox(height: screenHeight * 0.02),
    Container(
      padding: EdgeInsets.symmetric(horizontal: screenHeight*0.025),
      child: Column(children: [
        _paymentField("Amount", _amountController,screenWidth, screenHeight),
        SizedBox(height: screenHeight * 0.01),
        _paymentField("Discount",_DiscountController, screenWidth, screenHeight),
        SizedBox(height: screenHeight * 0.02),
         Padding(
      padding: const EdgeInsets.only(right: 220),
      child: Container(
        child: Row(
          children: [
            Text("Total : ",style: getFonts(16, Appcolors().maincolor),),
            Text("${_TotalController.toString()}",style: getFonts(16, Colors.black),)
          ],
        ),
      ),
    ),
      SizedBox(height: screenHeight * 0.02),
            _paymentField("Narration",_narrationController,screenWidth, screenHeight),

             SizedBox(height: screenHeight*0.01,),
     if (_isKeyLockSaleRateEnabled())
            Padding(
              padding: EdgeInsets.all(screenHeight * 0.03),
              child: 
              GestureDetector(
                onTap: () {
                  _addDataToTemporaryList();
                },
                child: Container(
                  height: screenHeight * 0.05,
                  width: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color(0xFF0A1EBE),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 17),
                        Text(
                          "Add",
                          style: getFonts(14, Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            ListView.builder(
              shrinkWrap: true, // To avoid full screen usage
              itemCount: temporaryData.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal:15),
                  child: Card(
                    color: Color.fromRGBO(225, 240, 255, 1),
                    child: ListTile(
                      title: Text("Date: ${temporaryData[index]['date']}  ||   LedgerName : ${temporaryData[index]['name']}  ||  Discount: ${temporaryData[index]['discount']}  ||  Total: ${temporaryData[index]['total']}",style: getFonts(12, Colors.black45),),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: screenHeight*0.01,)
      ],),
    )
          ],
        ),
      ),
      
    );
  }

  Widget _paymentField(String label, TextEditingController controller, double screenWidth, double screenHeight) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: formFonts(14, Colors.black),
              ),
             
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(padding: EdgeInsets.symmetric(vertical: 3),
            height: screenHeight * 0.06,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: Row(
                children: [
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: TextFormField(
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.number,
                      style: getFontsinput(14, Colors.black),
                      controller: controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter $label';
                        }
                        return null;
                      },
                      obscureText: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: screenHeight * 0.01),
                        
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //  void _showCreateItemDialog(String CassAcc,) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(backgroundColor: Appcolors().Scfold,
  //         title: Text('Create a new item'),
  //         content: Text('Item "$CassAcc" does not exist. Would you like to create it?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('Cancel',style: TextStyle(color: Appcolors().maincolor),),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               final creditsale = PaymentModel(date: "",
  //                cashAccount: CassAcc,
  //                 ledgerName: "", 
  //                 balance: 0.0,
  //                  amount: 0.0,
  //                   discount: 0.0, 
  //                   total: 0.0,
  //                    narration: "",
  //                    atType: "");
  //               await PaymentDatabaseHelper.instance.insert(creditsale.toMap());
  //               Navigator.of(context).pop();  
  //               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item created and saved')));
  //               _fetchCashAcc();
  //             },
  //             child: Text('Create',style: TextStyle(color: Appcolors().maincolor),),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
