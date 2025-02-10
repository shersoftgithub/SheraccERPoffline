
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/models/salescredit_modal.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/options.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_info2.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_information.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_refer.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/salesDBHelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stockDB.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/Home.dart';
import 'package:sheraaccerpoff/views/addPaymant.dart';
import 'package:sheraaccerpoff/views/addpayment2.dart';
import 'package:sheraaccerpoff/views/newLedger.dart';

class SalesOrder extends StatefulWidget {
  final SalesCredit? salesCredit;
  final SalesCredit? salesDebit;
final List<Map<String, String>>? itemDetails;
final double? discPerc; 
final double? discnt;
final double? net;
final double? tot;
final double? tax;
  const SalesOrder({super.key, this.salesCredit,this.salesDebit,this.itemDetails,this.discPerc,this.discnt,this.net,this.tot,this.tax});
  @override
  State<SalesOrder> createState() => _SalesOrderState();
}

class _SalesOrderState extends State<SalesOrder> {
  final TextEditingController _InvoicenoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _CustomerController = TextEditingController();
  bool isCustomerSelected = false;
  final TextEditingController _phonenoController = TextEditingController();
  final TextEditingController _totalamtController = TextEditingController();
  final TextEditingController _salerateController = TextEditingController();

  final TextEditingController _CashphonenoController = TextEditingController();
  final TextEditingController _CashtotalamtController = TextEditingController();
  final TextEditingController _CashsalerateController = TextEditingController();
  final TextEditingController _billnameController = TextEditingController();
  bool isCreditSelected = true;
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
    @override
  void initState() {
    super.initState();
    fetch_options();
    _fetchLedger();
    _fetchLastInvoiceId();
    _fetchfyData();
   
   _InvoicenoController.text = ''; 
    _dateController.text = '';      
    _salerateController.text = '';  
    _CustomerController.text = '';
    _phonenoController.text = '';
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
   @override
  void dispose() {
    super.dispose();
    _InvoicenoController.dispose();
    _dateController.dispose();
    _salerateController.dispose();
    _CustomerController.dispose();
    _phonenoController.dispose();
    _totalamtController.dispose();
  }
    optionsDBHelper dbHelper = optionsDBHelper();
     List<Map<String, dynamic>> todayItems = [];


    List<String> salesrate = [];
    Future<void>fetch_options()async{
      salesrate = await dbHelper.getOptionsByType('price_level');
      setState(() {
        
      });
    }
   List<int> ledgerIds = [];
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
       // _InvoicenoController.text = ledgerDetails['LedId'] ?? '';
        _phonenoController.text = ledgerDetails['Mobile'] ?? '';
      });
    } else {
      setState(() {
       // _InvoicenoController.clear();
        _phonenoController.clear();
      });
    }
  }
}


int nextInvoiceId = 0; 
Future<void> _fetchLastInvoiceId() async {
  List<int> ledgerIds = await SaleDatabaseHelper.instance.getAllLedgerIds();
  setState(() {
    if (ledgerIds.isNotEmpty) {
      nextInvoiceId = ledgerIds.last + 1;  
    } else {
      nextInvoiceId = 1;  
    }
  });
}
  void onSaleRateSelected(String value) {
    print('Selected Supplier: $value');
   
    _salerateController.text = value;
    _CustomerController.text=value;
  }
  void onSelected(String value) {
    print('Selected Supplier: $value');
       _CustomerController.text=value;
  }

// void _fetchInvoiceData(int ledgerId) async {
//   DatabaseHelper dbHelper = DatabaseHelper.instance;
  
//   List<Map<String, dynamic>> ledgerData = await dbHelper.queryAllRows();
  
//   var selectedLedger = ledgerData.firstWhere(
//     (row) => row[DatabaseHelper.columnId] == ledgerId,
//     orElse: () => {},
//   );
  
//   if (selectedLedger.isNotEmpty) {
//     setState(() {
//             _CustomerController.text = selectedLedger[DatabaseHelper.columnLedgerName].toString();
//       _phonenoController.text = selectedLedger[DatabaseHelper.columnContact].toString();
//     });
//   }
// }

// void _fetchName_Data(String name) async {
//   DatabaseHelper dbHelper = DatabaseHelper.instance;
//   List<Map<String, dynamic>> ledgerData = await dbHelper.queryAllRows();
  
//   var selectedLedger = ledgerData.firstWhere(
//     (row) => row[DatabaseHelper.columnLedgerName] == name,
//     orElse: () => {},
//   );
  
