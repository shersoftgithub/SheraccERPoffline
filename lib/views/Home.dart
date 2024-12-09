import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/payment.dart';

class HomePageERP extends StatefulWidget {
  const HomePageERP({super.key});

  @override
  State<HomePageERP> createState() => _HomePageERPState();
}

class _HomePageERPState extends State<HomePageERP> {
final List Names=[
  "Payment","Receipt","Sales","Sales Report","Ledger Report","Payment Report","Receipt Report"
];
final List images=[
  "assets/images/cash-payment.png",
  "assets/images/receipt-payment.png",
  "assets/images/sales.png",
  "assets/images/sales report.png",
  "assets/images/ledger.png",
  "assets/images/payment report.png",
  "assets/images/reciept report.png"
];
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
     
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              crossAxisCount: 2,
            ),
            itemCount: Names.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentForm()));
                  } else if (index == 1) {
                   // Navigator.push(context, MaterialPageRoute(builder: (_) => Jobcards()));
                  }else if(index==2){
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => JobcardBill()));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3,vertical: 3),
                  child: Container(
                    width: 167,
                    height: 138,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                          BoxShadow(
                            color: Appcolors().searchTextcolor,
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                            offset: Offset(0.0, 0.0), // shadow direction: bottom right
                          )
                        ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            height: 77,
                            width: 77,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(42),
                            ),
                            child: Image.asset(images[index],scale: 1.0, 
                            //fit: BoxFit.cover
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          Names[index],
                          style: getFonts(15, Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}