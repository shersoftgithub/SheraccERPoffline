import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/models/salescredit_modal.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_refer.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/salesDBHelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stockDB.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/more_home/settings.dart';
import 'package:sheraaccerpoff/views/sales.dart';

class Addpaymant2 extends StatefulWidget {
  final SalesCredit? salesCredit;
  final SalesCredit? salesdebit;
  final String? billname;
  final Map<String, dynamic>? selectedItemC; 
  final List<Map<String, dynamic>>? tempdataaddC; 
  final String? RateKeyC;
  const Addpaymant2({super.key,this.salesCredit,this.salesdebit,this.billname,this.selectedItemC,this.tempdataaddC,this.RateKeyC});

  @override
  State<Addpaymant2> createState() => _AddpaymantState();
}

class _AddpaymantState extends State<Addpaymant2> {
  final TextEditingController _itemnameController=TextEditingController();
  final TextEditingController _qtyController=TextEditingController();
  final TextEditingController _unitController=TextEditingController();
  final TextEditingController _rateController=TextEditingController();
  final TextEditingController _taxController=TextEditingController();
  final TextEditingController _DiscountController=TextEditingController();
  final TextEditingController _Discpercentroller=TextEditingController();
  final TextEditingController _FreeItemcentroller=TextEditingController();
  final TextEditingController _FreeQtycentroller=TextEditingController();
    final TextEditingController _totalamtController=TextEditingController();
    final TextEditingController _subtotalController=TextEditingController();
    final TextEditingController _taxvalueController=TextEditingController();
  List<String> _itemSuggestions = [];
    bool isCashSave = false;

  void _fetchItemNames() async {
    //List<String> items = await SaleDatabaseHelper.instance.getAllUniqueItemname();
    List<String> items = await SaleDatabaseHelper.instance.getAllUniqueItemname();
    setState(() {
      _itemSuggestions = items;
    });
  }
   List<String> productNames = [];
    Future<void> _fetchProductNames() async {
    List<String> products = await StockDatabaseHelper.instance.getAllItemNames();
        setState(() {
      productNames = products;
    });
  }
 void _saveData() {
  final itemName = _itemnameController.text.trim();
  final unit = _unitController.text.trim();
  final qty = double.tryParse(_qtyController.text.trim()) ?? 0.0;
  final rate = double.tryParse(_selectedRate.toString()) ?? 0.0;
  final tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
  final DiscPerc = double.tryParse(_Discpercentroller.text.trim()) ?? 0;
  final Discount = double.tryParse(_Discpercentroller.text.trim()) ?? 0;
  final totalAmt = (rate * qty) ;
      final taxvalue= (totalAmt*tax)/100;
final netamt=(totalAmt - taxvalue);
final PercenDisc = (totalAmt * DiscPerc)/100;
final finalAmt=(totalAmt - PercenDisc);
final ffiinalamt=(finalAmt + taxvalue);
  String taxStatus = selectedValue == 'With Tax' ? 'T' : 'NT';
  final ffiinalamt2 = taxStatus == 'NT' ? (ffiinalamt - taxvalue) : (finalAmt + taxvalue);

  final creditsale = SalesCredit(
    invoiceId: 0,
    date: "", 
    salesRate: 0.0,
    customer: "",
    phoneNo: "",
    itemName: itemName,
    qty: qty,
    unit: unit,
    rate: rate,
    tax: tax,
    totalAmt: ffiinalamt2,
  );
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>SalesOrder(salesCredit: creditsale,itemDetails:itemDetails,discPerc: DiscPerc,discnt : Discount,net :netamt,tot:ffiinalamt,tax:taxvalue,taxstatus: taxStatus,),
    ),
  );
}

void _saveDataCash() {
  final itemName = _itemnameController.text.trim();
  final unit = _unitController.text.trim();
  final qty = double.tryParse(_qtyController.text.trim()) ?? 0.0;
  final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
  final tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
  final totalAmt = (rate * qty) + tax;

  final Cashcreditsale = SalesCredit(
    invoiceId: 0,
    date: "", 
    salesRate: 0.0,
    customer: "",
    phoneNo: "",
    itemName: itemName,
    qty: qty,
    unit: unit,
    rate: rate,
    tax: tax,
    totalAmt: totalAmt,
  );
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>SalesOrder(salesDebit: Cashcreditsale,),
    ),
  );
}