//   if (selectedLedger.isNotEmpty) {
//     setState(() {
//             _InvoicenoController.text = selectedLedger[DatabaseHelper.columnId].toString();
//       _phonenoController.text = selectedLedger[DatabaseHelper.columnContact].toString();
//     });
//   }
// }
 int newinno = 1;  
  void invoice() async {
    final db = await SalesInformationDatabaseHelper2.instance.database;
    final lastRow = await db.rawQuery(
      'SELECT * FROM Sales_Information ORDER BY RealEntryNo DESC LIMIT 1',
    );
  
    int newAuto = 1;
    if (lastRow.isNotEmpty) {
      final lastData = lastRow.first;
      newAuto = (lastData['InvoiceNo'] as num? ?? 0).toInt();
    }    
    final newinno = newAuto + 1; 
    
    setState(() {
      this.newinno = newinno;
    });
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
void _saveData2() async {
  try {
final double finalAmt = widget.salesCredit?.totalAmt ?? 0.0;  
//final double dicount = widget.salesCredit?. ?? 0.0;   

    final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance
        .getLedgerDetailsByName(_CustomerController.text);

    final String ledCode = ledgerDetails?['LedId'] ?? 'Unknown';
    final double op = ledgerDetails?['OpeningBalance']?? '';
    final double creditamt = op - finalAmt;
    final transactionData = {
      'atDate': _dateController.text.isNotEmpty ? _dateController.text : 'Unknown',
      'atLedCode': ledCode,
      'atDebitAmount': finalAmt,
    'atCreditAmount': creditamt,
      'atType': 'SALE',
      'Caccount': _salerateController.text,
      //'atDiscount':,
      //'atNaration': _narrationController.text,
      'atLedName': _CustomerController.text,
    };

    await LedgerTransactionsDatabaseHelper.instance.insertAccTrans(transactionData);

    if (ledgerDetails != null) {
      final double currentBalance = ledgerDetails['OpeningBalance'] as double? ?? 0.0;
      final double updatedBalance = creditamt;

      await LedgerTransactionsDatabaseHelper.instance.updateLedgerBalance(
        ledCode,
        updatedBalance,
      );
    } else {
      print('Ledger not found for name: ${_CustomerController.text}');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved successfully')),
    );
    setState(() {
      
    });
  } catch (e) {
    print('Error while saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: $e')),
    );
  }
}

void _saveDataSaleinfor() async {
  try {
final double finalAmt = widget.salesCredit?.totalAmt ?? 0.0;  
// final double discount = widget.salesCredit?.discount ?? 0.0;  

    final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance
        .getLedgerDetailsByName(_CustomerController.text);

    final String ledCode = ledgerDetails?['LedId'] ?? 'Unknown';
    final transactionData = {
      'InvoiceNo': _InvoicenoController.text,
      'DDate':_dateController.text,
      'Customer': ledCode,
    'Toname': _CustomerController.text,
       'Discount': 0.00, 
      'NetAmount': finalAmt,
      
      'Total': finalAmt,
      'TotalQty': _CustomerController.text,
    };

    await SalesInformationDatabaseHelper.instance.insertSale(transactionData);

    if (ledgerDetails != null) {

    
    } else {
      print('Ledger not found for name: ${_CustomerController.text}');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved successfully')),
    );
    setState(() {
      
    });
  } catch (e) {
    print('Error while saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: $e')),
    );
  }
}
String _convertToSQLDate(String inputDate) {
  try {
    DateTime parsedDate;

    if (inputDate.contains("/")) {
      parsedDate = DateFormat("dd/MM/yyyy").parse(inputDate);
    } else if (inputDate.contains("-")) {
      parsedDate = DateFormat("yyyy-MM-dd").parse(inputDate);
    } else {
      return 'NULL'; // Return NULL for invalid formats
    }

    // Convert to MSSQL expected format: 'yyyy-MM-dd HH:mm:ss'
    return "'${DateFormat("yyyy-MM-dd HH:mm:ss").format(parsedDate)}'";
  } catch (e) {
    print("⚠️ Date conversion error: $e for input: $inputDate");
    return 'NULL'; // Handle invalid date values safely
  }
}



void _saveDataSaleinfor22() async {
  try {
     final db = await SalesInformationDatabaseHelper2.instance.database;
     final lastRow = await db.rawQuery(
      'SELECT * FROM Sales_Information ORDER BY RealEntryNo DESC LIMIT 1'
    );
    int newAuto = 1;
    int newentryno=1;
    String DDate=''; 
    String btime=''; 
    String ddate1=''; 
    String despatchdate=''; 
    String receiptDate=''; 
 

      if (lastRow.isNotEmpty) {
      final lastData = lastRow.first;
newAuto = (lastData['RealEntryNo'] as int? ?? 0) + 1;
      newentryno = (lastData['EntryNo'] as int? ?? 0) + 1;
       DDate = lastData['DDate'] as String? ?? '';
      btime =  lastData['BTime'] as String? ?? '';
      ddate1 = lastData['ddate1'] as String? ?? '';
      despatchdate = lastData['despatchdate'] as String? ?? '';
      receiptDate = lastData['receiptDate'] as String? ?? '';
    }
    final double finalAmt = widget.salesCredit?.totalAmt ?? 0.0;
    final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance
        .getLedgerDetailsByName(_CustomerController.text);
final String add1 = ledgerDetails?['add1'] ?? 'Unknown';
final String add2 = ledgerDetails?['add2'] ?? 'Unknown';
final String add3 = ledgerDetails?['add3'] ?? 'Unknown';
final String add4 = ledgerDetails?['add4'] ?? 'Unknown';
    if (ledgerDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ledger not found for customer: ${_CustomerController.text}')),
      );
      return;
    }

    final String ledCode = ledgerDetails['LedId'] ?? '';
    if (_InvoicenoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invoice number is required!')),
      );
      return;
    }
    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Date is required!')),
      );
      return;
    }
    final stockDetails = await StockDatabaseHelper.instance
        .getStockDetailsByName(widget.salesCredit!.itemName);
        final String itemcode = stockDetails?['itemcode'] ?? 'Unknown';
    
    final stocksaleDetails = await SaleReferenceDatabaseHelper.instance
        .getStockSaleDetailsByName(itemcode);
        final unitsaleDetails = await SaleReferenceDatabaseHelper.instance
        .getStockunitDetailsByName(itemcode);
