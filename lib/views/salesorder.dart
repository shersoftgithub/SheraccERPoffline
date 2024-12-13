import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/addPaymant.dart';

class SalesOrder extends StatefulWidget {
  const SalesOrder({super.key});

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
  bool isCreditSelected = true;
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
         body: Center(
        child: isCreditSelected
            ? _CreditScreenContent(screenHeight,screenWidth)
            : _CashScreenContent(screenHeight,screenWidth),
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
            onTap: (){},
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
             height: 26, 
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
             height: 26, 
            width: 172,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
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
            _field("Billing Name", _CustomerController, screenWidth, screenHeight),
            SizedBox(height: screenHeight*0.03,),
             _field("Phone Number", _CustomerController, screenWidth, screenHeight),
             SizedBox(height: screenHeight*0.001,),
             GestureDetector(
        onTap: () {
          Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Addpaymant()));
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
                    style: getFonts(screenHeight * 0.01, Colors.white),
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
                    Text("...........................",style: getFonts(14, Colors.black))
                  ],
                ),
                // Text(".......................",style: getFonts(10, Colors.black),)
              ],)
            ],
          ),
         ),
       )
      ],
    );
  }

  // Cash Screen Content
  Widget _CashScreenContent(double screenHeight,double screenWidth) {
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
             height: 26, 
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
             height: 26, 
            width: 172,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
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
            _field("Customer", _CustomerController, screenWidth, screenHeight),
            SizedBox(height: screenHeight*0.03,),
             _field("Phone Number", _CustomerController, screenWidth, screenHeight),
             SizedBox(height: screenHeight*0.001,),
             GestureDetector(
        onTap: () {
          Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Addpaymant()));
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
                    style: getFonts(screenHeight * 0.01, Colors.white),
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
                    Text("...........................",style: getFonts(14, Colors.black))
                  ],
                ),
                // Text(".......................",style: getFonts(10, Colors.black),)
              ],)
            ],
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
}