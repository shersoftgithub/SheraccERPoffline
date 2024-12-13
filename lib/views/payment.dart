import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sheraaccerpoff/models/paymant_model.dart';
import 'package:sheraaccerpoff/provider/sherprovider.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/payment_databsehelper.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class PaymentForm extends StatefulWidget {
  const PaymentForm({super.key});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final TextEditingController _adressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _taxnoController = TextEditingController();
  final TextEditingController _pricelevelController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _selectSupplierController = TextEditingController();
   List <String>_supplierSuggestions=[];
   @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

    Future<void> _fetchSuppliers() async {
    final dbHelper = DatabaseHelper();
    final suppliers = await dbHelper.getSuppliers();
    
    setState(() {
      _supplierSuggestions = suppliers.map((supplier) => supplier.suppliername).toList();
    });
  }

  void onJobcardSelected(String value) {
    print('Selected Supplier: $value');
   
    _selectSupplierController.text = value;
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
              size: 15,
            ),
          ),
        ),
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02),
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: screenWidth * 0.05,
                        right: screenWidth * 0.03,
                        top: screenHeight * 0.02),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Supplier",
                            style: formFonts(screenWidth * 0.035, Colors.grey),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Container(
                            height: screenHeight * 0.08,
                            width: screenWidth * 0.7,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(screenWidth * 0.02),
                              color: Colors.white,
                              border: Border.all(color: Appcolors().searchTextcolor),
                            ),
                            child: EasyAutocomplete(
                                                    controller: _selectSupplierController,
                                                    suggestions: _supplierSuggestions,
                            
                                                    onSubmitted: (value) {
                                                      onJobcardSelected(value);
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
                  SizedBox(width: screenWidth * 0.04),
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.06),
                    child: Container(
                      width: screenWidth * 0.1,
                      height: screenHeight * 0.05,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        color: Color(0xFF0008B4),
                      ),
                      child: IconButton(
                        onPressed: () {
                          showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Appcolors().Scfold,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text( "Enter Supplier"),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _selectSupplierController,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Appcolors().scafoldcolor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Appcolors().maincolor),
                    ),
                    hintText: "Enter supplier name",
                    hintStyle: TextStyle(color: Color(0xFF948C93)),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () async {
                    final supplierData = SupplierModel(suppliername: _selectSupplierController.text);
                  try {
                    await Provider.of<PaymentFormProvider>(context, listen: false)
                        .insertSupplier(supplierData); 

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Supplier Saved Successfully!'),
                      ),
                    );

                    _selectSupplierController.clear();
                    Navigator.pop(context); 
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                      ),
                    );
                  }
                  },
                  child: Center(
                    child: Container(
                      width: 155,
                      height: 43,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFF0008B4),
                      ),
                      child: Center(
                        child: Text(
                         "Save",
                          style: getFonts(14, Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
                        },
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: screenWidth * 0.05,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                children: [
                  _paymentField("Address", _adressController, screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.02),
                  _paymentField("Contact NO", _contactController, screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.02),
                  _paymentField("Mail", _mailController, screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.02),
                  _paymentField("Tax NO", _taxnoController, screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.02),
                  _paymentField("Price Level", _pricelevelController, screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.02),
                  _paymentField("Balance", _balanceController, screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          final paymentData = PaymentFormModel(
            address: _adressController.text,
            contactno: _contactController.text,
            mailid: _mailController.text,
            taxno: _taxnoController.text,
            pricelevel: _pricelevelController.text,
            balance: _balanceController.text,
          );

          Provider.of<PaymentFormProvider>(context, listen: false)
              .insertPaymentData(paymentData)
              .then((_) {
                _adressController.clear();
                _balanceController.clear();
                _contactController.clear();
                _mailController.clear();
                _pricelevelController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment Data Saved Successfully!'),
              ),
            );
          }).catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
              ),
            );
          });
        },
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Container(
            height: screenHeight * 0.07,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              color: Color(0xFF0A1EBE),
            ),
            child: Center(
              child: Text(
                "Payment",
                style: getFonts(screenWidth * 0.04, Colors.white),
              ),
            ),
          ),
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
                style: formFonts(screenWidth * 0.04, Colors.black),
              ),
              Text(
                "*",
                style: TextStyle(fontSize: screenWidth * 0.04, color: Color(0xFFE22E37)),
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
}