final cgst = (widget.tax!) / 2;
final sgst = (widget.tax!) / 2;
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
      'RealEntryNo': newAuto, 
      'EntryNo': newentryno, 
      'InvoiceNo': _InvoicenoController.text,
      'DDate':_dateController.text,
      'BTime':_dateController.text,
      'Customer': ledCode,
      'Add1': add1, 
      'Add2': add2,
      'Toname': _CustomerController.text,
      'TaxType': 'GST', 
      'GrossValue': finalAmt,
      'Discount': widget.discnt,
      'NetAmount': widget.net,
      'cess': 0.00,
      'Total': widget.tot,
      'loadingcharge': 0.00,
      'OtherCharges': 0.00,
      'OtherDiscount': 0.00,
      'Roundoff': 0.00,
      'GrandTotal': finalAmt,
      'SalesAccount': 0, 
      'SalesMan': 0, 
      'Location': 1, 
      'Narration': 0,
      'Profit': 0.00,
      'CashReceived': 0.00,
      'BalanceAmount': finalAmt,
      'Ecommision': 0.00,
      'labourCharge': 0.00,
      'OtherAmount': 0.00,
      'Type': 0,
      'PrintStatus': 0,
      'CNo': 0,
      'CreditPeriod': 0,
      'DiscPercent': 0.00,
      'SType': 2,
      'VatEntryNo': 0,
      'tcommision': 0.00,
      'commisiontype': 0,
      'cardno': 0,
      'takeuser': 0,
      'PurchaseOrderNo': 0,
      'ddate1': _dateController.text,
      'deliverNoteNo': 0,
      'despatchno': 0,
      'despatchdate':_dateController.text,
      'Transport': 0,
      'Destination': 0,
      'Transfer_Status': 0,
      'TenderCash': 0.00,
      'TenderBalance': 0.00,
      'returnno': 0,
      'returnamt': 0.00,
      'vatentryname': 0,
      'otherdisc1': 0.00,
      'salesorderno': 0,
      'systemno': 0,
      'deliverydate': 0,
      'QtyDiscount': 0.00,
      'ScheemDiscount': 0.00,
      'Add3': add3,
      'Add4': add4,
      'BankName': 0,
      'CCardNo': 0,
      'SMInvoice': 0,
      'Bankcharges': 0.00,
      'CGST': cgst,
      'SGST': sgst,
      'IGST': 0.00,
      'mrptotal': 0.00,
      'adcess': 0.00,
      'BillType': 0,
      'discuntamount': 0.00,
      'unitprice': 0.00,
      'lrno': 0,
      'evehicleno': 0,
      'ewaybillno': 0,
      'RDisc': 0.00,
      'subsidy': 0.00,
      'kms': 0.00,
      'todevice': 0,
      'Fcess': 0.00,
      'spercent': 0.00,
      'bankamount': 0.00,
      'FcessType': 0,
      'receiptAmount': 0.00,
      'receiptDate': _dateController.text,
      'JobCardno': 0,
      'WareHouse': 0,
      'CostCenter': 0,
      'CounterClose': 0,
      'CashAccountID': ledCode,
      'ShippingName': 0,
      'ShippingAdd1': 0,
      'ShippingAdd2': 0,
      'ShippingAdd3': 0,
      'ShippingGstNo': 0,
      'ShippingState': 0,
      'ShippingStateCode': 0,
      'RateType': 0,
      'EmiAc': 0,
      'EmiAmount': 0.00,
      'EmiRefNo': 0,
      'RedeemPoint': 0,
      'IRNNo': 0,
      'signedinvno': 0,
      'signedQrCode': 0,
      'Salesman1': 0,
      'TCSPer': 0.00,
      'TCS': 0.00,
      'app': 0,
      'TotalQty': widget.salesCredit!.qty, 
      'InvoiceLetter': 0,
      'AckDate': 0,
      'AckNo': 0,
      'Project': 0,
      'PlaceofSupply': 0,
      'tenderRefNo': 0,
      'IsCancel': 0,
      'FyID': selectedFyID,
      'm_invoiceno': _InvoicenoController.text,
      'PaymentTerms': 0,
      'WarrentyTerms': 0,
      'QuotationEntryNo': 0,
      'CreditNoteNo': 0,
      'CreditNoteAmount': 0.00,
      'Careoff': 0,
      'CareoffAmount': 0.00,
      'DeliveryStatus': 0,
      'SOrderBilled': 0,
      'isCashCounter': 0,
      'Discountbarcode': 0,
      'ExcEntryNo': 0,
      'ExcEntryAmt': 0.00,
      'FxCurrency': 0,
      'FxValue': 0.00,
      'CntryofOrgin': 0,
      'ContryFinalDest': 0,
      'PrecarriageBy': 0,
      'PlacePrecarrier': 0,
      'PortofLoading': 0,
      'Portofdischarge': 0,
      'FinalDestination': 0,
      'CtnNo': 0,
      'Totalctn': 0,
      'Netwt': 0.00,
      'grosswt': 0.00,
      'Blno': 0
    };

    // Insert into database
    await SalesInformationDatabaseHelper2.instance.insertSale(transactionData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved successfully')),
    );

    setState(() {
      _InvoicenoController.clear();
      _dateController.clear();
      _CustomerController.clear();
    });

  } catch (e) {
    print('Error while saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: $e')),
    );
  }
}


