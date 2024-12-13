import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sheraaccerpoff/models/paymant_model.dart';
import 'package:sheraaccerpoff/provider/sherprovider.dart';
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
                
                'Date',
                style: formFonts(14, Colors.black),
              ),
          SizedBox(height: screenHeight * 0.01),
          Container(
             height: 35, 
            width: 172,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
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
                
                'Cash Account',
                style: formFonts(14, Colors.black),
              ),
          SizedBox(height: screenHeight * 0.01),
          Container(
             height: 35, 
            width: 172,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
            ),
            // child: EasyAutocomplete(
            //             controller: _InvoicenoController,
            //             //suggestions: vamnes
            //                 //.map((jobcard) => jobcard['VehicleName'].toString())
            //                 //.toList(),
            //             // onSubmitted: (value) {
            //             //   onJobcardSelected(value);  // Handle selection
            //             // },
            //             decoration: InputDecoration(
            //               border: InputBorder.none,
            //             ),
            //           ),
          ),
        ],
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
      Container(
        padding: EdgeInsets.symmetric(horizontal: screenHeight*0.02),
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
                    child: TextFormField(
                     // controller: controller,
                     
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
    SizedBox(height: screenHeight * 0.02),
    Padding(
      padding: const EdgeInsets.only(right: 295),
      child: Text("Balance : ",style: getFonts(14, Appcolors().maincolor),),
    ),
    SizedBox(height: screenHeight * 0.02),
    Container(
      padding: EdgeInsets.symmetric(horizontal: screenHeight*0.02),
      child: Column(children: [
        _paymentField("Amount", _adressController, screenWidth, screenHeight),
        SizedBox(height: screenHeight * 0.01),
        _paymentField("Discount", _adressController, screenWidth, screenHeight),
        SizedBox(height: screenHeight * 0.01),
         Padding(
      padding: const EdgeInsets.only(right: 320),
      child: Text("Total : ",style: getFonts(14, Appcolors().maincolor),),
    ),
      SizedBox(height: screenHeight * 0.01),
            _paymentField("Narration", _adressController, screenWidth, screenHeight)
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
