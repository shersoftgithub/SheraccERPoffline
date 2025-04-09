
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/models/salescredit_modal.dart';
import 'package:sheraaccerpoff/previews/sales_preview.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/companydb.dart';
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
import 'package:shared_preferences/shared_preferences.dart';


class SalesOrder extends StatefulWidget {
  final SalesCredit? salesCredit;
  final SalesCredit? salesDebit;
final List<Map<String, String>>? itemDetails;
final double? discPerc; 
final double? discnt;
final double? net;
final double? tot;
final double? tax;
final String? taxstatus;
final double? discPercCC; 
final double? discntCC;
final double? netCC;
final double? totCC;
final double? taxCC;
final String? taxstatusCC;
final String? selectedType;
final String? selectedid;
final List<Map<String, dynamic>>? tempdata;
final List<Map<String, dynamic>>? tempdataCASH;
final String?cusname;
final double? grandtotal;
final double? grandtotalcash;
  const SalesOrder({super.key, this.salesCredit,this.salesDebit,this.itemDetails,this.discPerc,this.discnt,this.net,this.tot,this.tax,this.taxstatus,this.selectedType,this.selectedid,
  this.discPercCC,this.discntCC,this.netCC,this.totCC,this.taxCC,this.taxstatusCC,this.tempdata,this.cusname,this.grandtotal,this.tempdataCASH,this.grandtotalcash
  });
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
  final TextEditingController _adressController = TextEditingController();
  final TextEditingController _OBcontroller = TextEditingController();
    final TextEditingController _cashRecieveController = TextEditingController();


  final TextEditingController _CashphonenoController = TextEditingController();
  final TextEditingController _CashtotalamtController = TextEditingController();
  final TextEditingController _CashsalerateController = TextEditingController();
  final TextEditingController _billnameController     = TextEditingController();
  bool isCreditSelected = true;
  bool _isExpanded = false;
  bool _isExpandedAmt = false;
  
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
  TextEditingController customername = TextEditingController();  
String _selectedCustomer = "";  
    @override
  void initState() {
    super.initState();
    invoice();
 
   if (_CustomerController.text.isEmpty && widget.cusname != null && widget.cusname!.isNotEmpty) {
    _CustomerController.text = widget.cusname!;
  }
    fetch_options();
    _fetchLedger();
    _fetchLastInvoiceId();
    _fetchfyData();
   _fetchCompanyData2();
   _fetchSType();
   _restoreSavedData();
   openingBalance;
   _InvoicenoController.text = ''; 
    _dateController.text = '';      
    _salerateController.text = '';  
   _cashRecieveController.text='';
   _OBcontroller.text='';
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
   @override
  void dispose() {
    super.dispose();
    _InvoicenoController.dispose();
    _dateController.dispose();
    _salerateController.dispose();
    _CustomerController.dispose();
     _CashtotalamtController.dispose();
    _totalamtController.dispose();
    _billnameController.dispose();
    _CashphonenoController.dispose();
  }
    optionsDBHelper dbHelper = optionsDBHelper();
     List<Map<String, dynamic>> todayItems = [];


String selectedStype = 'Sale'; 
String selectedID = '0'; 
List stypelist=[];
Future<void> _fetchSType() async {
  try {
    List<Map<String, dynamic>> data = await SaleReferenceDatabaseHelper.instance.getAllStype();
    print('Fetched stock data: $data');

    setState(() {
      stypelist = data;
      var selectedItems = stypelist.where((item) => item['isChecked'] == 1).toList();
      if (selectedItems.isNotEmpty) {
        selectedStype = selectedItems.first['Type'] ?? 'Sale';
        selectedID = selectedItems.first['iD'] ?? '0';
      } else {
        selectedStype = 'Sale';
        selectedID = '0';
      }
    });
  } catch (e) {
    print('Error fetching stock data: $e');
  }
}

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

Future<void> _restoreSavedData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    _phonenoController.text = prefs.getString('savedPhone') ?? '';
    _adressController.text = prefs.getString('savedAddress') ?? '';
    openingBalance = prefs.getDouble('savedOpeningBalance') ?? 0.0;
    _CashphonenoController.text = prefs.getString('savedcashphone')??'';
    _billnameController.text = prefs.getString('savedbillname')?? '';
  });
}
double openingBalance = 0.0;


Future<void> _fetchLedgerDetails(String ledgerName) async {
  if (ledgerName.isNotEmpty) {
    Map<String, dynamic>? ledgerDetails = await LedgerTransactionsDatabaseHelper.instance.getLedgerDetailsByName(ledgerName);

    if (ledgerDetails != null) {
      setState(() {
        _phonenoController.text = ledgerDetails['Mobile'] ?? '';
        _adressController.text = ledgerDetails['add1'] ?? '';
        openingBalance = double.tryParse(ledgerDetails['OpeningBalance'].toString()) ?? 0.0;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedPhone', ledgerDetails['Mobile'] ?? '');
      await prefs.setString('savedAddress', ledgerDetails['add1'] ?? '');
      await prefs.setDouble('savedOpeningBalance', openingBalance);
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
List companydata= [];
 Future<void> _fetchCompanyData2() async {
    try {
    List<Map<String, dynamic>> data = await CompanyDatabaseHelper.instance.getAllCompany();
      print('Fetched Company data: $data');
      setState(() {
      companydata   = data;
      });
    } catch (e) {
      print('Error fetching Company data: $e');
    }
  }

 

// void invoice() async {
//   final db = await SalesInformationDatabaseHelper2.instance.database;
  
//   // Fetch last EntryNo, sorted in descending order
//   final lastRow = await db.rawQuery(
//     'SELECT EntryNo FROM Sales_Particulars ORDER BY EntryNo DESC LIMIT 1',
//   );

//   int lastEntryNo = lastRow.isNotEmpty ? (lastRow.first['EntryNo'] as int? ?? 0) : 0;
//   int updatedInno = lastEntryNo + 1; // Increment for the new invoice

//   setState(() {
//     newinno = updatedInno; 
//   });

//   print('New Invoice Number: $newinno'); // Debugging print
// }


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
    if (_CustomerController.text.isEmpty) {
      print("Error: Customer name is empty.");
      return;
    }

    final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance
        .getLedgerDetailsByName(_CustomerController.text);

    if (ledgerDetails == null) {
      print("Error: Ledger details not found for ${_CustomerController.text}");
      return;
    }
  double _grandTotal = 0.0; 
  double _totqty = 0.0;
void _calculateGrandTotal() {
  setState(() {
    _grandTotal = widget.tempdata!.fold(0.0, (sum, item) => sum + (double.tryParse(item['total'].toString()) ?? 0.0));
     _totalamtController.text = _grandTotal.toStringAsFixed(2);
     _totqty = widget.tempdata!.fold(0.0,(sum,item)=> sum +(double.tryParse(item['qty'].toString())?? 0.0));
  });
}
    final String ledCode = ledgerDetails['LedId']?.toString() ?? 'Unknown';
    final double openingBalance = double.tryParse(ledgerDetails['OpeningBalance']?.toString() ?? '0.0') ?? 0.0;

    final double finalAmt = widget.salesCredit?.totalAmt ?? 0.0;
    final double creditAmt = openingBalance - finalAmt;
    double cashReceived = double.tryParse(_cashRecieveController.text) ?? 0.0;
double balance = _grandTotal- cashReceived; 
    final transactionData = {
      'atDate': _dateController.text.isNotEmpty ? _dateController.text : 'Unknown',
      'atLedCode': ledCode,
      'atDebitAmount': finalAmt,
      'atCreditAmount': balance,
      'atType': selectedStype,
      'Caccount': _salerateController.text.isNotEmpty ? _salerateController.text : '0.0',
      'atLedName': _CustomerController.text,
    };

    await LedgerTransactionsDatabaseHelper.instance.insertAccTrans(transactionData);

    final double updatedBalance = creditAmt;
    await LedgerTransactionsDatabaseHelper.instance.updateLedgerBalance(ledCode, updatedBalance);

    print('Transaction saved successfully.');
    Fluttertoast.showToast(msg: "Saved successfully");
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Saved successfully')),
    // );

    setState(() {});
  } catch (e, stackTrace) {
    print('Error while saving data: $e');
    print('Stack Trace: $stackTrace');
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
      return 'NULL';
    }

    return "'${DateFormat("yyyy-MM-dd").format(parsedDate)}'";
  } catch (e) {
    print("Date conversion error: $e for input: $inputDate");
    return 'NULL'; 
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
final String add1 = ledgerDetails?['add1'] ?? '';
final String add2 = ledgerDetails?['add2'] ?? '';
final String add3 = ledgerDetails?['add3'] ?? '';
final String add4 = ledgerDetails?['add4'] ?? '';
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

 final double total = (widget.tot is String)
        ? double.tryParse(widget.tot as String) ?? 0.0
        : (widget.tot as double?) ?? 0.0;
final String prate = stocksaleDetails?['Prate']?.toString() ?? '0.0';
    final double priceRate = double.tryParse(prate) ?? 0.0;
    final num quantity = widget.salesCredit?.qty ?? 0;
   final rate =widget.salesCredit?.rate?? 0;
    final double profit = total - (priceRate * quantity);

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
      'Toname': _CustomerController.text.toString(),
      'TaxType': widget.taxstatus, 
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
      'Profit': profit.toString(),
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
      'SType': selectedID,
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
      // _dateController.clear();
      // _CustomerController.clear();
    });

  } catch (e) {
    print('Error while saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: $e')),
    );
  }
}