void _saveDataSaleperti() async {
  try {
    final db = await SalesInformationDatabaseHelper.instance.database;
        final lastRow = await db.rawQuery(
      'SELECT * FROM Sales_Particulars ORDER BY Auto DESC LIMIT 1'
    );
    int newAuto = 1;
    int Newentryno = 1;
    
    if (lastRow.isNotEmpty) {
      final lastData = lastRow.first;
      newAuto = (lastData['Auto'] as num? ?? 0).toInt();
      Newentryno = (lastData['EntryNo'] as num? ?? 0).toInt();     
    }

    final double finalAmt = widget.salesCredit?.totalAmt ?? 0.0;  
    final stockDetails = await StockDatabaseHelper.instance
        .getStockDetailsByName(widget.salesCredit!.itemName);
    final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance
        .getLedgerDetailsByName(_CustomerController.text);

    final String ledCode = ledgerDetails?['LedId'] ?? 'Unknown';
    final String itemcode = stockDetails?['itemcode'] ?? 'Unknown';
    
    final stocksaleDetails = await SaleReferenceDatabaseHelper.instance
        .getStockSaleDetailsByName(itemcode);
        final unitsaleDetails = await SaleReferenceDatabaseHelper.instance
        .getStockunitDetailsByName(itemcode);
    
    final String Ucode = stocksaleDetails?['Uniquecode'] ?? 'Unknown';
    final String itemDisc = (stocksaleDetails?['Disc'] ?? 0.0).toString();
   final String prate = (stocksaleDetails?['Prate'] ?? 0.0).toString();
final String rprate = (stocksaleDetails?['RealPrate'] ?? 0.0).toString();

final String unit = (unitsaleDetails?['Unit'] ?? 0.0).toString();
final entry=Newentryno+1;
final cgst = (widget.tax!) / 2;
final sgst = (widget.tax!) / 2;
String selectedDate = _dateController.text;
int selectedFyID = 0; 

for (var fyRecord in fy) {
  DateTime fromDate = DateTime.parse(fyRecord['Frmdate'].toString());  // Ensure it's parsed correctly
  DateTime toDate = DateTime.parse(fyRecord['Todate'].toString());  
  DateTime selected = DateTime.parse(selectedDate);  

  if (selected.isAfter(fromDate) && selected.isBefore(toDate)) {
    selectedFyID = int.tryParse(fyRecord['Fyid'].toString()) ?? 0;  // ✅ Ensure integer conversion
    break;  
  }
}

    final transactionData = {
      'DDate': _dateController.text,
      'EntryNo': entry,
      'UniqueCode': Ucode,
      'ItemID': itemcode,
      'serialno': 0,
      'Rate': 0.0,
      'RealRate': 0.0,
      'Qty': widget.salesCredit!.qty,
      'freeQty': 0.0,
      'GrossValue': finalAmt,
      'DiscPersent': widget.discPerc,
      'Disc': widget.discnt,
      'RDisc': 0.0,
      'Net': widget.net,
      'Vat': 0.0,
      'freeVat': 0.0,
      'cess': 0.0,
      'Total': widget.tot,
      'Profit': 0.0,
      'Auto': newAuto,
      'Unit': unit,
      'UnitValue': 0.0,
      'Funit': 0,
      'FValue': 0,
      'commision': 0.0,
      'GridID': 0,
      'takeprintstatus': 0,
      'QtyDiscPercent': 0.0,
      'QtyDiscount':itemDisc,
      'ScheemDiscPercent': 0.0,
      'ScheemDiscount': 0.0,
      'CGST': cgst,
      'SGST': sgst,
      'IGST': 0.0,
      'adcess': 0.0,
      'netdisc': 0.0,
      'taxrate': widget.tax,
      'SalesmanId': 0,
      'Fcess': 0.0,
      'Prate': prate,
      'Rprate': rprate,
      'location': 0,
      'Stype': 0,
      'LC': 0.0,
      'ScanBarcode': 0,
      'Remark': 0,
      'FyID': selectedFyID,
      'Supplier': 0,
      'Retail': 0.0,
      'spretail': 0.0,
      'wsrate': 0.0,
    };
    
    await SalesInformationDatabaseHelper.instance.insertParticular(transactionData);
    if (ledgerDetails != null) {
    } else {
      print('Ledger not found for name: ${_CustomerController.text}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved successfully')),
    );

    setState(() {
    });
  } catch (e) {
    print('Error while saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: $e')),
    );
  }
}


