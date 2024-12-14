import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class Newledger extends StatefulWidget {
  const Newledger({super.key});

  @override
  State<Newledger> createState() => _NewledgerState();
}

class _NewledgerState extends State<Newledger> with SingleTickerProviderStateMixin {
  late TabController _tabController;
 final TextEditingController _adressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _taxnoController = TextEditingController();
  final TextEditingController _pricelevelController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _selectSupplierController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
bool _isChecked = false;

Map<String, bool> _checkboxStates = {
    "Active": false,
    "Cost Center": false,
    "Franchise": false,
    "Bill Wise": false,
  };
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
              size: 20,
            ),
          ),
        ),
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: Text(
              "Ledger",
              style: appbarFonts(screenHeight * 0.02, Colors.white),
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
      body: Column(
        children: [
          // Top Buttons Row
          Container(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02,horizontal: screenHeight*0.07),
            child: Row(
             
              children: [
                GestureDetector(
                  onTap: () {},
                  child: _TopButtons("Save", screenWidth, screenHeight),
                ),
                SizedBox(width: screenHeight*0.02,),
                GestureDetector(
                  onTap: () {},
                  child: _TopButtons("Clear", screenWidth, screenHeight),
                ),
                SizedBox(width: screenHeight*0.02,),
                GestureDetector(
                  onTap: () {},
                  child: _TopButtons("Delete", screenWidth, screenHeight),
                ),
              ],
            ),
          ),
          // Tabs below buttons
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: screenHeight*0.02),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                color: Appcolors().maincolor,
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Appcolors().maincolor,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                labelStyle: getFonts(12, Colors.white),
                tabs: const [
                  Tab(text: "Account",),
                  Tab(text: "Address"),
                  Tab(text: "Opening Balance",),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AccountTab(screenHeight,screenWidth), // Account Tab
                _AddressTab(screenHeight,screenWidth), // Address Tab
                _OpeningBalanceTab(screenHeight,screenWidth), // Opening Balance Tab
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _TopButtons(String text, double screenWidth, double screenHeight) {
    return Container(
      height: 33,
      width: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color(0xFF0A1EBE),
      ),
      child: Center(
        child: Text(
          text,
          style: getFonts(16, Colors.white),
        ),
      ),
    );
  }

  // Account Tab Content
  Widget _AccountTab(double screenHeight,double screenWidth) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: screenHeight*.02),
          child: Column(
            children: [
              SizedBox(height: screenHeight*0.05,),
        _accfield(screenHeight, screenWidth, "Ledger Name"),
          SizedBox(height: screenHeight*0.03,),
           _accfield(screenHeight, screenWidth, "Under")
            ],
          ),
        )
      ],
    );
  }
  
Widget _accfield(double screenHeight,double screenWidth,String label ){
  return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: getFonts(14, Colors.black),
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
  // Address Tab Content
  Widget _AddressTab(double screenHeight,double screenWidth) {
    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: screenHeight*0.05,),
        Container(
          padding: EdgeInsets.symmetric(horizontal: screenHeight*0.03),
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
    );
  }

  // Opening Balance Tab Content
  Widget _OpeningBalanceTab(double screenHeight,double screenWidth) {
    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Column(
        children: [
           SizedBox(height: screenHeight * 0.03),
          Center(
            child: Text("Opening Balance",style: getFonts(16, Color(0xFF0008B4)),),
          ),
           SizedBox(height: screenHeight * 0.01),
          Center(
            child: Container(
        height: screenHeight * 0.04,
        width: screenWidth * 0.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade600)
        ),
        
      ),
          ),
          SizedBox(height: screenHeight * 0.04),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: screenHeight*0.03),
            child: Container(
              
              child: Column(
                children: [
                  Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _field("Recieve Amount", screenWidth, screenHeight),
                _field("Recieve Amount", screenWidth, screenHeight)
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
                     Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buttonOB(screenHeight, screenWidth, "Active"),
                     _buttonOB(screenHeight, screenWidth, "Cost Center"),
            ],
                     ),
                     SizedBox(height: screenHeight * 0.02),
                     Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buttonOB(screenHeight, screenWidth, "Franchise"),
                     _buttonOB(screenHeight, screenWidth, "Bill Wise")
            ],
                     )
                ],
              ),
            ),
          )
        ],
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
  Widget _field (String label,double screenWidth,double screenHeight ){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: formFonts(screenWidth * 0.03, Colors.black),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            height: screenHeight * 0.04,
            width: screenWidth * 0.4,
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
  Widget _buttonOB(double screenHeight,double screenWidth,String txt){
     
    return Container(
            height: screenHeight * 0.05,
            width: screenWidth * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(0xFF0A1EBE),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    "$txt",
                    style: getFonts(14, Colors.white),
                  ),
                ),
                Checkbox(
                  side: BorderSide(color: Colors.white),
                value: _checkboxStates[txt] ?? false,
                onChanged: (bool? value) {
                  setState(() {
                    _checkboxStates[txt] = value!;
                  });
                },
                
                checkColor: Appcolors().maincolor,
                activeColor: Colors.white, 
              ),
              ],
            ),
          );
  }
}