void _saveDataSaleinfor22multi() async {
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
final String add1 = ledgerDetails?['add1'] ?? '';
final String add2 = ledgerDetails?['add2'] ?? '';
final String add3 = ledgerDetails?['add3'] ?? '';
final String add4 = ledgerDetails?['add4'] ?? '';
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
    
    

 for (var tempDataEntry in widget.tempdata!) {
      final itemName = tempDataEntry['itemname'] ?? '';
      final qty = tempDataEntry['qty'] ?? 0.0;
      final rate = tempDataEntry['rate'] ?? 0.0;
      final tax = tempDataEntry['tax'] ?? 0.0;
      final discount = tempDataEntry['discount'] ?? 0.0;
      final discountPercentage = tempDataEntry['discountpercentage'] ?? 0.0;
      final unit = tempDataEntry['unit'] ?? '';
      final freeItem = tempDataEntry['freeItem'] ?? '';
      final subtotal = tempDataEntry['subtotal'] ?? '';
      final totalAmount = tempDataEntry['total'] ?? '';
      final taxtype = (tempDataEntry['taxtype'] == 'with tax') ? 'T' : 'NT';
      final finalAmt = qty * rate; 
      final profit = finalAmt - (qty * rate);

      final double cgst = (tax ?? 0.0) / 2;
      final double sgst = (tax ?? 0.0) / 2;

      final String selectedDate = _dateController.text;

      final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance.getLedgerDetailsByName(_CustomerController.text);

      final String ledCode = ledgerDetails?['LedId']?.toString() ?? 'Unknown';
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
final double finalAmtfi = widget.grandtotal ?? 0.0;
      final transactionData = {

      'RealEntryNo': newAuto, 
      'EntryNo': _InvoicenoController.text, 
      'InvoiceNo': _InvoicenoController.text,
      'DDate':_dateController.text,
      'BTime':'1900-01-01 ' +
                DateFormat("H:m:s:S")
                    .format(DateTime.now())
                    .toString(),
      'Customer': ledCode,
      'Add1': add1, 
      'Add2': add2,
      'Toname': _CustomerController.text.toString(),
      'TaxType': taxtype.toString(), 
      'GrossValue': finalAmt,
      'Discount': discount,
      'NetAmount': subtotal.toString(),
      'cess': 0.00,
      'Total': totalAmount.toString(),
      'loadingcharge': 0.00,
      'OtherCharges': 0.00,
      'OtherDiscount': 0.00,
      'Roundoff': 0.00,
      'GrandTotal': finalAmtfi,
      'SalesAccount': 0, 
      'SalesMan': 0, 
      'Location': 1, 
      'Narration': '',
      'Profit': profit.toString(),
      'CashReceived': _cashRecieveController.text,
      'BalanceAmount': finalAmt,
      'Ecommision': 0.00,
      'labourCharge': 0.00,
      'OtherAmount': 0.00,
      'Type': 0,
      'PrintStatus': 0,
      'CNo': 0,
      'CreditPeriod': 0,
      'DiscPercent': 0.00,
      'SType': selectedID,
      'VatEntryNo': 0,
      'tcommision': 0.00,
      'commisiontype': 0,
      'cardno': 0,
      'takeuser': 0,
      'PurchaseOrderNo': '',
      'ddate1': _dateController.text,
      'deliverNoteNo': "",
      'despatchno': '',
      'despatchdate':_dateController.text,
      'Transport': '',
      'Destination': '',
      'Transfer_Status': 0,
      'TenderCash': 0.00,
      'TenderBalance': 0.00,
      'returnno': 0,
      'returnamt': 0.00,
      'vatentryname': '',
      'otherdisc1': '',
      'salesorderno': 0,
      'systemno': 0,
      'deliverydate': 0,
      'QtyDiscount': 0.00,
      'ScheemDiscount': 0.00,
      'Add3': add3,
      'Add4': add4,
      'BankName': '',
      'CCardNo': 0,
      'SMInvoice': '',
      'Bankcharges': 0.00,
      'CGST': cgst,
      'SGST': sgst,
      'IGST': 0.00,
      'mrptotal': 0.00,
      'adcess': 0.00,
      'BillType': 0,
      'discuntamount': '',
      'unitprice': '',
      'lrno': '',
      'evehicleno': '',
      'ewaybillno': '',
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
      'ShippingName': '',
      'ShippingAdd1': '',
      'ShippingAdd2': '',
      'ShippingAdd3': '',
      'ShippingGstNo': '',
      'ShippingState': '',
      'ShippingStateCode': '',
      'RateType': 0,
      'EmiAc': 0,
      'EmiAmount': 0.00,
      'EmiRefNo': '',
      'RedeemPoint': 0,
      'IRNNo': '',
      'signedinvno': '',
      'signedQrCode': '',
      'Salesman1': 0,
      'TCSPer': 0.00,
      'TCS': 0.00,
      'app': 0,
      'TotalQty': qty.toString(), 
      'InvoiceLetter': '',
      'AckDate': '',
      'AckNo': '',
      'Project': 0,
      'PlaceofSupply': '',
      'tenderRefNo': '',
      'IsCancel': 0,
      'FyID': selectedFyID,
      'm_invoiceno': _InvoicenoController.text,
      'PaymentTerms': '',
      'WarrentyTerms': '',
      'QuotationEntryNo': '',
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
      'CntryofOrgin': '',
      'ContryFinalDest': '',
      'PrecarriageBy': '',
      'PlacePrecarrier': '',
      'PortofLoading': '',
      'Portofdischarge': '',
      'FinalDestination': '',
      'CtnNo': 0,
      'Totalctn': 0,
      'Netwt': 0.00,
      'grosswt': 0.00,
      'Blno': ''
      };

      await SalesInformationDatabaseHelper2.instance.insertSale(transactionData);
      newAuto++; 
    }

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Saved successfully')),
    // );

    setState(() {
      _InvoicenoController.clear();
      // _dateController.clear();
      // _CustomerController.clear();
    });

  } catch (e) {
    print('Error while saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: $e')),
    );
  }
}

