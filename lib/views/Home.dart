import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/Ledgerreport.dart';
import 'package:sheraaccerpoff/views/newLedger.dart';
import 'package:sheraaccerpoff/views/payment.dart';
import 'package:sheraaccerpoff/views/paymentReport.dart';
import 'package:sheraaccerpoff/views/purcahsereport.dart';
import 'package:sheraaccerpoff/views/reciept.dart';
import 'package:sheraaccerpoff/views/recieptreport.dart';
import 'package:sheraaccerpoff/views/sales.dart';
import 'package:sheraaccerpoff/views/salesReport.dart';
import 'package:sheraaccerpoff/views/stockreport.dart';

class HomePageERP extends StatefulWidget {
  const HomePageERP({super.key});

  @override
  State<HomePageERP> createState() => _HomePageERPState();
}

class _HomePageERPState extends State<HomePageERP> {
  final List<String> names = [
    "Payment",
    "Receipt",
    "Sales",
    "Sales Report",
    "Ledger Report",
    "Ledger",
    "Payment Report",
    "Receipt Report",
    "Exit",
    "Stock Report"
  ];

  final List<String> images = [
    "assets/images/cash-payment.png",
    "assets/images/receipt-payment.png",
    "assets/images/sales.png",
    "assets/images/sales report.png",
    "assets/images/ledger.png",
    "assets/images/ledger (2).png",
    "assets/images/payment report.png",
    "assets/images/reciept report.png"

    ,"assets/images/logout.png",
    "assets/images/stock report.png"
  ];
 List<String> menuItems = [
  "Company","configure","settings","sync Data","Backup","Export Backup","Clear Data",
 ];
 void navigateToPage(BuildContext context, String item) {
    switch (item) {
      case "Company":
        //Navigator.push(context, MaterialPageRoute(builder: (context) => CompanyPage()));
        break;
      case "Configure":
       // Navigator.push(context, MaterialPageRoute(builder: (context) => ConfigurePage()));
        break;
      case "Settings":
       // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
        break;
      case "Sync Data":
        // Handle sync data logic here
        print("Syncing data...");
        break;
      case "Backup":
        // Handle backup logic here
        print("Backup...");
        break;
      case "Export Backup":
        // Handle export backup logic here
        print("Exporting backup...");
        break;
      case "Clear Data":
        // Handle clear data logic here
        print("Clearing data...");
        break;
      default:
        print("Unknown option selected: $item");
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final gridItemWidth = screenWidth * 0.4;
    final gridItemHeight = screenHeight * 0.2;

    return Scaffold(
      backgroundColor: Appcolors().scafoldcolor,
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.1,
        backgroundColor: Appcolors().maincolor,
        leading: Text(""),
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: Text(
              "Sheracc ERP Offline",
              style: appbarFonts(screenWidth * 0.04, Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 20,right: 10),
            child: PopupMenuButton<String>(
          onSelected: (String selectedItem) {
            // Call navigation function when a menu item is selected
            navigateToPage(context, selectedItem);
          },
          itemBuilder: (BuildContext context) {
            return menuItems.map((String item) {
              return PopupMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList();
          },
          child: Icon( Icons.more_vert,color: Colors.white,),
        ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: screenHeight * 0.02,
              crossAxisSpacing: screenWidth * 0.03,
              crossAxisCount: 2,
              childAspectRatio: gridItemWidth / gridItemHeight,
            ),
            itemCount: names.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => PaymentForm()));
                  } else if (index == 1) {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Reciept()));
                  } else if (index == 2) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SalesOrder()));
                  }else if(index ==3){
                Navigator.push(
                        context, MaterialPageRoute(builder: (_) => SalesReport()));
                  }else if(index==4){
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => LedgerReport()));
                  }else if(index==5){
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Newledger()));
                  }else if(index==6){
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Paymentreport()));
                  }else if(index==7){
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Recieptreport()));
                  }else if(index==8){
                    exit();
                  }else if(index==9){
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => StockReport()));
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.01,
                      vertical: screenHeight * 0.01),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      boxShadow: [
                        BoxShadow(
                          color: Appcolors().searchTextcolor,
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset: Offset(0.0, 0.0), // Shadow direction
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            height: gridItemHeight * 0.5,
                            width: gridItemWidth * 0.5,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.1),
                            ),
                            child: Image.asset(
                              images[index],
                              scale: 1.0,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          names[index],
                          style: getFonts(screenWidth * 0.04, Colors.black),
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
  // void navigateToPage(BuildContext context, String item) {
  //   // Navigate to a different page based on the selected item
  //   switch (item) {
  //     case 'Item 1':
  //       // Navigator.push(
  //       //   context,
  //       //   MaterialPageRoute(builder: (context) => Page1()),
  //       // );
  //       break;
  //     case 'Item 2':
  //       // Navigator.push(
  //       //   context,
  //       //   MaterialPageRoute(builder: (context) => Page2()),
  //       // );
  //       break;
  //     case 'Item 3':
  //       // Navigator.push(
  //       //   context,
  //       //   MaterialPageRoute(builder: (context) => Page3()),
  //       // );
  //       break;
  //     // Add more cases for the remaining items
  //     // default:
  //     //   Navigator.push(
  //     //     context,
  //     //     MaterialPageRoute(builder: (context) => DefaultPage()),
  //     //   );
  //   }
  // }
  void exit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(backgroundColor: Appcolors().Scfold,
         
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text('Are you confirm To Exit App?',style: getFonts(14, Colors.black),),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',style: getFonts(15, Appcolors().maincolor)),
            ),
            TextButton(
              onPressed: () async {
              SystemNavigator.pop();
              },
              child: Text('Yes',style: getFonts(15, Appcolors().maincolor),),
            ),
          ],
        );
      },
    );
  }
}
