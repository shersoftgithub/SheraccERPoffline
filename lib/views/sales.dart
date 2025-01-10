import 'dart:ffi';

import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/models/salescredit_modal.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/newLedgerDBhelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/options.dart';
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
  const SalesOrder({super.key, this.salesCredit,this.salesDebit});

  @override
  State<SalesOrder> createState() => _SalesOrderState();
}

class _SalesOrderState extends State<SalesOrder> {
  final TextEditingController _InvoicenoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _CustomerController = TextEditingController();
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
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
     
      });
    }
  }
    @override
  void initState() {
    super.initState();
    fetch_options();
    _fetchLedgerIds();
    _fetchLastInvoiceId();
    _fetchTodayItems();
   _InvoicenoController.text = ''; // set the default value or from your data
    _dateController.text = '';      // set default or fetched value
    _salerateController.text = '';  
    _CustomerController.text = '';
    _phonenoController.text = '';
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
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
 Future<void> _fetchTodayItems() async {
    final items = await SaleDatabaseHelper.instance.queryTodayRows();
    setState(() {
      todayItems = items;
    });
  }

    List<String> salesrate = [];
    Future<void>fetch_options()async{
      salesrate = await dbHelper.getOptionsByType('price_level');
      setState(() {
        
      });
    }
   List<int> ledgerIds = [];
   List <String> names=[];

Future<void> _fetchLedgerIds() async {
  List<int> ids = await DatabaseHelper.instance.getAllLedgerIds();
    List<String> cname = await DatabaseHelper.instance.getAllLedgerNames();

  setState(() {
    ledgerIds = ids;
    names=cname;
  });
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

void _fetchInvoiceData(int ledgerId) async {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  
  List<Map<String, dynamic>> ledgerData = await dbHelper.queryAllRows();
  
  var selectedLedger = ledgerData.firstWhere(
    (row) => row[DatabaseHelper.columnId] == ledgerId,
    orElse: () => {},
  );
  
  if (selectedLedger.isNotEmpty) {
    setState(() {
            _CustomerController.text = selectedLedger[DatabaseHelper.columnLedgerName].toString();
      _phonenoController.text = selectedLedger[DatabaseHelper.columnContact].toString();
    });
  }
}
void _fetchName_Data(String name) async {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  
  List<Map<String, dynamic>> ledgerData = await dbHelper.queryAllRows();
  
  var selectedLedger = ledgerData.firstWhere(
    (row) => row[DatabaseHelper.columnLedgerName] == name,
    orElse: () => {},
  );
  
  if (selectedLedger.isNotEmpty) {
    setState(() {
            _InvoicenoController.text = selectedLedger[DatabaseHelper.columnId].toString();

      _phonenoController.text = selectedLedger[DatabaseHelper.columnContact].toString();
    });
  }
}
void _saveData() async {
  final qty = widget.salesCredit!.qty.toDouble();
  final itemName = widget.salesCredit!.itemName.toString();

  // Fetch ItemId using itemName from product_registration
  String? itemId = await StockDatabaseHelper.instance.getItemIdByItemName(itemName);

  if (itemId == null) {
    // Handle case where no ItemId is found for the itemName
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No ItemId found for $itemName')),
    );
    return;
  }

  // Step 2: Fetch the stock data using the ItemId from the stock table
  Map<String, dynamic>? stockData = await StockDatabaseHelper.instance.getProductByItemId2(itemId);

  if (stockData != null) {
    // Get the current quantity of the item in stock
    double currentQty = stockData['Qty'] ?? 0.0;
    double updatedQty = currentQty - qty;

    if (updatedQty < 0) {
      // Handle case where not enough stock is available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough stock available for $itemName')),
      );
      return;
    }

    // Proceed with saving the sales data
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
      totalAmt: double.tryParse(_totalamtController.text) ?? 0.0,
    );

    int lastInsertedId = await SaleDatabaseHelper.instance.insert(creditsale.toMap());

    // Update the stock quantity after saving sales data
    await StockDatabaseHelper.instance.updateProductQuantity(stockData['id'], updatedQty);

    // Save to payments, sync opening balances, and reset fields as per your existing logic
    await _saveLastInsertedIdToPayments(lastInsertedId, creditsale.customer);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved successfully')));

    await syncOpeningBalances(lastInsertedId);

    setState(() {
      _InvoicenoController.clear();
      _salerateController.clear();
      _CustomerController.clear();
      _phonenoController.clear();
      _totalamtController.clear();
    });
  } else {
    // Handle case where the stock record is not found
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No stock record found for $itemName')),
    );
  }
}