void _saveData() async {
  try {
    final qtyToReduce = widget.salesCredit!.qty.toDouble();
    final itemName = widget.salesCredit!.itemName.toString();
    final double finalAmt = widget.salesCredit?.totalAmt ?? 0.0;

    final itemCode = await StockDatabaseHelper.instance.getItemIdByItemName(itemName);

    if (itemCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item code not found for $itemName')),
      );
      return;
    }

    final stockData = await StockDatabaseHelper.instance.getProductByItemId2(itemCode);

    if (stockData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item not found in stock table')),
      );
      return;
    }

    final currentQty = stockData['Qty'] as double;
    final updatedQty = currentQty - qtyToReduce;

    if (updatedQty < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough stock for $itemName')),
      );
      return;
    }

    await StockDatabaseHelper.instance.updateProductQuantity(itemCode, updatedQty);

    final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance.getLedgerDetailsByName(_CustomerController.text);

    if (ledgerDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ledger not found for name: ${_CustomerController.text}')),
      );
      return;
    }

    final String ledCode = ledgerDetails['LedId'] ?? 'Unknown';
    final double currentBalance = ledgerDetails['OpeningBalance'] as double? ?? 0.0;
    final double updatedBalance = currentBalance - finalAmt;

    await LedgerTransactionsDatabaseHelper.instance.updateLedgerBalance(ledCode, updatedBalance);

    final creditsale = SalesCredit(
      invoiceId: int.parse(_InvoicenoController.text),
      date: _dateController.text,
      salesRate: double.tryParse(_salerateController.text) ?? 0.0,
      customer: _CustomerController.text,
      phoneNo: _phonenoController.text,
      itemName: widget.salesCredit!.itemName,
      qty: widget.salesCredit!.qty,
      unit: widget.salesCredit!.unit,
      rate: widget.salesCredit!.rate,
      tax: widget.salesCredit!.tax,
      totalAmt: finalAmt,
    );

    int lastInsertedId = await SaleDatabaseHelper.instance.insert(creditsale.toMap());

    // Perform any additional post-insert operations
    // await _saveLastInsertedIdToPayments(lastInsertedId, creditsale.customer);
    // await syncOpeningBalances(lastInsertedId);

    // Show success message and clear form fields
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved successfully')),
    );

    setState(() {
      _InvoicenoController.clear();
      _salerateController.clear();
      _CustomerController.clear();
      _phonenoController.clear();
      _totalamtController.clear();
    });
  } catch (e) {
    print('Error saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred while saving data')),
    );
  }
}



void _saveDataCash() async {
  try {
    final qtyToReduce = widget.salesDebit!.qty.toDouble();
    final itemName = widget.salesDebit!.itemName.toString();
    final double finalAmt = widget.salesDebit?.totalAmt ?? 0.0;
    final itemCode = await StockDatabaseHelper.instance.getItemIdByItemName(itemName);

    if (itemCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item code not found for $itemName')),
      );
      return;
    }
    final stockData = await StockDatabaseHelper.instance.getProductByItemId2(itemCode);

    if (stockData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item not found in stock table')),
      );
      return;
    }

    final currentQty = stockData['Qty'] as double;
    final updatedQty = currentQty - qtyToReduce;

    if (updatedQty < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough stock for $itemName')),
      );
      return;
    }

    await StockDatabaseHelper.instance.updateProductQuantity(itemCode, updatedQty);

final double salesRate = double.tryParse(_CashsalerateController.text) ?? 0.0;
    final double totalAmt = double.tryParse(_CashtotalamtController.text) ?? 0.0;

    final Cashcreditsale=SalesCredit(
    
    invoiceId: nextInvoiceId,
    date: _dateController.text, 
    salesRate: salesRate,
     customer: _billnameController.text,
      phoneNo: _CashphonenoController.text,
      itemName: widget.salesDebit?.itemName ?? '',
        qty: widget.salesDebit!.qty,
         unit: widget.salesDebit!.unit,
          rate: widget.salesDebit!.rate,
           tax: widget.salesDebit!.tax, 
           totalAmt:finalAmt);
          await SaleDatabaseHelper.instance.insert(Cashcreditsale.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved successfully')),
    );

    setState(() {
      _InvoicenoController.clear();
      _CashsalerateController.clear();
      _billnameController.clear();
      _CashphonenoController.clear();
      _CashtotalamtController.clear();
    });
  } catch (e) {
    print('Error saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred while saving data')),
    );
  }
}
//  syncOpeningBalancesCash() async {
//   final paymentHelper = SaleDatabaseHelper.instance;
//   final ledgerHelper = DatabaseHelper.instance;
//   List<Map<String, dynamic>> payments = await paymentHelper.queryAllRows();

//   for (var payment in payments) {
//     String ledgerName = payment['ledgerName'];
//     double saleTotal = payment['total_amt'] ?? 0.0;

//     Map<String, dynamic>? ledger =
//         await ledgerHelper.getLedgerByName(ledgerName);

//     if (ledger != null) {
//       await ledgerHelper.updateLedgerBalance(ledgerName, saleTotal);
//     }
//   }

//   print("Opening balances updated successfully!");
// }
// Future<void> _saveLastInsertedIdToPayments(int lastInsertedId, String customer) async {
//   final ledgerHelper = DatabaseHelper.instance;

//   Map<String, dynamic>? ledger = await ledgerHelper.getLedgerByName(customer);

//   if (ledger != null) {
//     await ledgerHelper.updateLedgerBalance(customer, lastInsertedId.toDouble());
//   } else {
//     print("Ledger not found for customer: $customer");
//   }
// }

// Future<void> syncOpeningBalances(int lastInsertedId) async {
//   final paymentHelper = SaleDatabaseHelper.instance;
//   final ledgerHelper = DatabaseHelper.instance;

//   Map<String, dynamic>? payment = await paymentHelper.getRowById(lastInsertedId);

//   if (payment != null) {
//     String ledgerName = payment['customer'];
//     double saleTotal = payment['total_amt'] ?? 0.0;