Future<double> calculateRealRate(double rate) async {
  try {
    if (companydata.isEmpty) {
      print("No company data available.");
      return rate;
    }
    Map<String, dynamic> selectedCompany = companydata.first;

    String companyName = selectedCompany['Sname']?.toString() ?? 'Unknown';
    String taxCalculation = selectedCompany['TaxCalculation']?.toString() ?? "PLUS";
    double tax = widget.salesCredit?.tax ?? 0.0;
    double cess = double.tryParse(selectedCompany['cess']?.toString() ?? '0.0') ?? 0.0;

    print("Selected Company: $companyName");
    print("Tax Calculation Type: $taxCalculation");
    double realRate = (taxCalculation == "MINUS") ? (100 * rate) / (100 + tax) : rate;
  
    print("Calculated Real Rate: $realRate");
    return realRate;
  } catch (e) {
    print("without tax realRate: $e");
    return rate; 
  }
}



void _saveDataSaleperti() async {
  try {
    final db = await SalesInformationDatabaseHelper.instance.database;
    final lastRow = await db.rawQuery(
      'SELECT * FROM Sales_Particulars ORDER BY Auto DESC LIMIT 1'
    );
final db2 = await SalesInformationDatabaseHelper2.instance.database;
     final lastRowinfo = await db2.rawQuery(
      'SELECT * FROM Sales_Information ORDER BY RealEntryNo DESC LIMIT 1'
    );
    int newAuto = 1;
    int newentryno=1;
    int Newentryno = 1;
    if (lastRowinfo.isNotEmpty) {
      final lastData = lastRowinfo.first;
      //newentryno = (lastData['EntryNo'] as int? ?? 0) + 1;
      newentryno = (lastData['RealEntryNo'] as int? ?? 0) + 1;
    }
    if (lastRow.isNotEmpty) {
      final lastData = lastRow.first;
      newAuto = (lastData['Auto'] as num? ?? 0).toInt();
     // Newentryno = (lastData['EntryNo'] as num? ?? 0).toInt();
    }

    final double finalAmt = widget.salesCredit?.totalAmt ?? 0.0;  
    final stockDetails = await StockDatabaseHelper.instance
        .getStockDetailsByName(widget.salesCredit!.itemName);
    final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance
        .getLedgerDetailsByName(_CustomerController.text);

    final String ledCode = ledgerDetails?['LedId']?.toString() ?? 'Unknown';
    final String itemcode = stockDetails?['itemcode']?.toString() ?? 'Unknown';
    final String retail = stockDetails?['retail']?.toString() ?? 'Unknown';
    final String sprate = stockDetails?['sprate']?.toString() ?? 'Unknown';
    final String wrate = stockDetails?['wsrate']?.toString() ?? 'Unknown';

    final stocksaleDetails = await SaleReferenceDatabaseHelper.instance
        .getStockSaleDetailsByName(itemcode);
    final unitsaleDetails = await SaleReferenceDatabaseHelper.instance
        .getStockunitDetailsByName(itemcode);

    final String Ucode = stocksaleDetails?['Uniquecode']?.toString() ?? 'Unknown';
    final String itemDisc = stocksaleDetails?['Disc']?.toString() ?? '0.0';
    final String prate = stocksaleDetails?['Prate']?.toString() ?? '0.0';
    final String rprate = stocksaleDetails?['RealPrate']?.toString() ?? '0.0';
    final String unit = unitsaleDetails?['Unit']?.toString() ?? 'Unknown';

    final double cgst = (widget.tax ?? 0.0) / 2;
    final double sgst = (widget.tax ?? 0.0) / 2;

    final double total = (widget.tot is String)
        ? double.tryParse(widget.tot as String) ?? 0.0
        : (widget.tot as double?) ?? 0.0;

    final double priceRate = double.tryParse(prate) ?? 0.0;
    final num quantity = widget.salesCredit?.qty ?? 0;
   final rate =widget.salesCredit?.rate?? 0;
    final double profit = total - (priceRate * quantity);
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



    final qtyToReduce = widget.salesCredit!.qty.toDouble();
    final itemName = widget.salesCredit!.itemName.toString();
    final itemCode = await StockDatabaseHelper.instance.getItemIdByItemName(itemName);
     final stockData = await StockDatabaseHelper.instance.getProductByItemId2(itemCode!);
     final currentQty = stockData!['Qty'] as double;
     final updatedQty = currentQty - qtyToReduce;

     if (updatedQty < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough stock for $itemName')),
      );
      return;
    }

    await StockDatabaseHelper.instance.updateProductQuantity(itemCode, updatedQty);

double realRate = await calculateRealRate(rate);
    final transactionData = {
      'DDate': _dateController.text,
      'EntryNo': newentryno ,
      'UniqueCode': Ucode,
      'ItemID': itemcode,
      'serialno': 0,
      'Rate': widget.salesCredit?.rate??0,  
      'RealRate': realRate,  
      'Qty': widget.salesCredit!.qty.toString(),  
      'freeQty': '0.0',
      'GrossValue': finalAmt.toString(),  
      'DiscPersent': widget.discPerc.toString(), 
      'Disc': widget.discnt.toString(),  
      'RDisc': '0.0',
      'Net': widget.net.toString(), 
      'Vat': '0.0',
      'freeVat': '0.0',
      'cess': '0.0',
      'Total': total.toString(), 
      'Profit': profit.toString(),  
      'Auto': newAuto.toString(),  
      'Unit': unit, 
      'UnitValue': '0.0',
      'Funit': '0',
      'FValue': '0',
      'commision': '0.0',
      'GridID': '0',
      'takeprintstatus': '0',
      'QtyDiscPercent': '0.0',
      'QtyDiscount': itemDisc,  
      'ScheemDiscPercent': '0.0',
      'ScheemDiscount': '0.0',
      'CGST': cgst.toString(), 
      'SGST': sgst.toString(),  
      'IGST': '0.0',
      'adcess': '0.0',
      'netdisc': '0.0',
      'taxrate': widget.tax.toString(),  
      'SalesmanId': '0',
      'Fcess': '0.0',
      'Prate': prate,  
      'Rprate': rprate, 
      'location': '0',
      'Stype': selectedID,

      'LC': '0.0',
      'ScanBarcode': '0',
      'Remark': '0',
      'FyID': selectedFyID.toString(),  
      'Supplier': '0',
      'Retail': retail,  
      'spretail': sprate,  
      'wsrate': wrate, 
    };

    await SalesInformationDatabaseHelper2.instance.insertParticular(transactionData);
    
    if (ledgerDetails != null) {
      print('Ledger details found and data saved.');
    } else {
      print('Ledger not found for name: ${_CustomerController.text}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved successfully')),
    );

    setState(() {});
  } catch (e) {
    print('Error while saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: $e')),
    );
  }
}