void _saveDataCCAASSS() {
  final itemName = _itemnameController.text.trim();
  final unit = _unitController.text.trim();
  final qty = double.tryParse(_qtyController.text.trim()) ?? 0.0;
  final rate = double.tryParse(_selectedRate.toString()) ?? 0.0;
  final tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
  final DiscPerc = double.tryParse(_Discpercentroller.text.trim()) ?? 0;
  final Discount = double.tryParse(_Discpercentroller.text.trim()) ?? 0;
  final totalAmt = (rate * qty) ;
      final taxvalue= (totalAmt*tax)/100;
final netamt=(totalAmt - taxvalue);
final PercenDisc = (totalAmt * DiscPerc)/100;
final finalAmt=(totalAmt - PercenDisc);
final ffiinalamt=(finalAmt + taxvalue);
  String taxStatus = selectedValue == 'With Tax' ? 'T' : 'NT';
  final ffiinalamt2 = taxStatus == 'NT' ? (ffiinalamt - taxvalue) : (finalAmt + taxvalue);

  final Cashcreditsale = SalesCredit(
    invoiceId: 0,
    date: "", 
    salesRate: 0.0,
    customer: "",
    phoneNo: "",
    itemName: itemName,
    qty: qty,
    unit: unit,
    rate: rate,
    tax: tax,
    totalAmt: ffiinalamt2,
  );
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>SalesOrder(salesDebit: Cashcreditsale,itemDetails:itemDetails,discPercCC: DiscPerc,discntCC : Discount,netCC :netamt,totCC:ffiinalamt,taxCC:taxvalue,taxstatusCC: taxStatus,),
    ),
  );
}
FocusNode _focusNode = FocusNode();
@override
  void initState() {
    super.initState();
      _focusNode.addListener(() {
    if (_focusNode.hasFocus) {
      print('Focused on text field');
    }
  });
    _fetchItemNames(); 
     _fetchProductNames();
     _fetchSettings();
     _fetchstock();
    _DiscountController.addListener(_onDiscountChanged);
    
    _taxController.text;
    _rateController.text = _selectedRate ?? '';

  _qtyController.addListener(_onFieldsChanged);
  _rateController.addListener(_onFieldsChanged);

  _taxController.addListener(_onFieldsChanged);
_subtotalController.addListener(_onFieldsChanged);
_totalamtController.addListener(_onFieldsChanged);
_taxvalueController.addListener(_onFieldsChanged);
_taxvalueController.addListener(_onFieldsChanged);
       if (widget.selectedItemC != null) {
    if (widget.selectedItemC!.isNotEmpty) {
      _itemnameController.text = widget.selectedItemC!['itemname'] ?? '';
      _unitController.text = widget.selectedItemC!['unit'] ?? '';
      _qtyController.text = widget.selectedItemC!['qty'].toString();
      _rateController.text = widget.selectedItemC!['rate'].toString();
     if (widget.selectedItemC != null && widget.selectedItemC!.isNotEmpty) {
  _DiscountController.text = widget.selectedItemC!['discount'].toString();
  _Discpercentroller.text = widget.selectedItemC!['discountpercentage'].toString();
}
      _taxController.text = widget.selectedItemC!['tax'].toString();
      _subtotalController.text = widget.selectedItemC!['subtotal'].toString();
      _totalamtController.text = widget.selectedItemC!['total'].toString();
      _taxvalueController.text = widget.selectedItemC!['taxvalue'].toString();
        selectedValue = widget.selectedItemC!['taxtype'].toString();
    }
  }
  _Discpercentroller.addListener(_onPercentChanged);
temporaryData = widget.tempdataaddC ?? [];
  if (temporaryData.isNotEmpty) {
    _calculateGrandTotal();
  }
  
  }
  

void _onFieldsChanged() {
  if (_isUpdating) return;

  setState(() {
    _isUpdating = true;
    double qty = double.tryParse(_qtyController.text.trim()) ?? 0.0;
    double rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    double discount = double.tryParse(_DiscountController.text.trim()) ?? 0.0;
    double discountPercent = double.tryParse(_Discpercentroller.text.trim()) ?? 0.0;
    double tax = double.tryParse(_taxController.text.trim()) ?? 0.0;

    if (qty == 0 || rate == 0) {
      _clearControllers();
      _isUpdating = false;
      return;
    }

    double subtotal = qty * rate;
    double discountAmount = 0.0;

    // Handle discount percentage to discount amount conversion only when percentage exists
    if (_Discpercentroller.text.isNotEmpty && discountPercent > 0 && discountPercent <= 100) {
      discountAmount = (subtotal * discountPercent) / 100;
      _updateTextController(_DiscountController, discountAmount, allowManualEdit: true);
    } else if (_DiscountController.text.isNotEmpty) {
      discountAmount = discount;
      double calculatedPercent = (subtotal > 0) ? (discount / subtotal) * 100 : 0;
      if (calculatedPercent.isFinite && calculatedPercent >= 0 && calculatedPercent <= 100) {
        _updateTextController(_Discpercentroller, calculatedPercent, allowManualEdit: true);
      }
    }

    // Calculate taxable amount
    double taxableAmount = (subtotal - discountAmount).clamp(0, double.infinity);

    // Skip tax value calculation if not needed (editing time)
    double taxValue = 0.0;
    if (selectedValue == 'With Tax') {
      if (_taxController.text.isNotEmpty) {
        taxValue = (taxableAmount * tax / 100);
      }
    }

    // Calculate total amount
    double totalAmount = taxableAmount + taxValue;
    totalAmount = totalAmount.isFinite ? totalAmount : 0.0;

    // Update controllers safely
    _updateTextController(_subtotalController, subtotal);
    _updateTextController(_taxvalueController, taxValue);
    _updateTextController(_totalamtController, totalAmount);

    _isUpdating = false;
  });
}