//     Map<String, dynamic>? ledger = await ledgerHelper.getLedgerByName(ledgerName);

//     if (ledger != null) {
//       double receivedBalance = ledger[DatabaseHelper.columnReceivedBalance] ?? 0.0;
//       double payAmount = ledger[DatabaseHelper.columnPayAmount] ?? 0.0;
//       double openingBalance=payAmount-receivedBalance;
//       double updatedSaleTotal = (openingBalance - saleTotal).abs();

//       await ledgerHelper.updateLedgerBalance(ledgerName, updatedSaleTotal);

//       print("Updated ledger balance for $ledgerName: $updatedSaleTotal");
//     } else {
//       print("Ledger not found for customer: $ledgerName");
//     }
//   } else {
//     print("No payment found for ID: $lastInsertedId");
//   }

//   print("Opening balance synced for the last record.");
// }


  String? _selectedKey;

Future<void> _fetchItems({String? customer}) async {
  final items = await SaleDatabaseHelper.instance.queryRowsByCustomer(customer: customer);
  setState(() {
    todayItems = items;
  });
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
     void updateTotalAmount() {
    double qty = widget.salesCredit?.qty ?? 0.0;
    double rate = widget.salesCredit?.rate ?? 0.0;
    double tax = widget.salesCredit?.tax ?? 0.0;
    double finalamt=widget.salesCredit?.totalAmt??0.0;
    double saleRate = double.tryParse(_salerateController.text) ?? 0.0;
        double totalAmt = finalamt + ((saleRate - rate) * qty);
        _totalamtController.text = finalamt.toStringAsFixed(2);
  }
  _salerateController.addListener(updateTotalAmount);

   void CashupdateTotalAmount() {
    double qty = widget.salesDebit?.qty ?? 0.0;
    double rate = widget.salesDebit?.rate ?? 0.0;
    double tax = widget.salesDebit?.tax ?? 0.0;
    double saleRate = double.tryParse(_CashsalerateController.text) ?? 0.0;
        double totalAmt = (qty * rate) + tax + ((saleRate - rate) * qty);
        _CashtotalamtController.text = totalAmt.toStringAsFixed(2);
  }
  _CashsalerateController.addListener(CashupdateTotalAmount);
_InvoicenoController.text=newinno.toString();
    return Scaffold(
      backgroundColor: Appcolors().scafoldcolor,
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.1,
        backgroundColor: Appcolors().maincolor,
        leading: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomePageERP()));
            },
            icon: Icon(
              Icons.arrow_back_ios_new_sharp,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 18,right:20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sales",
                style: appbarFonts(screenHeight * 0.02, Colors.white),
              ),
              Container(
                height: screenHeight * 0.03,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isCreditSelected = true;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.01),
                        decoration: BoxDecoration(
                          color: isCreditSelected ? Colors.green : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Credit",
                          style: TextStyle(
                            color: isCreditSelected ? Colors.white : Colors.black,
                            fontSize: screenHeight * 0.01,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isCreditSelected = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.01),
                        decoration: BoxDecoration(
                          color: !isCreditSelected ? Colors.green : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Cash",
                          style: TextStyle(
                            color: !isCreditSelected ? Colors.white : Colors.black,
                            fontSize: screenHeight * 0.01,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight*0.02),
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
          physics: ScrollPhysics(),
           child: Column(
             children: [
               Center(
                       child: isCreditSelected
                  ? _CreditScreenContent(screenHeight,screenWidth)
                  : _CashScreenContent(screenHeight,screenWidth),
                     ),

              

             ],
           ),
         ), 
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: screenHeight*0.03,vertical:screenHeight*0.03 ),
        child: Row(children: [
          GestureDetector(
            onTap: (){},
            child: Container(
              width: 175,height: 53,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5),bottomLeft: Radius.circular(5)),
                color: Appcolors().Scfold
                
              ),
              child: Center(child: Text("Save & New",style: getFonts(15, Colors.black),)),
            ),
          ),
          GestureDetector(
            onTap: (){
             //_saveDataCash();
             
              //_saveData2();
               _saveData();
             _saveDataSaleperti();
              _saveDataSaleinfor22();
              },
            child: Container(
              width: 175,height: 53,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(5),bottomRight: Radius.circular(5)),
                color: Appcolors().maincolor
              ),
              child: Center(child: Text("Save ",style: getFonts(15, Colors.white),)),
            ),
          )
        ],),
      ),  
    );
  }
