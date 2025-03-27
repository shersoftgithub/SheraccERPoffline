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
  @override
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
    double fontSize1 = screenWidth * 0.07;
    double fontSize2 = screenWidth * 0.06;
    double fontSize3 = screenWidth * 0.03;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0616BA),
              Color(0xFF387FE9),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.2),
            Container(
              child: Image.asset(
                "assets/images/launch 1.png",
                height: screenHeight * 0.25, 
              ),
            ),
            Center(
              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "SherAcc",
                    style: splashFonts(fontSize1), 
                  ),
                  SizedBox(width: 3),
                  ClipPath(
                    clipper: SlantedContainerClipper(),
                    child: Container(
                      height: screenHeight * 0.04, 
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          "  ERP",
                          style: splash3Fonts(fontSize2), 
                        ),
                      ),
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
                      style: splash2Fonts(fontSize3), 
                    ),
                    SizedBox(width: 7),
                    Icon(
                      Icons.cloud_off_outlined,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }
}

class SlantedContainerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.3, 0); 
    path.lineTo(size.width, 0); 
    path.lineTo(size.width, size.height);
    path.lineTo(1, size.height); 
    path.lineTo(0, size.height * 0.8); 
    path.lineTo(size.width * 0.2, 0); 

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
