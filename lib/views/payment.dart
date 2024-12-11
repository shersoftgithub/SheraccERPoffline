import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Appcolors().scafoldcolor,
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.1,
        backgroundColor: Appcolors().maincolor,
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
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert, color: Colors.white),
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
                            height: screenHeight * 0.05,
                            width: screenWidth * 0.85,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(screenWidth * 0.02),
                              color: Colors.white,
                              border: Border.all(color: Appcolors().searchTextcolor),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                              child: Row(
                                children: [
                                  SizedBox(width: screenWidth * 0.01),
                                  Expanded(
                                    child: TextFormField(
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
                  ),
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
                        onPressed: () {},
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
        onTap: () {},
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