void _saveDataCash()async{
  
  final Cashcreditsale=SalesCredit(
    
    invoiceId: nextInvoiceId,
    date: _dateController.text, 
    salesRate: double.tryParse(_CashsalerateController.text)??0.0,
     customer: _billnameController.text,
      phoneNo: _CashphonenoController.text,
      itemName: widget.salesDebit?.itemName ?? '',
        qty: widget.salesDebit!.qty,
         unit: widget.salesDebit!.unit,
          rate: widget.salesDebit!.rate,
           tax: widget.salesDebit!.tax, 
           totalAmt:double.parse(_CashtotalamtController.text));
          await SaleDatabaseHelper.instance.insert(Cashcreditsale.toMap());
           
   await syncOpeningBalancesCash();
    
}
 syncOpeningBalancesCash() async {
  final paymentHelper = SaleDatabaseHelper.instance;
  final ledgerHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> payments = await paymentHelper.queryAllRows();

  for (var payment in payments) {
    String ledgerName = payment['ledgerName'];
    double saleTotal = payment['total_amt'] ?? 0.0;

    Map<String, dynamic>? ledger =
        await ledgerHelper.getLedgerByName(ledgerName);

    if (ledger != null) {
      await ledgerHelper.updateLedgerBalance(ledgerName, saleTotal);
    }
  }

  print("Opening balances updated successfully!");
}
Future<void> _saveLastInsertedIdToPayments(int lastInsertedId, String customer) async {
  final ledgerHelper = DatabaseHelper.instance;

  Map<String, dynamic>? ledger = await ledgerHelper.getLedgerByName(customer);

  if (ledger != null) {
    await ledgerHelper.updateLedgerBalance(customer, lastInsertedId.toDouble());
  } else {
    print("Ledger not found for customer: $customer");
  }
}

Future<void> syncOpeningBalances(int lastInsertedId) async {
  final paymentHelper = SaleDatabaseHelper.instance;
  final ledgerHelper = DatabaseHelper.instance;

  Map<String, dynamic>? payment = await paymentHelper.getRowById(lastInsertedId);

  if (payment != null) {
    String ledgerName = payment['customer'];
    double saleTotal = payment['total_amt'] ?? 0.0;

    Map<String, dynamic>? ledger = await ledgerHelper.getLedgerByName(ledgerName);

    if (ledger != null) {
      double receivedBalance = ledger[DatabaseHelper.columnReceivedBalance] ?? 0.0;
      double payAmount = ledger[DatabaseHelper.columnPayAmount] ?? 0.0;
      double openingBalance=payAmount-receivedBalance;
      double updatedSaleTotal = (openingBalance - saleTotal).abs();

      await ledgerHelper.updateLedgerBalance(ledgerName, updatedSaleTotal);

      print("Updated ledger balance for $ledgerName: $updatedSaleTotal");
    } else {
      print("Ledger not found for customer: $ledgerName");
    }
  } else {
    print("No payment found for ID: $lastInsertedId");
  }

  print("Opening balance synced for the last record.");
}






  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
     void updateTotalAmount() {
    double qty = widget.salesCredit?.qty ?? 0.0;
    double rate = widget.salesCredit?.rate ?? 0.0;
    double tax = widget.salesCredit?.tax ?? 0.0;
    double saleRate = double.tryParse(_salerateController.text) ?? 0.0;
        double totalAmt = (qty * rate) + tax + ((saleRate - rate) * qty);
        _totalamtController.text = totalAmt.toStringAsFixed(2);
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
              _saveDataCash();
              _saveData();
              
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
  child: SingleChildScrollView(
    physics: NeverScrollableScrollPhysics(),
    child: EasyAutocomplete(
        controller: _InvoicenoController,
        suggestions: ledgerNamesAsString,
           inputTextStyle: getFontsinput(14, Colors.black),
        onSubmitted: (value) {
          int selectedId = ledgerIds[ledgerNamesAsString.indexOf(value)];
        _fetchInvoiceData(selectedId);  
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
                      controller: _salerateController,
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
                    child: EasyAutocomplete(
                        controller: _CustomerController,
                        suggestions: names,
                        inputTextStyle: getFontsinput(14, Colors.black),
                        onSubmitted: (value) {
    if (!names.contains(value)) {
      _showCreateItemDialog(value);  
    } else {
      _fetchName_Data(value);  
    }
  },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          
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
                        context, MaterialPageRoute(builder: (_) => Addpaymant2()));
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