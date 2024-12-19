import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/utility/colors.dart';

import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/Home.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePageERP()));
    });
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
          Color(0xFF0616BA),
        Color(0xFF387FE9),])
      ),
      child: Column(
  mainAxisAlignment: MainAxisAlignment.center, 
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    SizedBox(height: 300,),
    Container(
      child: Image.asset("assets/images/launch 1.png"),
    ),
    SizedBox(height: 10,),
    Center(
      child: Row(
        children: [
          SizedBox(width: screenHeight*0.12,),
          Text(
            "SherAcc", 
            style: splashFonts( ),
          ),
          SizedBox(width: 3,),
          ClipPath(
            clipper: SlantedContainerClipper(),
            child: Container(
              height: 30,
              color: Colors.white,
             
              child: Center(child: Text("  ERP",style: splash3Fonts(),)),
            ),
          ),
        ],
      ),
    ),
    Expanded(
      child: Align(
        alignment: Alignment.bottomCenter, 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Text(
              "offline", 
              style: splash2Fonts(),
            ),
            SizedBox(width: 7,),
            Icon(Icons.cloud_off_outlined,color: Colors.white,)
          ],
        ),
      ),
    ),
    SizedBox(height: 20,)
  ],
)

      ),
    );
  }

}class SlantedContainerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Start with the sloped left edge
    path.moveTo(size.width * 0.3, 0); // Slope starting point
    path.lineTo(size.width, 0); // Top-right edge
    path.lineTo(size.width, size.height); // Right vertical edge
    path.lineTo(1, size.height); // Bottom edge
    path.lineTo(0, size.height * 0.8); // Left bottom point
    path.lineTo(size.width * 0.2, 0); // Diagonal sloped line to the top-left

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

