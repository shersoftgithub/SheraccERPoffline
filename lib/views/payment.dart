import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class PaymentForm extends StatefulWidget {
  const PaymentForm({super.key});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
final TextEditingController _adressController=TextEditingController();
final TextEditingController _contactController=TextEditingController();
final TextEditingController _mailController=TextEditingController();
final TextEditingController _taxnoController=TextEditingController();
final TextEditingController _pricelevelController=TextEditingController();
final TextEditingController _balanceController=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors().scafoldcolor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Appcolors().maincolor,
        
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text("Sheracc ERP Offline",style: appbarFonts(15,Colors.white),),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: IconButton(
              onPressed: () {},
              icon: IconButton(onPressed: (){},
               icon: Icon(Icons.more_vert,color: Colors.white,),),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(left: 5,right: 5),
            child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 19, right: 10,top: 13),
                    child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select Supplier",style: formFonts(14, Colors.grey),),
                  SizedBox(height: 10,),
                  Container(
                          height: 39,
                          width: 310,
                          decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white, 
                  border: Border.all(color: Appcolors().searchTextcolor)
                          ),
                          child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), 
                  child: Row(
                    children: [
                      SizedBox(width: 1), 
                      Expanded( 
                        child: TextFormField(
                        
                          obscureText: false,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(bottom: 12), 
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
                  ),
                  SizedBox(width: 1),
                  Padding(
                    padding: const EdgeInsets.only(top: 45),
                    child: Container(
                      width: 39,
                      height: 39,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFF0008B4),
                      ),
                      child: IconButton(
                        onPressed: () {
                        },
                        icon: Icon(Icons.add, color: Colors.white,size: 22,),
                      ),
                    ),
                  ),
                ],
              ),
          ),
            SizedBox(height: 20,),
           Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
               _Paymentfield("Address", _adressController),
               SizedBox(height: 15,),
               _Paymentfield("Contact NO", _contactController),
               SizedBox(height: 15,),
               _Paymentfield("Mail", _mailController),
               SizedBox(height: 15,),
               _Paymentfield("Tax NO", _taxnoController),
               SizedBox(height: 15,),
               _Paymentfield("Price Level", _pricelevelController),
               SizedBox(height: 15,),
               _Paymentfield("Balance", _balanceController),
               SizedBox(height: 15,),
              ],
            ),
           )
        ],),
      ),
      bottomNavigationBar: GestureDetector(
                  onTap: (){
                
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      height: 51,width: 358,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                         color: Color(0xFF0A1EBE), 
                      ),
                      child: Center(child: Text("Payment",style: getFonts(16, Colors.white)),
                     ) ),
                  ),
                )
    )
    ;
  }
    Widget _Paymentfield (String textrow,TextEditingController controller){
    return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(textrow,style: formFonts(16, Colors.black),),
                  Text("*",style: TextStyle(fontSize: 16,color: Color(0xFFE22E37)),)
                ],),
                SizedBox(height: 10,),
                Container(
                        height: 45,
                        width: 358,
                        decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white, 
                border: Border.all(color: Appcolors().searchTextcolor)
                        ),
                        child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), 
                child: Row(
                  children: [
                    SizedBox(width: 5), 
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
                          contentPadding: EdgeInsets.only(bottom: 12), 
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