void _saveDataSaleperti2222222() async {
  try {
    final db = await SalesInformationDatabaseHelper.instance.database;
    final db2 = await SalesInformationDatabaseHelper2.instance.database;

    final lastRow = await db2.rawQuery(
      'SELECT * FROM Sales_Particulars ORDER BY Auto DESC LIMIT 1',
    );

    final lastRowinfo = await db2.rawQuery(
      'SELECT * FROM Sales_Information ORDER BY RealEntryNo DESC LIMIT 1',
    );

    int newAuto = 1;
    int newentryno = 1;

    if (lastRowinfo.isNotEmpty) {
      final lastData = lastRowinfo.first;
      newentryno = (lastData['RealEntryNo'] as int? ?? 0) + 1;
       
    }

    if (lastRow.isNotEmpty) {
      final lastData2 = lastRow.first;
      newAuto = (lastData2['Auto'] as int? ?? 0) + 1;
    }

    for (var tempDataEntry in widget.tempdata!) {
      final itemName = tempDataEntry['itemname'] ?? '';
      final double qty = double.tryParse(tempDataEntry['qty']?.toString() ?? '0.0') ?? 0.0;
      final double rate = double.tryParse(tempDataEntry['rate']?.toString() ?? '0.0') ?? 0.0;
      final double tax = double.tryParse(tempDataEntry['tax']?.toString() ?? '0.0') ?? 0.0;
      final double discount = double.tryParse(tempDataEntry['discount']?.toString() ?? '0.0') ?? 0.0;
      final double discountPercentage = double.tryParse(tempDataEntry['discountpercentage']?.toString() ?? '0.0') ?? 0.0;
      final double subtotal = double.tryParse(tempDataEntry['subtotal']?.toString() ?? '0.0') ?? 0.0;
      final double totalAmount = double.tryParse(tempDataEntry['total']?.toString() ?? '0.0') ?? 0.0;
      final double freeqty = double.tryParse(tempDataEntry['freeItem']?.toString() ?? '0.0') ?? 0.0;
      
      final String unit = tempDataEntry['unit'] ?? '';
      final String taxtype = tempDataEntry['taxtype'] ?? '';

      final double finalAmt = qty * rate;
      final double profit = finalAmt - (qty * rate);
      final double cgst = tax / 2;
      final double sgst = tax / 2;

      final stockDetails = await StockDatabaseHelper.instance.getStockDetailsByName(itemName);
      final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance.getLedgerDetailsByName(_CustomerController.text);
      final String ledCode = ledgerDetails?['LedId']?.toString() ?? 'Unknown';
      final String itemCode = stockDetails?['itemcode']?.toString() ?? 'Unknown';
      final String retail = stockDetails?['retail']?.toString() ?? 'Unknown';
      final String sprate = stockDetails?['sprate']?.toString() ?? 'Unknown';
      final String wrate = stockDetails?['wsrate']?.toString() ?? 'Unknown';

      final stocksaleDetails = await SaleReferenceDatabaseHelper.instance.getStockSaleDetailsByName(itemCode);
      final String Ucode = stocksaleDetails?['Uniquecode']?.toString() ?? 'Unknown';
      final String itemDisc = stocksaleDetails?['Disc']?.toString() ?? '0.0';
      final String prate = stocksaleDetails?['Prate']?.toString() ?? '0.0';
      final String rprate = stocksaleDetails?['RealPrate']?.toString() ?? '0.0';

      double realRate = await calculateRealRate(rate);

    Map<String, double> itemQuantities = {};

    for (var tempDataEntry in widget.tempdata!) {
      String itemName = tempDataEntry['itemname'] ?? '';
      double qty = double.tryParse(tempDataEntry['qty']?.toString() ?? '0.0') ?? 0.0;

      if (itemName.isNotEmpty) {
        itemQuantities[itemName] = (itemQuantities[itemName] ?? 0.0) + qty;
      }
    }

    for (var entry in itemQuantities.entries) {
      String itemName = entry.key;
      double totalQtyToReduce = entry.value;

      String? itemCode = await StockDatabaseHelper.instance.getItemIdByItemName(itemName);
      if (itemCode == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item not found: $itemName')),
        );
        return;
      }

      final stockData = await StockDatabaseHelper.instance.getProductByItemId2(itemCode);
      if (stockData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock data not found for item: $itemName')),
        );
        return;
      }
      double currentQty = stockData['Qty'] as double;
      double updatedQty = currentQty - totalQtyToReduce;

      if (updatedQty < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Not enough stock for $itemName')),
        );
        return;
      }
      await StockDatabaseHelper.instance.updateProductQuantity(itemCode, updatedQty);
    }

      final transactionData = {
        'DDate': _dateController.text,
        'EntryNo':updatedInno.toString(),
        'UniqueCode': Ucode,
        'ItemID': itemCode,
        'serialno': '',
        'Rate': rate.toString(),
        'RealRate': realRate.toString(),
        'Qty': qty.toString(),
        'freeQty':freeqty.toString(),
        'GrossValue': finalAmt.toString(),
        'DiscPersent': discountPercentage.toString(),
        'Disc': discount.toString(),
        'RDisc': '0.0',
        'Net': subtotal.toString(),
        'Vat': '0.0',
        'freeVat': '0.0',
        'cess': '0.0',
        'Total': totalAmount.toString(),
        'Profit': profit.toString(),
        'Auto': newAuto.toString(),
        'Unit': unit,
        'UnitValue': '0.0',
        'Funit': '0',
        'FValue': '0',
        'commision': '0.0',
        'GridID': '0',
        'takeprintstatus': '0',
        'QtyDiscPercent': '0.0',
        'QtyDiscount': itemDisc,
        'ScheemDiscPercent': '0.0',
        'ScheemDiscount': '0.0',
        'CGST': cgst.toString(),
        'SGST': sgst.toString(),
        'IGST': '0.0',
        'adcess': '0.0',
        'netdisc': '0.0',
        'taxrate': tax.toString(),
        'SalesmanId': '0',
        'Fcess': '0.0',
        'Prate': prate,
        'Rprate': rprate,
        'location': '0',
        'Stype': selectedID.toString(),
        'LC': '0.0',
        'ScanBarcode': '',
        'Remark': '',
        'FyID': "2",
        'Supplier': '',
        'Retail': retail,
        'spretail': sprate,
        'wsrate': wrate,
      };

      await SalesInformationDatabaseHelper2.instance.insertParticular(transactionData);
      newAuto++;
      newentryno++;
    }

    setState(() {});

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

    // await _saveLastInsertedIdToPayments(lastInsertedId, creditsale.customer);
    // await syncOpeningBalances(lastInsertedId);

    // Show success message and clear form fields
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved successfully')),
    );

    setState(() {
      _InvoicenoController.clear();
      // _salerateController.clear();
      // _CustomerController.clear();
      // _phonenoController.clear();
      // _totalamtController.clear();
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


void _saveDataSalepertiCash() async {
  try {
    final db = await SalesInformationDatabaseHelper.instance.database;
    final db2 = await SalesInformationDatabaseHelper2.instance.database;

    final lastRow = await db2.rawQuery(
      'SELECT * FROM Sales_Particulars ORDER BY Auto DESC LIMIT 1',
    );
    final lastRowinfo = await db2.rawQuery(
      'SELECT * FROM Sales_Information ORDER BY RealEntryNo DESC LIMIT 1',
    );
    int newAuto = 1;
    int newentryno = 1;

    if (lastRowinfo.isNotEmpty) {
      final lastData = lastRowinfo.first;
      newentryno = (lastData['RealEntryNo'] as int? ?? 0) + 1;
       
    }

    if (lastRow.isNotEmpty) {
      final lastData2 = lastRow.first;
      newAuto = (lastData2['Auto'] as int? ?? 0) + 1;
    }

    for (var tempDataEntry in widget.tempdataCASH!) {
      final itemName = tempDataEntry['itemname'] ?? '';
      final double qty = double.tryParse(tempDataEntry['qty']?.toString() ?? '0.0') ?? 0.0;
      final double rate = double.tryParse(tempDataEntry['rate']?.toString() ?? '0.0') ?? 0.0;
      final double tax = double.tryParse(tempDataEntry['tax']?.toString() ?? '0.0') ?? 0.0;
      final double discount = double.tryParse(tempDataEntry['discount']?.toString() ?? '0.0') ?? 0.0;
      final double discountPercentage = double.tryParse(tempDataEntry['discountpercentage']?.toString() ?? '0.0') ?? 0.0;
      final double subtotal = double.tryParse(tempDataEntry['subtotal']?.toString() ?? '0.0') ?? 0.0;
      final double totalAmount = double.tryParse(tempDataEntry['total']?.toString() ?? '0.0') ?? 0.0;
      final double freeqty = double.tryParse(tempDataEntry['freeItem']?.toString() ?? '0.0') ?? 0.0;
      
      final String unit = tempDataEntry['unit'] ?? '';
      final String taxtype = tempDataEntry['taxtype'] ?? '';

      final double finalAmt = qty * rate;
      final double profit = finalAmt - (qty * rate);
      final double cgst = tax / 2;
      final double sgst = tax / 2;

      final stockDetails = await StockDatabaseHelper.instance.getStockDetailsByName(itemName);
      final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance.getLedgerDetailsByName(_CustomerController.text);
      final String ledCode = ledgerDetails?['LedId']?.toString() ?? 'Unknown';
      final String itemCode = stockDetails?['itemcode']?.toString() ?? 'Unknown';
      final String retail = stockDetails?['retail']?.toString() ?? 'Unknown';
      final String sprate = stockDetails?['sprate']?.toString() ?? 'Unknown';
      final String wrate = stockDetails?['wsrate']?.toString() ?? 'Unknown';

      final stocksaleDetails = await SaleReferenceDatabaseHelper.instance.getStockSaleDetailsByName(itemCode);
      final String Ucode = stocksaleDetails?['Uniquecode']?.toString() ?? 'Unknown';
      final String itemDisc = stocksaleDetails?['Disc']?.toString() ?? '0.0';
      final String prate = stocksaleDetails?['Prate']?.toString() ?? '0.0';
      final String rprate = stocksaleDetails?['RealPrate']?.toString() ?? '0.0';

      double realRate = await calculateRealRate(rate);
      Map<String, double> itemQuantities = {};

    for (var tempDataEntry in widget.tempdataCASH!) {
      String itemName = tempDataEntry['itemname'] ?? '';
      double qty = double.tryParse(tempDataEntry['qty']?.toString() ?? '0.0') ?? 0.0;

      if (itemName.isNotEmpty) {
        itemQuantities[itemName] = (itemQuantities[itemName] ?? 0.0) + qty;
      }
    }

    for (var entry in itemQuantities.entries) {
      String itemName = entry.key;
      double totalQtyToReduce = entry.value;

      String? itemCode = await StockDatabaseHelper.instance.getItemIdByItemName(itemName);
      if (itemCode == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item not found: $itemName')),
        );
        return;
      }

      final stockData = await StockDatabaseHelper.instance.getProductByItemId2(itemCode);
      if (stockData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock data not found for item: $itemName')),
        );
        return;
      }
      double currentQty = stockData['Qty'] as double;
      double updatedQty = currentQty - totalQtyToReduce;

      if (updatedQty < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Not enough stock for $itemName')),
        );
        return;
      }
      await StockDatabaseHelper.instance.updateProductQuantity(itemCode, updatedQty);
    }

      final transactionData = {
        'DDate': _dateController.text,
        'EntryNo':updatedInno.toString(),
        'UniqueCode': Ucode,
        'ItemID': itemCode,
        'serialno': '0',
        'Rate': rate.toString(),
        'RealRate': realRate.toString(),
        'Qty': qty.toString(),
        'freeQty':freeqty.toString(),
        'GrossValue': finalAmt.toString(),
        'DiscPersent': discountPercentage.toString(),
        'Disc': discount.toString(),
        'RDisc': '0.0',
        'Net': subtotal.toString(),
        'Vat': '0.0',
        'freeVat': '0.0',
        'cess': '0.0',
        'Total': totalAmount.toString(),
        'Profit': profit.toString(),
        'Auto': newAuto.toString(),
        'Unit': unit,
        'UnitValue': '0.0',
        'Funit': '0',
        'FValue': '0',
        'commision': '0.0',
        'GridID': '0',
        'takeprintstatus': '0',
        'QtyDiscPercent': '0.0',
        'QtyDiscount': itemDisc,
        'ScheemDiscPercent': '0.0',
        'ScheemDiscount': '0.0',
        'CGST': cgst.toString(),
        'SGST': sgst.toString(),
        'IGST': '0.0',
        'adcess': '0.0',
        'netdisc': '0.0',
        'taxrate': tax.toString(),
        'SalesmanId': '0',
        'Fcess': '0.0',
        'Prate': prate,
        'Rprate': rprate,
        'location': '0',
        'Stype': selectedID.toString(),
        'LC': '0.0',
        'ScanBarcode': '0',
        'Remark': '0',
        'FyID': "2",
        'Supplier': '0',
        'Retail': retail,
        'spretail': sprate,
        'wsrate': wrate,
      };

      await SalesInformationDatabaseHelper2.instance.insertParticular(transactionData);
      newAuto++;
      newentryno++;
    }

    setState(() {});
    Fluttertoast.showToast(msg: 'Saved Succesfully');

  } catch (e) {
    print('Error while saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: $e')),
    );
  }
}


