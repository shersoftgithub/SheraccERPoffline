import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class Company extends StatefulWidget {
  const Company({super.key});

  @override
  State<Company> createState() => _CompanyState();
}

class _CompanyState extends State<Company> {
  final TextEditingController _companyController =TextEditingController();
  final TextEditingController _address1Controller =TextEditingController();
  final TextEditingController _address2Controller =TextEditingController();
  final TextEditingController _taxnoController =TextEditingController();
  final TextEditingController _mobileController =TextEditingController();
  final TextEditingController _mailController =TextEditingController();
  final TextEditingController _stateController =TextEditingController();
  final TextEditingController _statecodeController =TextEditingController();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Appcolors().scafoldcolor,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        backgroundColor: Appcolors().maincolor,
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
            child: Text(
              "Sheracc ERP Offline",
              style: appbarFonts(MediaQuery.of(context).size.width * 0.04, Colors.white),
            ),
          ),
        ),
        actions: [
          Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: screenHeight*0.01,horizontal: screenHeight*0.02),
            child: Column(
              children: [
_field("Company Name", _companyController, screenWidth, screenHeight),
_field("Adress1", _address1Controller, screenWidth, screenHeight),
_field("Address2", _address2Controller, screenWidth, screenHeight),
_field("TAX NO", _taxnoController, screenWidth, screenHeight),
_field("Mobile", _companyController, screenWidth, screenHeight),
_field("Mail", _companyController, screenWidth, screenHeight),
_field("State", _companyController, screenWidth, screenHeight),
_field("Statecode", _companyController, screenWidth, screenHeight)

              ],
            ),
          )
        ],
      ),
    );
  }
  Widget _field(String txt,TextEditingController controller,double screenWidth, double screenHeight){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              // validator: (value) {
              //   if (value == null || value.isEmpty) {
              //     return 'Please enter $textrow';
              //   }
              //   return null;
              // },
              obscureText: false,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                contentPadding: EdgeInsets.only(bottom: screenHeight * 0.01),
                hintText: "$txt",
                hintStyle: TextStyle(fontSize: 14)
              ),
            ),
          ),
        ],
      ),
    );
  }
}