void _clearControllers() {
  _subtotalController.clear();
  _taxvalueController.clear();
  _totalamtController.clear();
  _DiscountController.clear();
  _Discpercentroller.clear();
}

void _updateTextController(TextEditingController controller, double value, {bool allowManualEdit = false}) {
  String newText = value.isFinite ? value.toStringAsFixed(2) : "0.00";
  if (allowManualEdit && controller.text.isNotEmpty && controller.text != "0") return;
  if (controller.text != newText) {
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}



     List<String> items = [];
Future<void> _fetchstock() async {
  List<String> itemids = await StockDatabaseHelper.instance.getAllItemcode();

  setState(() {
    items = itemids;

  });
}

  void _onItemnameChanged(String value) async {
  List<String> items = await SaleDatabaseHelper.instance.getAllUniqueItemname();
  setState(() {
    _itemSuggestions = items.where((item) => item.contains(value)).toList();
  });
}
 void _onItemnamecreateChanged(String value) async {
    if (!_itemSuggestions.contains(value)) {
      _showCreateItemDialog(value, _unitController.text.trim(), double.tryParse(_qtyController.text.trim()) ?? 0.0,
          double.tryParse(_rateController.text.trim()) ?? 0.0, double.tryParse(_taxController.text.trim()) ?? 0.0,
          (double.tryParse(_rateController.text.trim()) ?? 0.0) * (double.tryParse(_qtyController.text.trim()) ?? 0.0));
    }
  }


  String? _selectedRate;
  List<Map<String, String>> itemDetails = [];
Future<void> _onItemnameChanged2(String value) async {
  if (value.isEmpty) {
    setState(() {
      itemDetails = [];
      _selectedRate = null;
    });
    return;
  }

  List<Map<String, String>> details = await StockDatabaseHelper.instance.getItemDetailsByName(value);

  setState(() {
    itemDetails = details.isNotEmpty ? details : [];
    
    if (details.isNotEmpty && widget.RateKeyC != null) {
      if (details[0].containsKey(widget.RateKeyC!.toLowerCase())) {
        _selectedRate = details[0][widget.RateKeyC!.toLowerCase()];
       _rateController.text=_selectedRate!;
      } else {
        _selectedRate = null; 
      }
    } else {
      _selectedRate = null;
    }
  });

  if (details.isNotEmpty) {
    _taxController.text = details[0]["tax"] ?? "N/A"; 
  }
}






  void _onRateSelected(String? selectedRate) {
  setState(() {
    _selectedRate = selectedRate;
    _rateController.text = selectedRate ?? '';
  });
}
 bool _isDropdownVisible = false;
 bool _isDropdownVisible2 = false;
bool _isUpdating = false;
void _onPercentChanged() {
  if (_isUpdating) return;

  final rate = double.tryParse(_selectedRate.toString()) ?? 0.0;
  final qty = double.tryParse(_qtyController.text.trim()) ?? 1.0;
  final totalAmt = rate * qty;

  double percValue = double.tryParse(_Discpercentroller.text.trim()) ?? 0.0;

  if (_Discpercentroller.text.isEmpty) {
    // If the PercentageController is cleared, don't perform calculations or update the discount
    _DiscountController.text = ''; // Clear discount controller
  } else if (totalAmt > 0) {
    setState(() {
      _isUpdating = true;

      // Calculate discount amount based on percentage
      final discountAmt = (totalAmt * percValue) / 100;
      _DiscountController.text = discountAmt.toStringAsFixed(2);

      _isUpdating = false;
    });
  } else {
    _DiscountController.text = '0.00'; // Default discount to 0 if no total amount
  }
}
Future<void> _validateQuantity( ) async {
  List<Map<String, dynamic>> items = await StockDatabaseHelper.instance.getItemDetails();
  String enteredItem = _itemnameController.text.trim();
  double enteredQty = double.tryParse(_qtyController.text) ?? 0;

  for (var item in items) {
    if (item['itemname'] == enteredItem) {
      double availableQty = item['stockQty'] ?? item['productQty'] ?? 0;

      if (enteredQty > availableQty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insufficient stock! Available: $availableQty')),
        );
        _qtyController.clear(); 
      }
      return;
    }
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Item not found in stock!')),
  );
}
  
 
void _onDiscountChanged() {
  if (_isUpdating) return;
  final rate = double.tryParse(_selectedRate ?? '0') ?? 0.0;
  final qty = double.tryParse(_qtyController.text.trim()) ?? 1.0;
  final totalAmt = rate * qty;

  double discountAmt = double.tryParse(_DiscountController.text.trim()) ?? 0.0;

  if (_DiscountController.text.isEmpty) {
    _Discpercentroller.text = ''; 
  } else if (totalAmt > 0) {
    setState(() {
      _isUpdating = true;

      final percValue = (discountAmt / totalAmt) * 100;

      if (percValue.isFinite && percValue >= 0 && percValue <= 100) {
        _Discpercentroller.text = percValue.toStringAsFixed(2);
      } else {
        _Discpercentroller.text = ''; 
      }

      _isUpdating = false;
    });
  } else {
    _Discpercentroller.text = ''; 
  }
}


  String? selectedValue;

  List<String> dropdownItems = ['With Tax', 'Without Tax'];


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
   bool _isKeyFreeUtemEnabled() {
  return settings.any((element) =>
      element['Name'] == 'KEY FREE ITEM' && element['Status'] == '1');
}
  bool _isKeyFreeQtyEnabled() {
  return settings.any((element) =>
      element['Name'] == 'KEY FREE QTY IN SALE' && element['Status'] == '1');
}
 bool _isKeyItembycodeEnabled() {
  return settings.any((element) =>
      element['Name'] == 'KEY ITEM BY CODE' && element['Status'] == '1');
}
 bool _isKeyLockSaleRateEnabled() {
  return settings.any((element) =>
      element['Name'] == 'KEY LOCK SALES RATE' && element['Status'] == '1');
}
bool _isKeyLockSaleDiscEnabled() {
  return settings.any((element) =>
      element['Name'] == 'KEY LOCK SALES DISCOUNT' && element['Status'] == '1');
}
bool _isKeyLockMinSaleRateEnabled() {
  return settings.any((element) =>
      element['Name'] == 'KEY LOCK MINIMUM SALES RATE' && element['Status'] == '1');
}




