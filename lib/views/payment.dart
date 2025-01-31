import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/models/paymant_model.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/payment_databsehelper.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/newLedger.dart';


class PaymentForm extends StatefulWidget {
  const PaymentForm({super.key});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
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
  // _fetchLedgerBalances();
   _fetchLedger();
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
    

  void onJobcardSelected(String value) {
    print('Selected Supplier: $value');
   
    _selectlnamesController.text = value;
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

  //  List <String>LedgerPaymant = [];
  //   Future<void> _fetchLedgerBalances() async {
  //   List<Map<String, dynamic>> LedgerPaymant = await DatabaseHelper.instance.getAllLedgersWithBalances();
  //   setState(() {
  //     LedgerPaymant = LedgerPaymant;  
  //   });
  // }

//   void _fetchBalanceForLedger(String selectedLedgerName) async {
//   DatabaseHelper dbHelper = DatabaseHelper.instance;
//   List<Map<String, dynamic>> ledgerData = await dbHelper.queryAllRows();
//   var selectedLedger = ledgerData.firstWhere(
//     (row) => row[DatabaseHelper.columnLedgerName] == selectedLedgerName,
//     orElse: () => {},
//   );

//   if (selectedLedger.isNotEmpty) {
//     double openingBalance = selectedLedger[DatabaseHelper.columnPayAmount] ?? 0.0;
//     double receivedBalance = selectedLedger[DatabaseHelper.columnReceivedBalance] ?? 0.0;
//     double balance = (selectedLedger[DatabaseHelper.columnOpeningBalance] ?? 0.0).abs();
//     double remainingBalance = openingBalance-receivedBalance;
//     setState(() {
//       _balanceController.text = balance.toStringAsFixed(2);
//     });
//   } else {
//     setState(() {
//       _balanceController.text = 'Ledger not found';
//     });
//   }
// }

void _saveData() async {
  try {
    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final double balance = double.tryParse(_balanceController.text) ?? 0.0;
    final double discount = double.tryParse(_DiscountController.text) ?? 0.0;
    final double total = balance - amount - discount;

    final ledgerDetails = await LedgerTransactionsDatabaseHelper.instance
        .getLedgerDetailsByName(_selectlnamesController.text);

    final String ledCode = ledgerDetails?['LedId'] ?? 'Unknown';

    final transactionData = {
      'atDate': _dateController.text.isNotEmpty ? _dateController.text : 'Unknown',
      'atLedCode': ledCode,
      'atDebitAmount': amount,
      'atCreditAmount': total,
      'atType': 'PAYMENT',
      'Caccount': _cashAccController.text,
      'atDiscount': _DiscountController.text,
      'atNaration': _narrationController.text,
      'atLedName': _selectlnamesController.text,
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




List<String> _itemSuggestions = [];
void _onItemnamecreateChanged(String value) async {
    if (!_itemSuggestions.contains(value)) {
     // _showCreateItemDialog( _cashAccController.text.trim(), );
    }
  }
  // void _fetchCashAcc() async {
  //   List<String> items = await PaymentDatabaseHelper.instance.getAllUniqueCashAccounts();
  //   setState(() {
  //     _itemSuggestions = items;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
double total = ((double.tryParse(_balanceController.text) ?? 0.0) - (double.tryParse(_amountController.text) ?? 0.0))-(double.tryParse(_DiscountController.toString()) ?? 0.0);

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
              "Payment",
              style: appbarFonts(screenWidth * 0.04, Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight*0.02),
            child: GestureDetector(
              onTap: () {
                _saveData();
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
           child: SingleChildScrollView(
             child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 5),
               child: EasyAutocomplete(
                   controller: _cashAccController,
                   suggestions: _itemSuggestions,
                      inputTextStyle: getFontsinput(14, Colors.black),
                   onSubmitted: (value) {
                     _onItemnamecreateChanged(value);  
                   },
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
        _paymentField("Amount", _amountController, screenWidth, screenHeight),
        SizedBox(height: screenHeight * 0.01),
        _paymentField("Discount", _DiscountController, screenWidth, screenHeight),
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
            _paymentField("Narration", _narrationController, screenWidth, screenHeight)
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
                    child: TextFormField(
                      textAlign: TextAlign.right,
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
  // void _showCreateItemDialog(String CassAcc,) {
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
