import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sheraaccerpoff/provider/sherprovider.dart';
import 'package:sheraaccerpoff/views/Home.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PaymentFormProvider()), 
        //ChangeNotifierProvider(create: (context) => UserProvider()), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePageERP(), 
    );
  }
}