String _getItemNameFromFullString(String fullString) {
  int parenthesisIndex = fullString.indexOf('(');
    if (parenthesisIndex != -1) {
    return fullString.substring(0, parenthesisIndex).trim();
  } else {
    return fullString;
  }
}


double _grandTotal = 0.0; 

void _calculateGrandTotal() {
  setState(() {
    _grandTotal = temporaryData.fold(0.0, (sum, item) => sum + (double.tryParse(item['total'].toString()) ?? 0.0));
  });
}

int? selectedItemIndex;
List<Map<String, dynamic>> temporaryData = [];

void _addDataToTemporaryList() {
  if (_itemnameController.text.isNotEmpty && _qtyController.text.isNotEmpty && _rateController.text.isNotEmpty) {
    setState(() {
      
      Map<String, dynamic> newItem = {
        'itemname': _itemnameController.text,
        'qty': double.tryParse(_qtyController.text) ?? 0.0,
        'rate': double.tryParse(_rateController.text) ?? 0.0,
        'tax': double.tryParse(_taxController.text) ?? 0.0,
        'discount': double.tryParse(_DiscountController.text) ?? 0.0,
        'discountpercentage': double.tryParse(_Discpercentroller.text) ?? 0.0,
        'unit': _unitController.text,
        'freeItem': _FreeItemcentroller.text,
        'subtotal': _subtotalController.text,
        'total': _totalamtController.text,
        'taxtype': selectedValue.toString(),
        'taxvalue': _taxvalueController.text,
        'cusname':widget.billname.toString()
      };

      if (selectedItemIndex != null) {
        temporaryData[selectedItemIndex!] = newItem;
        selectedItemIndex = null; 
      } else {
        temporaryData.add(newItem);
      }
    });

    _calculateGrandTotal();
    _itemnameController.clear();
    _qtyController.clear();
    _rateController.clear();
    _taxController.clear();
    _DiscountController.clear();
    _Discpercentroller.clear();
    _subtotalController.clear();
    _totalamtController.clear();
    _unitController.clear();
    _FreeItemcentroller.clear();
    _FreeQtycentroller.clear();
  }
}