void _saveDataSaleinfor22Cash() async {
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
    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Date is required!')),
      );
      return;
    }
    
    

 for (var tempDataEntry in widget.tempdataCASH!) {
      final itemName = tempDataEntry['itemname'] ?? '';
      final qty = tempDataEntry['qty'] ?? 0.0;
      final rate = tempDataEntry['rate'] ?? 0.0;
      final tax = tempDataEntry['tax'] ?? 0.0;
      final discount = tempDataEntry['discount'] ?? 0.0;
      final discountPercentage = tempDataEntry['discountpercentage'] ?? 0.0;
      final unit = tempDataEntry['unit'] ?? '';
      final freeItem = tempDataEntry['freeItem'] ?? '';
      final subtotal = tempDataEntry['subtotal'] ?? '';
      final totalAmount = tempDataEntry['total'] ?? '';
      final taxtype = tempDataEntry['taxtype'] ?? '';
      
      final finalAmt = qty * rate; 
      final profit = finalAmt - (qty * rate);
      final _grandTotalcash = widget.tempdataCASH!.fold(0.0, (sum, item) => sum + (double.tryParse(item['total'].toString()) ?? 0.0));

      final double cgst = (tax ?? 0.0) / 2;
      final double sgst = (tax ?? 0.0) / 2;

      final String selectedDate = _dateController.text;
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
final double finalAmtfi = widget.grandtotal ?? 0.0;
      final transactionData = {
      'RealEntryNo': newAuto, 
      'EntryNo': _InvoicenoController.text, 
      'InvoiceNo': _InvoicenoController.text,
      'DDate':_dateController.text,
      'BTime':'1900-01-01 ' +
                DateFormat("H:m:s:S")
                    .format(DateTime.now())
                    .toString(),
      'Customer': _billnameController.text.toString(),
      'Add1': _CashphonenoController.text, 
      'Add2': _CashphonenoController.text,
      'Toname': _billnameController.text.toString(),
      'TaxType': taxtype.toString(), 
      'GrossValue': finalAmt,
      'Discount': discount,
      'NetAmount': subtotal.toString(),
      'cess': 0.00,
      'Total': totalAmount.toString(),
      'loadingcharge': 0.00,
      'OtherCharges': 0.00,
      'OtherDiscount': 0.00,
      'Roundoff': 0.00,
      'GrandTotal': _grandTotalcash,
      'SalesAccount': 0, 
      'SalesMan': 0, 
      'Location': 1, 
      'Narration': 0,
      'Profit': profit.toString(),
      'CashReceived': _cashRecieveController.text,
      'BalanceAmount': finalAmt,
      'Ecommision': 0.00,
      'labourCharge': 0.00,
      'OtherAmount': 0.00,
      'Type': 0,
      'PrintStatus': 0,
      'CNo': 0,
      'CreditPeriod': 0,
      'DiscPercent': 0.00,
      'SType': selectedID,
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
      'Add3': '',
      'Add4': '',
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
      'CashAccountID': 0,
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
      'TotalQty': qty.toString(), 
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

      await SalesInformationDatabaseHelper2.instance.insertSale(transactionData);
      newAuto++; 
    }

    Fluttertoast.showToast(msg: "Saved successfully");

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Saved successfully')),
    // );

    setState(() {
      _InvoicenoController.clear();
      // _dateController.clear();
      // _CustomerController.clear();
    });

  } catch (e) {
    print('Error while saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: $e')),
    );
  }
}
int updatedInno = 0; 
 void invoice() async {
    final db = await SalesInformationDatabaseHelper2.instance.database;
        final lastRow = await db.rawQuery(
      'SELECT * FROM Sales_Information ORDER BY RealEntryNo DESC LIMIT 1'
    );

    int lastEntryNo = lastRow.isNotEmpty ? (lastRow.first['EntryNo'] as int? ?? 0) : 0;
    int newInvoiceNo = lastEntryNo + 1; 
    setState(() {
      updatedInno = newInvoiceNo;
    });

    print('New Invoice Number: $updatedInno'); 
  }