Widget _CreditScreenContent(double screenHeight,double screenWidth) {

  var item = widget.itemDetails?[0];
    List<String>? keys = item?.keys.toList();
  
  List<String> ledgerNamesAsString = ledgerIds.map((id) => id.toString()).toList();
   double additem_total=widget.salesCredit?.totalAmt??0.0;

    return Column(
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
                
                'Invoice No',
                style: formFonts(14, Colors.black),
              ),
          SizedBox(height: screenHeight * 0.01),
          Container(
   height: screenHeight * 0.032, 
              width: screenWidth * 0.43,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(5),
    color: Colors.white,
    border: Border.all(color: Appcolors().searchTextcolor),
  ),
  //child: Text('$newinno',style: getFontsinput(14, Colors.black),),
  child: SingleChildScrollView(
    physics: NeverScrollableScrollPhysics(),
    child: EasyAutocomplete(
        controller: _InvoicenoController,
        suggestions: ledgerNamesAsString,
           inputTextStyle: getFontsinput(14, Colors.black),
        onSubmitted: (value) {
          int selectedId = ledgerIds[ledgerNamesAsString.indexOf(value)];
       // _fetchInvoiceData(selectedId);  
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(bottom: 23,left: 5),
        ),
      
        suggestionBackgroundColor: Appcolors().Scfold,
      ),
  ),
)
,
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
                                  height: screenHeight * 0.032, 
              width: screenWidth * 0.43,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Appcolors().searchTextcolor),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child:TextField(
                                      style: getFontsinput(14, Colors.black),
           readOnly: true,
          controller: _dateController,
           decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 11, horizontal: 10),
                
              ),
        ),
                                  ),
        ],
      ),
    )
            ],
          ),
        ),
    SizedBox(height: screenHeight*0.03,),
       Container(
        child: Column(
          children: [
            Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
                "Sales Rate",
                style: formFonts(14, Colors.black),
              ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            padding: EdgeInsets.symmetric(horizontal: screenHeight*0.01),
                    height: screenHeight * 0.05,
                    width: screenWidth * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      border: Border.all(color: Appcolors().searchTextcolor),
                    ),
                    child: Container(height: screenHeight*0.2,
                      child: DropdownButton<String>(
                        dropdownColor: Appcolors().Scfold,
                        style: getFontsinput(14, Colors.black),
                                    value: _selectedKey,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedKey = newValue;
                                      });
                                    },
                                    items: keys?.map<DropdownMenuItem<String>>((String key) {
                                      return DropdownMenuItem<String>(
                                        value: key,
                                        child: Text(key.toUpperCase()), // Display column name in uppercase
                                      );
                                    }).toList(),
                                    menuMaxHeight: 150,
                                    underline: SizedBox.shrink(), 
                                  ),
                    ),
                  ),
        ],
      ),
    ),
    SizedBox(height: screenHeight*0.03,),
    Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
              "Customer",
              style: formFonts(14, Colors.black),
            ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          padding: EdgeInsets.symmetric(vertical: screenHeight*0.001),
                    height: screenHeight * 0.05,
                    width: screenWidth * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      border: Border.all(color: Appcolors().searchTextcolor),
                    ),
                    child: Padding(
              padding: EdgeInsets.only(left: 10,bottom: 10),
              child: SingleChildScrollView(
                 physics: NeverScrollableScrollPhysics(),
                    child:EasyAutocomplete(
      controller: _CustomerController,
      suggestions: names,
      inputTextStyle: getFontsinput(14, Colors.black),
      onSubmitted: (value) async {
        if (!isCustomerSelected) {
          await _fetchLedgerDetails(value);
          await _fetchItems(customer: value);
          setState(() {
            _CustomerController.text = value;
            isCustomerSelected = true; // Lock further changes
          });
        }
      },
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.only(bottom: 10),
      ),
      suggestionBackgroundColor: Appcolors().Scfold,
    ),
                  ),
            )
                  ),
      ],
    ),
        ),
            SizedBox(height: screenHeight*0.03,),
             _field("Phone Number", _phonenoController, screenWidth, screenHeight),
             SizedBox(height: screenHeight*0.001,),
             GestureDetector(
        onTap: () {
           setState(() {
      _CustomerController.clear();
      isCustomerSelected = false;
    });
          Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Addpaymant(
                          salesCredit: widget.salesCredit,
)));
        },
        child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.03),
          child: Container(
            height: screenHeight * 0.05,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color(0xFF0A1EBE),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 20,width: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white)
              ),      
              child: Icon(Icons.add,color: Colors.white,size: 17,),
                  ),
                  Text(
                    "Add Item",
                    style: getFonts(11, Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          ],
        ),
       ),
        Padding(
         padding:  EdgeInsets.symmetric(horizontal: screenHeight*0.03),
         child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Amount",style: getFonts(14, Colors.black),),
              Column(children: [
                Row(
                  children: [
                    Text("₹",style: getFonts(14, Colors.black)),
 Text(
                        _totalamtController.text.isEmpty
                            ? additem_total.toString()
                            : _totalamtController.text,
                        style: getFonts(14, Colors.red),
                      ),                  ],
                ),
                //Text("...........................",style: getFonts(14, Colors.black)),
                // Text(".......................",style: getFonts(10, Colors.black),)

                
              ],)
            ],
          ),
         ),
       ),
       Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight*0.01),
  width: screenWidth * 0.9,
  child: Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Itemname",
                  style: formFonts(12, Colors.black),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  ":  ${widget.salesCredit?.itemName ?? ''}",
                  style: getFontsinput(12, Colors.black),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Unit",
                  style: formFonts(12, Colors.black),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  ":  ${widget.salesCredit?.unit ?? ''}",
                  style: getFontsinput(12, Colors.black),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Quantity",
                  style: formFonts(12, Colors.black),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  ":  ${widget.salesCredit?.qty.toString() ?? ''}",
                  style: getFontsinput(12, Colors.black),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Rate",
                  style: formFonts(12, Colors.black),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  ":  ${widget.salesCredit?.rate.toString() ?? ''}",
                  style: getFontsinput(12, Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
),
        //SizedBox(height: screenHeight*0.2,),
            Container(
              height: screenHeight*0.3,
              child: Expanded(
                child: ListView.builder(padding: EdgeInsets.symmetric(horizontal: screenHeight*0.022),
                   itemCount: todayItems.length,
                  itemBuilder: (context, index) {
                    final item = todayItems[index];
                    return  Container(
                    padding: EdgeInsets.symmetric(vertical: screenHeight*0.01),
                    width: screenWidth * 0.9,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Column(
                          children: [
                            Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Itemname",
                        style: formFonts(12, Colors.black),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        ":  ${item['item_name']}",
                        style: getFontsinput(12, Colors.black),
                      ),
                    ),
                  ],
                            ),
                            Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Unit",
                        style: formFonts(12, Colors.black),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        ":  ${item['unit']}",
                        style: getFontsinput(12, Colors.black),
                      ),
                    ),
                  ],
                            ),
                            Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Quantity",
                        style: formFonts(12, Colors.black),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        ":  ${item['qty']}",
                        style: getFontsinput(12, Colors.black),
                      ),
                    ),
                  ],
                            ),
                            Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Rate",
                        style: formFonts(12, Colors.black),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        ":  ${item['rate']}",
                        style: getFontsinput(12, Colors.black),
                      ),
                    ),
                  ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  }
                 ,
                  
                ),
              ),
            )
      ],
    );
  }

  // Cash Screen Content
  Widget _CashScreenContent(double screenHeight,double screenWidth) {
      List<String> ledgerNamesAsString = ledgerIds.map((id) => id.toString()).toList();
   double additem_total=widget.salesDebit?.totalAmt??0.0;
   
    return Column(
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
                
                'Invoice No',
                style: formFonts(14, Colors.black),
              ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7,vertical: 2),
             height: screenHeight * 0.032, 
              width: screenWidth * 0.43,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
            ),
           child: Text("$nextInvoiceId",style: getFontsinput(14, Colors.black),),
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
             height: screenHeight * 0.032, 
              width: screenWidth * 0.43,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
            ),
            child:TextField(
              style: getFontsinput(14, Colors.black),
           readOnly: true,
          controller: _dateController,
           decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 11, horizontal: 10),
              ),
        ),
          ),
        ],
      ),
    )
            ],
          ),
        ),
    SizedBox(height: screenHeight*0.03,),
       Container(
        child: Column(
          children: [
            Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
                "Sales Rate",
                style: formFonts(14, Colors.black),
              ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            height: screenHeight * 0.05,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _CashsalerateController,
                      style: getFontsinput(14, Colors.black),
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
    ),
    SizedBox(height: screenHeight*0.03,),
            _field("Billing Name", _billnameController, screenWidth, screenHeight),
            SizedBox(height: screenHeight*0.03,),
             _field("Phone Number", _CashphonenoController, screenWidth, screenHeight),
             SizedBox(height: screenHeight*0.001,),
             GestureDetector(
        onTap: () {
          Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Addpaymant2(salesdebit: widget.salesDebit,)));
        },
        child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.03),
          child: Container(
            height: screenHeight * 0.05,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color(0xFF0A1EBE),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 20,width: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white)
              ),      
              child: Icon(Icons.add,color: Colors.white,size: 17,),
                  ),
                  Text(
                    "Add Item",
                    style: getFonts(11, Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          ],
        ),
       ),
       Padding(
         padding:  EdgeInsets.symmetric(horizontal: screenHeight*0.03),
         child: Container(
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Amount",style: getFonts(14, Colors.black),),
              Column(children: [
                Row(
                  children: [
                    Text("₹",style: getFonts(14, Colors.black)),
 Text(
                        _CashtotalamtController.text.isEmpty
                            ? additem_total.toString()
                            : _CashtotalamtController.text,
                        style: getFonts(14, Colors.red),
                      ),                  ],
                ),
                
              ],)
            ],
          )
         ),
       ),
       Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight*0.01),
  width: screenWidth * 0.9,
  child: Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Itemname",
                  style: formFonts(12, Colors.black),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  ":  ${widget.salesDebit?.itemName ?? ''}",
                  style: getFontsinput(12, Colors.black),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Unit",
                  style: formFonts(12, Colors.black),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  ":  ${widget.salesDebit?.unit ?? ''}",
                  style: getFontsinput(12, Colors.black),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Quantity",
                  style: formFonts(12, Colors.black),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  ":  ${widget.salesDebit?.qty.toString() ?? ''}",
                  style: getFontsinput(12, Colors.black),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Rate",
                  style: formFonts(12, Colors.black),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  ":  ${widget.salesDebit?.rate.toString() ?? ''}",
                  style: getFontsinput(12, Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
)

      ],
    );
  }

  Widget _field(String textrow, TextEditingController controller, double screenWidth, double screenHeight) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
                textrow,
                style: formFonts(14, Colors.black),
              ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            height: screenHeight * 0.05,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      style: getFontsinput(14, Colors.black),
                      controller: controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter $textrow';
                        }
                        return null;
                      },
                      readOnly: true,
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
  void _showCreateItemDialog(String CassAcc) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Appcolors().Scfold,
        title: Text('Create new one'),
        content: Text('Item "${_CustomerController.text}" does not exist. Would you like to create it?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Appcolors().maincolor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Newledger()));
            },
            child: Text(
              'Create',
              style: TextStyle(color: Appcolors().maincolor),
            ),
          ),
        ],
      );
    },
  );
}
}