void _calculateSubtotal() {
  double rate = double.tryParse(_rateController.text) ?? 0.0;
  int qty = int.tryParse(_qtyController.text) ?? 0;
  var tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
  double discount = double.tryParse(_Discpercentroller.text) ?? 0.0;
  final totalAmt = (rate * qty) ;
var taxvalue= (totalAmt*tax)/100;
  double subtotal = rate * qty;
  double discountAmount = (subtotal * discount) / 100;
  double total = subtotal - discountAmount + taxvalue;

  setState(() {
    _subtotalController.text = subtotal.toStringAsFixed(2);
    _totalamtController.text = total.toStringAsFixed(2);
    _taxvalueController.text = taxvalue.toStringAsFixed(2);
  });
}

void _editDataInTemporaryList() {
  if (widget.selectedItemC != null) {
    int index = temporaryData.indexWhere(
      (item) => item['itemname'] == widget.selectedItemC!['itemname'],
    );

    if (index != -1) {
      temporaryData[index] = {
        'itemname': widget.selectedItemC!['itemname'],
        'qty': double.tryParse(_qtyController.text) ?? 0,
        'rate': double.tryParse(_rateController.text) ?? 0.0,
        'tax': double.tryParse(_taxController.text) ?? 0.0,
        'discount': double.tryParse(_DiscountController.text) ?? 0.0,
        'discountpercentage': double.tryParse(_Discpercentroller.text) ?? 0.0,
        'subtotal': double.tryParse(_subtotalController.text) ?? 0.0,
        'total': double.tryParse(_totalamtController.text) ?? 0.0,
        'taxvalue': double.tryParse(_taxvalueController.text) ?? 0.0,
        'taxtype': selectedValue.toString(),
      };
    }
    setState(() {
      _calculateGrandTotal();
    });

    Future.delayed(Duration(milliseconds: 100), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SalesOrder(
            cusname: widget.billname,
            grandtotal: _grandTotal, 
            tempdata: temporaryData,
          ),
        ),
      );
    });
  }
}

  @override
  Widget build(BuildContext context) {
     final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

 final qty = double.tryParse(_qtyController.text.trim()) ?? 0.0;
  final rate = double.tryParse(_selectedRate.toString()) ?? 0.0;
  var tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
  final DiscPerc = double.tryParse(_Discpercentroller.text.trim()) ?? 0;
  final totalAmt = (rate * qty) ;
      var taxvalue= (totalAmt*tax)/100;
final netamt=(totalAmt - taxvalue);
final PercenDisc = (totalAmt * DiscPerc)/100;
//_Discpercentroller.text = PercenDisc.toStringAsFixed(2);

 if (selectedValue == 'Without Tax') {
  final tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
  taxvalue = 0; 
} else if (selectedValue == 'With Tax') {
  final tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
  taxvalue = (totalAmt * tax) / 100; 
}
  final finalAmt=((totalAmt - PercenDisc)+taxvalue);
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
              "Add Item To Sale",
              style: appbarFonts(screenHeight * 0.02, Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 10),
            child: PopupMenuButton<String>(
              onSelected: (String selectedItem) {
                if (selectedItem == 'Rates') {
                  _showRatesDialog();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'Rates',
                    child: Text('Rates'),
                  ),
                  PopupMenuItem<String>(
                    value: 'Others',
                    child: Text('Others'),
                  ),
                ];
              },
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
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
                  "Item Name",
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
              child: SingleChildScrollView(
                child: EasyAutocomplete(
                  inputTextStyle: getFontsinput(14, Colors.black),
                  suggestionBackgroundColor: Appcolors().Scfold,
                    controller: _itemnameController,
                    suggestions: _isKeyItembycodeEnabled() ? items : productNames,
                    onChanged: (value) {
    _onItemnameChanged2(value); 
  },
  onSubmitted: (value) {
    _onItemnameChanged2(value); 
  },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: screenHeight*0.01,vertical: 8),
                    ),
                  ),
              ),
            ),
           
          ],
        ),
            ),
            SizedBox(height: screenHeight*0.02,),
          Container(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
                  
                  'Quantity',
                  style: formFonts(14, Colors.black),
                ),
            SizedBox(height: screenHeight * 0.01),
            Container(
               height: screenHeight * 0.05, 
              width: screenWidth * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                border: Border.all(color: Appcolors().searchTextcolor),
              ),
               child: TextFormField(
  style: getFontsinput(14, Colors.black),
  controller: _qtyController,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    border: InputBorder.none,
    contentPadding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.015, horizontal: screenHeight * 0.01),
  ),
  onChanged: (value) async {
    await _validateQuantity();
    _calculateSubtotal();
  } ,
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
                  
                  'Unit',
                  style: formFonts(14, Colors.black),
                ),
            SizedBox(height: screenHeight * 0.01),
            GestureDetector(
              child: Container(
                 height: 35, 
                width: 173,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                  border: Border.all(color: Appcolors().searchTextcolor),
                ),
                child: TextFormField(
                         controller: _unitController,
                          style: getFontsinput(14,Colors.black),
                          obscureText: false,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: screenHeight*0.015,horizontal: screenHeight*0.01),
                          ),
                        ),
              ),
            ),
          ],
        ),
            )
              ],
            ),
          ),
        
          SizedBox(height: screenHeight*0.02,),
          Container(
            child: SingleChildScrollView(
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                    
                    'Rate(Price/unit)',
                    style: formFonts(14, Colors.black),
                  ),
              SizedBox(height: screenHeight * 0.01),
                      GestureDetector(
                        child: Container(
                height: screenHeight * 0.05, 
              width: screenWidth * 0.45,
              decoration: BoxDecoration(
                border: Border.all(color: Appcolors().searchTextcolor),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 7,vertical:screenHeight*0.02,),
                child: TextField(
  controller: _rateController, 
  style: getFontsinput(14, Colors.black),
  readOnly: _isKeyLockSaleRateEnabled(), 
  enabled: !_isKeyLockSaleRateEnabled(),
  decoration: InputDecoration(
    border: InputBorder.none,
    
  ),
  keyboardType: TextInputType.number,
  onChanged: (value) {
  double enteredRate = double.tryParse(value) ?? 0.0;
  double mrpRate = double.tryParse(itemDetails[0]["mrp"]?.toString() ?? "0") ?? 0.0;
_calculateSubtotal();
  if (_isKeyLockMinSaleRateEnabled()) {
    if (enteredRate > mrpRate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _rateController.text = mrpRate.toString();
      });

      _selectedRate = mrpRate.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rate cannot exceed MRP ($mrpRate)'),
        ),
      );
    } else {
      _selectedRate = value;
    }
  } else if (_isKeyLockSaleRateEnabled()) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rateController.text = _selectedRate!;
    });
  } else {
    _selectedRate = value;
  }
}

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
                    
                    'Tax',
                    style: formFonts(14, Colors.black),
                  ),
              SizedBox(height: screenHeight * 0.01),
             Container(
       height: screenHeight * 0.05, 
              width: screenWidth * 0.45, 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        border: Border.all(color: Colors.grey), 
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: DropdownButton<String>(
          value: selectedValue,
          dropdownColor: Appcolors().Scfold,
          onChanged: (String? newValue) {
  setState(() {
  selectedValue = newValue;

 if (selectedValue == 'Without Tax') {
  final tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
  taxvalue = 0; 
} else if (selectedValue == 'With Tax') {
  final tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
  taxvalue = (totalAmt * tax) / 100; 
}
});

},

          underline: SizedBox(), 
          isExpanded: true, 
          items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            
              value: value,
              child: Text(
                value,
                style: getFontsinput(14, Colors.black), 
              ),
            );
          }).toList(),
        ),
      ),
    )
                        ],
                      ),
              )
                ],
              ),
            ),
          ),
           SizedBox(height: screenHeight*0.02,),
       Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_isKeyFreeUtemEnabled())
            Container(
              child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                
                'Free Item',
                style: formFonts(14, Colors.black),
              ),
                        SizedBox(height: screenHeight * 0.01),
                        GestureDetector(
            child: Container(
               height: 35, 
              width: 173,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                border: Border.all(color: Appcolors().searchTextcolor),
              ),
              child: TextFormField(
                       controller: _FreeItemcentroller,
                        style: getFontsinput(14,Colors.black),
                        obscureText: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: screenHeight*0.015,horizontal: screenHeight*0.01),
                        ),
                      ),
            ),
                        ),
                      ],
                    ),
            ),
              if (_isKeyFreeQtyEnabled())
            Container(
              child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                
                'Free Qty',
                style: formFonts(14, Colors.black),
              ),
                        SizedBox(height: screenHeight * 0.01),
                        GestureDetector(
            child: Container(
               height: 35, 
              width: 173,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                border: Border.all(color: Appcolors().searchTextcolor),
              ),
              child: TextFormField(
                       controller: _FreeQtycentroller,
                        style: getFontsinput(14,Colors.black),
                        obscureText: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: screenHeight*0.015,horizontal: screenHeight*0.01),
                        ),
                      ),
            ),
                        ),
                      ],
                    ),
            ),
        ],
       ),
        
       SizedBox(height: screenHeight*0.04,),
      Container(
        padding: EdgeInsets.symmetric(horizontal: screenHeight*0.024),
        child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Totals & Taxes",style: getFonts(14, Colors.black),),
    SizedBox(height: screenHeight*0.01,),
    Divider(color: Appcolors().searchTextcolor,),
    SizedBox(height: screenHeight*0.01,),
    Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sub Total(Rate x Qty)",style: getFonts(12, Colors.black),),
              Column(children: [
                Row(
                  children: [
                    Text("₹",style: getFonts(14, Colors.black)),
 Text("${totalAmt}",style: getFonts(12, Colors.black),
                        
                      ),                  ],
                ),
               
              ],)
            ],
          ),
         ),
         SizedBox(height: screenHeight*0.012,),
          Visibility(
            visible: !_isKeyLockSaleDiscEnabled(),
            child: Container(
                    child: Row(
                      children: [
                        Text("Discount",style: getFonts(12, Colors.black),),
                        SizedBox(width: screenHeight*0.053,),
                        Container(
                          child: Row(
                            children: [
                              Container(
                                height: screenHeight*0.05,width: screenWidth*0.2,
                                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),topLeft: Radius.circular(5)),
                    color: Colors.white,
                    border: Border.all(color: Appcolors().searchTextcolor),
                  ),
                                child: TextFormField(
                    style: getFontsinput(14, Colors.black),
                           controller: _Discpercentroller,
                            keyboardType: TextInputType.number,
                            obscureText: false,
                           // onChanged: _onRateChanged,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: screenHeight*0.018,horizontal: screenHeight*0.01),
                            ),
                          ),
                              ),
                             
                              Container(
                                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(5),topRight: Radius.circular(5)),
                    color: Colors.white,
                    border: Border.all(color: Appcolors().searchTextcolor),
                  ),
                               height: screenHeight*0.05,width: screenWidth*0.1,
                                child:  Icon(Icons.percent),
                              ),
                            ],
                          ),
                        ),
                         SizedBox(width: screenHeight*0.02,),
                        Container(
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                     borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),topLeft: Radius.circular(5)),
                    color: Colors.white,
                    border: Border.all(color: Appcolors().searchTextcolor),
                  ),
                               height: screenHeight*0.05,width: screenWidth*0.1,
                                child:  Icon(Icons.currency_rupee),
                              ),
                              Container(
                                height: screenHeight*0.05,width: screenWidth*0.2,
                                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(5),topRight: Radius.circular(5)),
                    color: Colors.white,
                    border: Border.all(color: Appcolors().searchTextcolor),
                  ),
                                child: TextFormField(
                    style: getFontsinput(14, Colors.black),
                           controller: _DiscountController,
                            keyboardType: TextInputType.number,
                            obscureText: false,
                           // onChanged: _onRateChanged,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: screenHeight*0.018,horizontal: screenHeight*0.01),
                            ),
                          ),
                              ),
                             
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
          ),
                SizedBox(height: screenHeight*0.01,),
                Container(
                  child: Row(
                    children: [
                      Text("Tax % ",style: getFonts(12, Colors.black),),
                      SizedBox(width: screenHeight*0.075,),
                      Container(
                        child: Row(
                          children: [
                            Container(
                            padding: EdgeInsets.symmetric(vertical: screenHeight*0.01,horizontal: screenHeight*0.01),

                              height: screenHeight*0.05,width: screenWidth*0.2,
                              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),topLeft: Radius.circular(5)),
                  color: Colors.white,
                  border: Border.all(color: Appcolors().searchTextcolor),
                ),
                              child: Text("${tax}",style: getFontsinput(14, Colors.black),),
                            ),
                           
                            Container(
                              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(5),topRight: Radius.circular(5)),
                  color: Colors.white,
                  border: Border.all(color: Appcolors().searchTextcolor),
                ),
                             height: screenHeight*0.05,width: screenWidth*0.1,
                              child:  Icon(Icons.percent),
                            ),
                          ],
                        ),
                      ),
                       SizedBox(width: screenHeight*0.02,),
                      Container(
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                   borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),topLeft: Radius.circular(5)),
                  color: Colors.white,
                  border: Border.all(color: Appcolors().searchTextcolor),
                ),
                             height: screenHeight*0.05,width: screenWidth*0.1,
                              child:  Icon(Icons.currency_rupee),
                            ),
                            Container(
                            padding: EdgeInsets.symmetric(vertical: screenHeight*0.01,horizontal: screenHeight*0.01),

                              height: screenHeight*0.05,width: screenWidth*0.2,
                              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(5),topRight: Radius.circular(5)),
                  color: Colors.white,
                  border: Border.all(color: Appcolors().searchTextcolor),
                ),
                              child:Text("${taxvalue}",style: getFontsinput(14, Colors.black),),
                            ),
                           
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                 SizedBox(height: screenHeight*0.012,),
                Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Amount",style: getFonts(14, Colors.black),),
              Column(children: [
                Row(
                  children: [
                    Text("₹",style: getFonts(14, Colors.black)),
                Text("${finalAmt}",style: getFonts(14, Colors.red),
                        
                      ),                  ],
                ),
                
              ],)
            ],
          ),
         ),
         Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Net Balance",style: getFonts(12, Colors.black),),
              Column(children: [
                Row(
                  children: [
                    Text("₹",style: getFonts(12, Colors.black)),
                Text("${_grandTotal}",style: getFonts(12, Colors.red),
                        
                      ),                  ],
                ),
                
              ],)
            ],
          ),
         ),
          ],
        ),
      ),

          ],
        ),
      ),
       bottomNavigationBar:Container(
        padding: EdgeInsets.symmetric(horizontal: screenHeight*0.022,vertical:screenHeight*0.02 ),
        child: Row(children: [
          GestureDetector(
            onTap: (){
               if (widget.selectedItemC != null) {
      int index = temporaryData.indexWhere(
        (item) => item['itemname'] == widget.selectedItemC!['itemname'],
      );
      if (index != -1) {
        setState(() {
          temporaryData.removeAt(index); 
          _calculateGrandTotal(); 
           _editDataInTemporaryList();
          _itemnameController.clear();
          _qtyController.clear();
          _rateController.clear();
          _subtotalController.clear();
          _DiscountController.clear();
          _Discpercentroller.clear();
          _taxController.clear();
          _taxvalueController.clear();
          _totalamtController.clear();
        });
      }
    } else {
      _addDataToTemporaryList(); 
    }
              
            },
            child: Container(
              width: screenWidth * 0.45,height: screenHeight*0.07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5),bottomLeft: Radius.circular(5)),
                color: Appcolors().Scfold
                
              ),
              child: Center(child: Text(widget.selectedItemC != null ? "Delete" : "Save & New",style: getFonts(15, Colors.black),)),
            ),
          ),
          GestureDetector(
            onTap: (){
                  if (widget.selectedItemC != null) {
      _editDataInTemporaryList();
     
    } else {
      if(_itemnameController.text.isEmpty && _qtyController.text.isEmpty && _rateController.text.isEmpty){
 ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please Fill the blanks')),
    );
    return;
}
if(selectedValue == null || selectedValue!.trim().isEmpty){
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please select Tax')),
    );
    return;
}
      _addDataToTemporaryList();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SalesOrder(
            cusname: widget.billname,
            grandtotal: _grandTotal,
            tempdata: temporaryData,
          ),
        ),
      );
    }
            },
            child: Container(
              width: screenWidth * 0.45,height: screenHeight*0.07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(5),bottomRight: Radius.circular(5)),
                color: Appcolors().maincolor
              ),
              child: Center(child: Text(
                 widget.selectedItemC != null ? "Edit" : "Save",style: getFonts(15, Colors.white),)),
            ),
          )
        ],),
      ), 
    );
  }

  void _showCreateItemDialog(String itemName, String unit, double qty, double rate, double tax, double totalAmt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(backgroundColor: Appcolors().Scfold,
          title: Text('Create a new item'),
          content: Text('Item "$itemName" does not exist. Would you like to create it?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',style: TextStyle(color: Appcolors().maincolor),),
            ),
            TextButton(
              onPressed: () async {
                final creditsale = SalesCredit(
                  invoiceId: 0,
                  date: "",
                  salesRate: 0.0,
                  customer: "",
                  phoneNo: "",
                  itemName: itemName,
                  qty: qty,
                  unit: unit,
                  rate: rate,
                  tax: tax,
                  totalAmt: totalAmt,
                );
                await SaleDatabaseHelper.instance.insert(creditsale.toMap());
                Navigator.of(context).pop();  
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item created and saved')));
                _fetchItemNames();
              },
              child: Text('Create',style: TextStyle(color: Appcolors().maincolor),),
            ),
          ],
        );
      },
    );
  }
TableRow _buildTableRow(String label, String? value) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      GestureDetector(
        onTap: () {
          setState(() {
            _selectedRate = value ?? "N/A";
            _rateController.text = value.toString(); 
            _isDropdownVisible = false; 
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(value ?? "N/A"),
        ),
      ),
    ],
  );
}

void _showRatesDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Rates"),
        content: Container(
          width: 300,
          height: 250,
          child: itemDetails.isNotEmpty
              ? Table(
                  border: TableBorder.all(color: Colors.grey),
                  children: [
                    _buildTableRow("MRP", itemDetails[0]["mrp"] ?? ""),
                    _buildTableRow("Retail", itemDetails[0]["retail"] ?? ""),
                    _buildTableRow("WS Rate", itemDetails[0]["wsrate"] ?? ""),
                    _buildTableRow("SP Rate", itemDetails[0]["sprate"] ?? ""),
                    _buildTableRow("Branch", itemDetails[0]["branch"] ?? ""),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'No data found for the selected item.',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      );
    },
  );
}
 
}