List<String> Ratedetails=[
  'mrp','retail','wsrate','sprate','branch','tax'
];


String _balanceText = "0.00"; 
  double _balance = 0.0;
  String _balanceType = ''; 
 void _fetchBalance(String ledgerName) async {
    if (ledgerName.isEmpty) return;

    try {
      Map<String, dynamic> result = await LedgerTransactionsDatabaseHelper.instance.getLedgerBalance(ledgerName);

      if (result.containsKey('error')) {
        setState(() {
          _balanceText = result['error'];
        });
      } else {
        setState(() {
          _balance = (result['balance'] as double).abs();
          _balanceType = result['balanceType'];
          _balanceText = "${_balance.toStringAsFixed(2)} $_balanceType";
        });
      }
    } catch (e) {
      setState(() {
        _balanceText = "$e";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double _grandTotal = 0.0; 
    double _grandTotalcash = 0.0; 

void _calculateGrandTotal() {
  setState(() {
    _grandTotal = widget.tempdata!.fold(0.0, (sum, item) => sum + (double.tryParse(item['total'].toString()) ?? 0.0));
     _totalamtController.text = _grandTotal.toStringAsFixed(2);
  });
}
void _calculateGrandTotalcash() {
  setState(() {
     _grandTotalcash = widget.tempdataCASH!.fold(0.0, (sum, item) => sum + (double.tryParse(item['total'].toString()) ?? 0.0));
     _CashtotalamtController.text = _grandTotalcash.toStringAsFixed(2);
  });
}
     _totalamtController.addListener(_calculateGrandTotal);
     _CashtotalamtController.addListener(_calculateGrandTotalcash);
     void updateTotalAmount() {
    double qty = widget.salesCredit?.qty ?? 0.0;
    double rate = widget.salesCredit?.rate ?? 0.0;
    double tax = widget.salesCredit?.tax ?? 0.0;
    double finalamt=widget.salesCredit?.totalAmt??0.0;
    double saleRate = double.tryParse(_salerateController.text) ?? 0.0;
    double GrandTotal=widget.grandtotal??0.0;
    
        double totalAmt = finalamt + ((saleRate - rate) * qty);

       // _totalamtController.text = GrandTotal.toStringAsFixed(2);
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
_InvoicenoController.text=updatedInno.toString();
    return Scaffold(
      backgroundColor: Appcolors().scafoldcolor,
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.1,
        backgroundColor: Appcolors().maincolor,
        leading: Padding(
          padding:  EdgeInsets.only(top: screenHeight *0.025),
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
          padding:  EdgeInsets.only(top: screenHeight*0.023,right:screenWidth*0.05),
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
                width: screenWidth*0.05,
                height: screenHeight*0.025,
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
        padding: EdgeInsets.symmetric(horizontal: screenHeight*0.028,vertical:screenHeight*0.03 ),
        child: Row(children: [
          GestureDetector(
            onTap: (){},
            child: Container(
              width: screenWidth * 0.44,height: screenHeight*0.07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5),bottomLeft: Radius.circular(5)),
                color: Appcolors().Scfold
                
              ),
              child: Center(child: Text("Save & New",style: getFonts(15, Colors.black),)),
            ),
          ),
          GestureDetector(
            onTap: (){

               if(isCreditSelected){

               if(widget.tempdata != null && widget.tempdata!.isNotEmpty){
                _saveDataSaleperti2222222();
                _saveDataSaleinfor22multi();
              
                PreviewDiaalogue();
               }else{
              // _saveDataSaleperti();
              // _saveDataSaleinfor22();
              //  _saveData2();
               }
     
              }else{
                _saveDataSalepertiCash();
                _saveDataSaleinfor22Cash();
              }             
              },
            child: Container(
             width: screenWidth * 0.44,height: screenHeight*0.07,
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
 String name=_CustomerController.text;
 String OB = _OBcontroller.text;
  var item = widget.itemDetails?[0];
    List<String>? keys = item?.keys.toList();
  
  List<String> ledgerNamesAsString = ledgerIds.map((id) => id.toString()).toList();
   double additem_total=widget.grandtotal??0.0;
double cashReceived = double.tryParse(_cashRecieveController.text) ?? 0.0;
double balance = additem_total - cashReceived; 
_InvoicenoController.text=updatedInno.toString(); 
  return Column(
      children: [
        SizedBox(height: screenHeight*0.01,),
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
          SizedBox(height: screenHeight * 0.001),
          Container(
   height: screenHeight * 0.032, 
   width: screenWidth * 0.43,
   decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(5),
    color: Colors.white,
    border: Border.all(color: Appcolors().searchTextcolor),
  ),
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Text('$updatedInno',style: getFontsinput(14, Colors.black),),
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
          SizedBox(height: screenHeight * 0.001),
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
    SizedBox(height: screenHeight*0.01,),
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
          SizedBox(height: screenHeight * 0.001),
         Container(
  padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.01),
  height: screenHeight * 0.05,
  width: screenWidth * 0.9,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(5),
    color: Colors.white,
    border: Border.all(color: Appcolors().searchTextcolor),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
     Expanded(
  child: DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      dropdownColor: Appcolors().Scfold,
      style: getFontsinput(14, Colors.black),
      value: _selectedKey, 
      onChanged: (String? newValue) {
        setState(() {
          _selectedKey = newValue;
        });
      },
      items: Ratedetails.map<DropdownMenuItem<String>>((String rate) {
        return DropdownMenuItem<String>(
          value: rate,
          child: Text(rate.toUpperCase()),
        );
      }).toList(),
      menuMaxHeight: 150,
      isExpanded: true,
    ),
  ),
),
    ],
  ),
)

        ],
      ),
    ),
    SizedBox(height: screenHeight*0.01,),
    Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
              "Customer",
              style: formFonts(14, Colors.black),
            ),
        SizedBox(height: screenHeight * 0.001),
        Container(
          padding: EdgeInsets.symmetric(vertical: screenHeight*0.006),
                    height: screenHeight * 0.05,
                    width: screenWidth * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      border: Border.all(color: Appcolors().searchTextcolor),
                    ),
                    child: Padding(
              padding: EdgeInsets.only(left: screenHeight*0.015,bottom: screenHeight*0.01),
              child: SingleChildScrollView(
                 physics: NeverScrollableScrollPhysics(),
                    child:EasyAutocomplete(
      controller: _CustomerController ,  
      suggestions: names,

      inputTextStyle: getFontsinput(14, Colors.black),
      onSubmitted: (value) async {
          _fetchBalance(value); 
        if (!isCustomerSelected) {
          await _fetchLedgerDetails(value);
         
          await _fetchItems(customer: value);
           setState(() {
              _CustomerController.text = value;  
            
              isCustomerSelected = true;
              
            });
        }
      },
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.only(bottom: screenHeight*0.025),
      ),
      suggestionBackgroundColor: Appcolors().Scfold,
    ),
                  ),
            )
                  ),
      ],
    ),
        ),
            SizedBox(height: screenHeight*0.01,),
             Container(
            height: screenHeight * 0.05,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
            ),
            child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 9),
               child: Text("Others", style: DrewerFonts()),
             ),
              IconButton(
                icon: Icon(
                  _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded; 
                  });
                },
              ),
                       ],
                     ),
          ),
          SizedBox(height: screenHeight*0.01,),
          if (_isExpanded) 
          Row(
            children: [
             
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: screenHeight*0.024),
                child: Column(
                  children: [
                     _field("Adress", _adressController, screenWidth, screenHeight),
                     
                     _field("Phone Number", _phonenoController, screenWidth, screenHeight),
                
                  ],
                ),
              ),
            ],
          ),

             SizedBox(height: screenHeight*0.00001,),
             GestureDetector(
        onTap: () {
if(_CustomerController.text.isEmpty){
 ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please select Customer Name')),
    );
    return;
}

           setState(() {
          _selectedCustomer = "";
          isCustomerSelected = false;
        });
          Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Addpaymant(
                          salesCredit: widget.salesCredit,
                          customername: _CustomerController.text,
                          tempdataadd: widget.tempdata?? [],
                          RateKey: _selectedKey,
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
                    height: screenHeight *0.03,width: screenWidth *0.055,
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
       SizedBox(
  height: screenHeight * 0.3,
  child: Column(
    children: [
      Expanded(
        child: widget.tempdata != null && widget.tempdata!.isNotEmpty
            ? ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.022),
                itemCount: widget.tempdata!.length,
                itemBuilder: (context, index) {
                  final item = widget.tempdata![index];
                  int no=index + 1;
                  return GestureDetector(
                    onTap: (){

                                    if(widget.tempdata != null && widget.tempdata!.isNotEmpty){
                                      Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Addpaymant(
                                          salesCredit: widget.salesCredit,
                                          customername: _CustomerController.text,
                                          selectedItem: item,
                                          tempdataadd: widget.tempdata??[], 
                                        ),
                                      ),
                                    );
                                    }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.001),
                      width: screenWidth * 0.9,
                      child: Card(
                        color: Colors.grey.shade100,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: Colors.grey)
                                    ),
                                    child: Center(child: Text('$no',style: formFonts(10, Colors.black),)),
                                  ),
                                  SizedBox(width: screenHeight*0.02,),
                                  Text('${item['itemname']??''}',style: getFonts(13, Colors.black),),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Item Subtotal",
                                    style: formFonts(12, Colors.black),
                                  ),
                                  Text(
                                    "${item['qty'] ?? ''} × ${item['rate'] ?? ''} = ${item['subtotal'] ?? ''}",
                                    style: getFontsinput(12, Colors.black),
                                  ),
                                ],
                              ),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Diccount(%):${item['discountpercentage']?? ''}",
                                    style: formFonts(12, Colors.black),
                                  ),
                                  Text(
                                    "${item['discount'] ?? 'N/A'}",
                                    style: getFontsinput(12, Colors.black),
                                  ),
                                ],
                              ),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Tax(%):${item['tax'] ?? ''}",
                                    style: formFonts(12, Colors.black),
                                  ),
                                  Text(
                                    " ${item['taxvalue'] ?? ''}",
                                    style: getFontsinput(12, Colors.black),
                                  ),
                                ],
                              ),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total",
                                    style: formFonts(12, Colors.black),
                                  ),
                                  Text(
                                    "${item['total'] ?? 'N/A'}",
                                    style: getFontsinput(12, Colors.black),
                                  ),
                                ],
                              ),
                              
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  "NO Cart Items",
                  style: formFonts(14, Colors.grey),
                ),
              ),
      ),
    ],
  ),
),


          //    SizedBox(height: screenHeight*0.01,),
          //    Container(
          //   height: screenHeight * 0.05,
          //   width: screenWidth * 0.9,
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5),
          //     color: Colors.white,
          //     border: Border.all(color: Appcolors().searchTextcolor),
          //   ),
          //   child: Row(
          //              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //              children: [
          //    Padding(
          //      padding: const EdgeInsets.symmetric(horizontal: 9),
          //      child: Text("Others Amounts", style: DrewerFonts()),
          //    ),
          //     IconButton(
          //       icon: Icon(
          //         _isExpandedAmt ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          //         color: Colors.black,
          //       ),
          //       onPressed: () {
          //         setState(() {
          //           _isExpandedAmt = !_isExpandedAmt; 
          //         });
          //       },
          //     ),
          //              ],
          //            ),
          // ),
          SizedBox(height: screenHeight*0.01,),
          
          Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.symmetric(horizontal: screenHeight*0.01,vertical:screenHeight*0.01 ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey)
            ),
            child:Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("OB",style: getFonts(14, Colors.black),),
                    Container(
                      child: Row(
                        children: [
                           Text("₹",style: getFonts(14, Colors.black)),
                     Text(
                          '${_balanceText}',style: getFonts(14, Colors.black54),
                        )
                        ],
                      ),
                    )
                  ],
                ),
                 SizedBox(height: screenHeight*0.01,),
                 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Amount",style: getFonts(14, Colors.black),),
                    Container(
                      child: Row(
                        children: [
                           Text("₹",style: getFonts(14, Colors.black)),
                      Text(
                                    _totalamtController.text.isEmpty
                                        ? additem_total.toString()
                                        : _totalamtController.text,
                                    style: getFonts(14, Colors.black),
                                  ), 
                        ],
                      ),
                    )
                  ],
                ),
                 SizedBox(height: screenHeight*0.01,),
                 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Cash Recieved",style: getFonts(14, Colors.green.shade500),),
                    SizedBox(width: screenHeight*0.1,),
                    Expanded(
            child: TextField(
              controller: _cashRecieveController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding:  EdgeInsets.only(left: screenHeight*0.03,top: 12,right: screenHeight*0.05),
                  child: Text("₹", style: getFonts(14, Colors.black)),
                ),
                border: UnderlineInputBorder(
                  
                  borderSide: BorderSide(color: const Color.fromARGB(255, 66, 44, 44)),
                ),
              ),
            ),
          ),
                  ],
                ),
                 SizedBox(height: screenHeight*0.01,),
                 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Balance Due",style: getFonts(14, Colors.black),),
                    Container(
                      child: Row(
                        children: [
                           Text("₹",style: getFonts(14, Colors.black)),
                     Text(
                          '${balance.toString()}'
                        )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
                   SizedBox(height: screenHeight*0.2,),

      ],
    );
  }

  Widget _CashScreenContent(double screenHeight,double screenWidth) {
    List<String> ledgerNamesAsString = ledgerIds.map((id) => id.toString()).toList();
    double additem_total2=widget.grandtotalcash??0.0;
    _InvoicenoController.text=updatedInno.toString(); 
    double cashReceived = double.tryParse(_cashRecieveController.text) ?? 0.0;
    double balance=0.0;
    balance = additem_total2 - cashReceived; 
    return Column(
      children: [
        SizedBox(height: screenHeight*0.01,),
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
          SizedBox(height: screenHeight * 0.001),
          Container(
            padding: EdgeInsets.symmetric(horizontal: screenHeight*0.01,vertical: screenHeight*0.0025),
             height: screenHeight * 0.032, 
              width: screenWidth * 0.43,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
            ),
           child: Text("${updatedInno.toString()}",style: getFontsinput(14, Colors.black),),
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
          SizedBox(height: screenHeight * 0.001),
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
    SizedBox(height: screenHeight*0.01,),
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
          SizedBox(height: screenHeight * 0.001),
          Container(padding: EdgeInsets.symmetric(horizontal: screenHeight*0.01),
            height: screenHeight * 0.05,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
            ),
            child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
     Expanded(
  child: DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      dropdownColor: Appcolors().Scfold,
      style: getFontsinput(14, Colors.black),
      value: _selectedKey, 
      onChanged: (String? newValue) {
        setState(() {
          _selectedKey = newValue;
        });
      },
      items: Ratedetails.map<DropdownMenuItem<String>>((String rate) {
        return DropdownMenuItem<String>(
          value: rate,
          child: Text(rate.toUpperCase()),
        );
      }).toList(),
      menuMaxHeight: 150,
      isExpanded: true,
    ),
  ),
),
    ],
  )
          ),
        ],
      ),
    ),
    SizedBox(height: screenHeight*0.01,),
            _field("Billing Name", _billnameController, screenWidth, screenHeight),
            SizedBox(height: screenHeight*0.01,),
             _field("Phone Number", _CashphonenoController, screenWidth, screenHeight),
             SizedBox(height: screenHeight*0.001,),
             GestureDetector(
        onTap: () {
          Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Addpaymant2(
                          salesdebit: widget.salesDebit,
                          tempdataaddC: widget.tempdataCASH?? [],
                          RateKeyC: _selectedKey,
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
                    height: screenHeight *0.03,width: screenWidth *0.055,
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
                            ? additem_total2.toString()
                            : _CashtotalamtController.text,
                        style: getFonts(14, Colors.red),
                      ),                  ],
                ),
                
              ],)
            ],
          )
         ),
       ),
       SizedBox(
  height: screenHeight * 0.3,
  child: Column(
    children: [
      Expanded(
        child: widget.tempdataCASH != null && widget.tempdataCASH!.isNotEmpty
            ? ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.022),
                itemCount: widget.tempdataCASH!.length,
                itemBuilder: (context, index) {
                  final item = widget.tempdataCASH![index];

                  return GestureDetector(
                    onTap: (){

                                    if(widget.tempdataCASH != null && widget.tempdataCASH!.isNotEmpty){
                                      Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Addpaymant2(
                                          salesdebit: widget.salesDebit,
                                          billname: _billnameController.text,
                                          selectedItemC: item,
                                          tempdataaddC: widget.tempdataCASH??[], 
                                        ),
                                      ),
                                    );
                                    }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.001),
                      width: screenWidth * 0.9,
                      child: Card(
                        color: Colors.grey.shade100,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Column(
                            children: [
                              Text('${item['itemname']??''}',style: getFonts(13, Colors.black),),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Item Subtotal",
                                    style: formFonts(12, Colors.black),
                                  ),
                                  Text(
                                    " ${item['subtotal'] ?? 'N/A'}",
                                    style: getFontsinput(12, Colors.black),
                                  ),
                                ],
                              ),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Diccount(%):0.00",
                                    style: formFonts(12, Colors.black),
                                  ),
                                  Text(
                                    "${item['discount'] ?? 'N/A'}",
                                    style: getFontsinput(12, Colors.black),
                                  ),
                                ],
                              ),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Tax(%):${item['tax'] ?? ''}",
                                    style: formFonts(12, Colors.black),
                                  ),
                                  Text(
                                    " ${item['taxvalue'] ?? ''}",
                                    style: getFontsinput(12, Colors.black),
                                  ),
                                ],
                              ),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total",
                                    style: formFonts(12, Colors.black),
                                  ),
                                  Text(
                                    "${item['total'] ?? 'N/A'}",
                                    style: getFontsinput(12, Colors.black),
                                  ),
                                ],
                              ),
                              
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  "NO Cart Items",
                  style: formFonts(14, Colors.grey),
                ),
              ),
      ),
    ],
  ),
),

 SizedBox(height: screenHeight*0.01,),
          
          Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.symmetric(horizontal: screenHeight*0.01,vertical:screenHeight*0.01 ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey)
            ),
            child:Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("OB",style: getFonts(14, Colors.black),),
                    Container(
                      child: Row(
                        children: [
                           Text("₹",style: getFonts(14, Colors.black)),
                     Text(
                          '${_balanceText}',style: getFonts(14, Colors.black54),
                        )
                        ],
                      ),
                    )
                  ],
                ),
                 SizedBox(height: screenHeight*0.01,),
                 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Amount",style: getFonts(14, Colors.black),),
                    Container(
                      child: Row(
                        children: [
                           Text("₹",style: getFonts(14, Colors.black)),
                      Text(
                                    _CashtotalamtController.text.isEmpty
                                        ? additem_total2.toString()
                                        : _CashtotalamtController.text,
                                    style: getFonts(14, Colors.black),
                                  ), 
                        ],
                      ),
                    )
                  ],
                ),
                 SizedBox(height: screenHeight*0.01,),
                 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Cash Recieved",style: getFonts(14, Colors.green.shade500),),
                    SizedBox(width: screenHeight*0.1,),
                    Expanded(
            child: TextField(
              controller: _cashRecieveController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding:  EdgeInsets.only(left: screenHeight*0.03,top: 12,right: screenHeight*0.05),
                  child: Text("₹", style: getFonts(14, Colors.black)),
                ),
                border: UnderlineInputBorder(
                  
                  borderSide: BorderSide(color: const Color.fromARGB(255, 66, 44, 44)),
                ),
              ),
            ),
          ),
                  ],
                ),
                 SizedBox(height: screenHeight*0.01,),
                 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Balance Due",style: getFonts(14, Colors.black),),
                    Container(
                      child: Row(
                        children: [
                           Text("₹",style: getFonts(14, Colors.black)),
                     Text(
                          '${balance.toString()}'
                        )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
                   SizedBox(height: screenHeight*0.2,),
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
          SizedBox(height: screenHeight * 0.001),
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

void PreviewDiaalogue() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Appcolors().scafoldcolor,
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'If You want to sales Preview ?',
              style: getFonts(14, Colors.black),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomePageERP()));
              },
              child: Text(
                'Cancel',
                style: getFonts(15, Appcolors().maincolor),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SalesPreview(
                  tempdata: widget.tempdata,no: _InvoicenoController.text,date: _dateController.text,
                  add: _adressController.text,ob: openingBalance.toString(),cashreci: _cashRecieveController.text,
                  name:  _CustomerController.text,
                  )));
              },
              child: Text(
                'Yes',
                style: getFonts(15, Appcolors().maincolor),
              ),
            ),
          ],
        );
      },
    );
  }

}